//  Assemble
//  ============================
//  Original author: Dave O'Neill.
//  Copyright 2018 AudioKit. All rights reserved.
//  License: <https://github.com/AudioKit/AudioKit/blob/master/LICENSE>

#import "ASAudioUnitBase.h"

const int kMaxChannelCount = 16;

static void    prepareBufferList(AudioBufferList *, int, int);
static void    clearBufferList(AudioBufferList *);
static size_t  bufferListByteSize(int);
static Boolean bufferListHasNullData(AudioBufferList *);
static void    bufferListPointChannelDataToBuffer(AudioBufferList *, float *);

@implementation ASAudioUnitBase
{
    float               *_inputBuffer;
    float               *_ouputBuffer;
    AUAudioUnitBusArray *_inputBusArray;
    AUAudioUnitBusArray *_outputBusArray;
    ProcessEventsBlock  _processEventsBlock;
    BOOL                _shouldClearOutputBuffer;
}

- (instancetype)initWithComponentDescription:(AudioComponentDescription)componentDescription
                                     options:(AudioComponentInstantiationOptions)options
                                       error:(NSError **)outError
{
    self = [super initWithComponentDescription:componentDescription options:options error:outError];
    
    if (self != nil)
    {
        AVAudioFormat *format = [[AVAudioFormat alloc] initStandardFormatWithSampleRate:48000 channels:2];
        
        if ([self shouldAllocateInputBus])
            _inputBusArray  = [[AUAudioUnitBusArray alloc] initWithAudioUnit:self
                                                                     busType:AUAudioUnitBusTypeInput
                                                                      busses: @[[[AUAudioUnitBus alloc]initWithFormat:format error:NULL]]];

        _outputBusArray = [[AUAudioUnitBusArray alloc] initWithAudioUnit:self
                                                                 busType:AUAudioUnitBusTypeOutput
                                                                  busses: @[[[AUAudioUnitBus alloc]initWithFormat:format error:NULL]]];

        _shouldClearOutputBuffer = [self shouldClearOutputBuffer];
    }
    
    return self;
}

-(BOOL)shouldAllocateInputBus
{
    return true;
}

-(BOOL)shouldClearOutputBuffer
{
    return false;
}

- (BOOL)allocateRenderResourcesAndReturnError:(NSError **)outError
{
    if (![super allocateRenderResourcesAndReturnError:outError]) return NO;

    AVAudioFormat *format = _outputBusArray[0].format;

    if (_inputBusArray != NULL && [_inputBusArray[0].format isEqual: format] == false)
    {
        if (outError)
            *outError = [NSError errorWithDomain:NSOSStatusErrorDomain
                                            code:kAudioUnitErr_FormatNotSupported userInfo:nil];

        NSLog(@"%@ input format must match output format", self.class);
        self.renderResourcesAllocated = NO;
        return NO;
    }

    assert(_inputBuffer == NULL && _ouputBuffer == NULL);
    
    size_t bufferSize = sizeof(float) * format.channelCount * self.maximumFramesToRender;

    if (self.shouldAllocateInputBus)
        _inputBuffer = malloc(bufferSize);
    
    if (self.canProcessInPlace == false || self.shouldAllocateInputBus == false)
        _ouputBuffer = malloc(bufferSize);

    _processEventsBlock = [self processEventsBlock: format];

    return YES;
}

-(void)deallocateRenderResources
{
    if (_inputBuffer != NULL) free(_inputBuffer);
    if (_ouputBuffer != NULL) free(_ouputBuffer);

    _inputBuffer = NULL;
    _ouputBuffer = NULL;

    [super deallocateRenderResources];
}

-(ProcessEventsBlock)processEventsBlock:(AVAudioFormat *)format
{
    return ^(AudioBufferList       *inBuffer,
             AudioBufferList       *outBuffer,
             const AudioTimeStamp  *timestamp,
             AVAudioFrameCount     frameCount,
             const AURenderEvent   *realtimeEventListHead)
    {
        if (inBuffer == NULL)
        {
            for (int i = 0; i < outBuffer->mNumberBuffers; i++)
                memset(outBuffer->mBuffers[i].mData, 0, outBuffer->mBuffers[i].mDataByteSize);
        }

        else
        {
            for (int i = 0; i < inBuffer->mNumberBuffers; i++)
                memcpy(outBuffer->mBuffers[i].mData, inBuffer->mBuffers[i].mData, inBuffer->mBuffers[i].mDataByteSize);
        }
    };
}

- (AUInternalRenderBlock)internalRenderBlock
{
    __unsafe_unretained ASAudioUnitBase *base = self;
    
    return  ^AUAudioUnitStatus(AudioUnitRenderActionFlags    *actionFlags,
                               const AudioTimeStamp          *timestamp,
                               AVAudioFrameCount             frameCount,
                               NSInteger                     outputBusNumber,
                               AudioBufferList               *outputBufferList,
                               const AURenderEvent           *realtimeEventListHead,
                               AURenderPullInputBlock        pullInputBlock)
    {
        const int channelCount = outputBufferList->mNumberBuffers;

        // Guard against potential stack overflow.
        assert(channelCount <= kMaxChannelCount);
        assert(channelCount >= 1);

        const char inputBufferAllocation[bufferListByteSize(outputBufferList->mNumberBuffers)];

        AudioBufferList *inputBufferList = NULL;

        if (base->_inputBuffer != NULL)
        {
            // Prepare buffer for pull input.
            inputBufferList = (AudioBufferList *)inputBufferAllocation;
            prepareBufferList(inputBufferList, channelCount, frameCount);
            bufferListPointChannelDataToBuffer(inputBufferList, base->_inputBuffer);

            // Pull input into _inputBuffer.
            AudioUnitRenderActionFlags flags = 0;
            AUAudioUnitStatus status = pullInputBlock(&flags, timestamp, frameCount, 0, inputBufferList);
            if (status) return status;
        }

        // If outputBufferList has null data, point to valid buffer before processing.
        if (bufferListHasNullData(outputBufferList))
        {
            float *buffer = base->_ouputBuffer ?: base->_inputBuffer;
            bufferListPointChannelDataToBuffer(outputBufferList, buffer);
        }

        if (base->_shouldClearOutputBuffer)
        {
            clearBufferList(outputBufferList);
        }

        base->_processEventsBlock(inputBufferList, outputBufferList, timestamp, frameCount, realtimeEventListHead);
        
        return noErr;
    };
}

-(AUAudioUnitBusArray *)inputBusses
{
    return _inputBusArray;
}

-(AUAudioUnitBusArray *)outputBusses
{
    return _outputBusArray;
}

@end

static void prepareBufferList(AudioBufferList *audioBufferList,
                              int channelCount,
                              int frameCount)
{
    audioBufferList->mNumberBuffers = channelCount;
    for (int channelIndex = 0; channelIndex < channelCount; channelIndex++)
    {
        audioBufferList->mBuffers[channelIndex].mNumberChannels = 1;
        audioBufferList->mBuffers[channelIndex].mDataByteSize = frameCount * sizeof(float);
    }
}

static void clearBufferList(AudioBufferList *audioBufferList)
{
    for (int i = 0; i < audioBufferList->mNumberBuffers; i++)
    {
        memset(audioBufferList->mBuffers[i].mData, 0, audioBufferList->mBuffers[i].mDataByteSize);
    }
}

static size_t bufferListByteSize(int channelCount)
{
    return sizeof(AudioBufferList) + (sizeof(AudioBuffer) * (channelCount - 1));
}

static Boolean bufferListHasNullData(AudioBufferList *bufferList)
{
    return bufferList->mBuffers[0].mData == NULL;
}

static void bufferListPointChannelDataToBuffer(AudioBufferList *bufferList, float *buffer)
{
    int frameCount = bufferList->mBuffers[0].mDataByteSize / sizeof(float);
    for (int channelIndex = 0; channelIndex < bufferList->mNumberBuffers; channelIndex++)
    {
        int offset = channelIndex * frameCount;
        bufferList->mBuffers[channelIndex].mData = buffer + offset;
    }
}

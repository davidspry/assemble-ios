//  Assemble
//  ============================
//  Original author: Andrew Voelkel.
//  Copyright 2018 AudioKit. All rights reserved.
//  License: <https://github.com/AudioKit/AudioKit/blob/master/LICENSE>

#import "ASAudioUnit.h"

@implementation ASAudioUnit

- (ASDSPBase *)kernel
{
    return (ASDSPBase *)_dsp;
}

- (ASDSPRef)initDSPWithSampleRate:(double)sampleRate channelCount:(AVAudioChannelCount)count
{
    return (_dsp = NULL);
}

@synthesize parameterTree = _parameterTree;

- (AUValue)parameterWithAddress:(AUParameterAddress)address
{
    return self.kernel->getParameter(address);
}

- (void)setParameterWithAddress:(AUParameterAddress)address value:(AUValue)value
{
    self.kernel->setParameter(address, value);
}

- (void)setParameterImmediatelyWithAddress:(AUParameterAddress)address value:(AUValue)value
{
    self.kernel->setParameter(address, value, true);
}

- (BOOL)isPlaying
{
    return self.kernel->isPlaying();
}

- (void)setParameterTree:(AUParameterTree *)tree
{
    _parameterTree = tree;

    __block ASDSPBase *kernel = self.kernel;

    _parameterTree.implementorValueObserver = ^(AUParameter *param, AUValue value)
    {
        kernel->setParameter(param.address, value);
    };

    _parameterTree.implementorValueProvider = ^(AUParameter *param)
    {
        return kernel->getParameter(param.address);
    };

    _parameterTree.implementorStringFromValueCallback = ^(AUParameter *param, const AUValue *__nullable valuePtr)
    {
        AUValue value = valuePtr == nil ? param.value : *valuePtr;
        return [NSString stringWithFormat:@"%.2f", value];
    };
}

- (instancetype)initWithComponentDescription:(AudioComponentDescription)componentDescription
                                     options:(AudioComponentInstantiationOptions)options
                                       error:(NSError **)outError
{
    self = [super initWithComponentDescription:componentDescription options:options error:outError];
    
    if (self == nil) return nil;

    AVAudioFormat *format = [[AVAudioFormat alloc] initStandardFormatWithSampleRate:48000 channels:2];

    _dsp = [self initDSPWithSampleRate:format.sampleRate channelCount:format.channelCount];

    _parameterTree = [AUParameterTree createTreeWithChildren:@[]];

    return self;
}

- (BOOL)allocateRenderResourcesAndReturnError:(NSError **)outError
{
    if (![super allocateRenderResourcesAndReturnError:outError])
        return NO;

    AVAudioFormat *format = self.outputBusses[0].format;
    self.kernel->init(format.channelCount, format.sampleRate);

    return YES;
}

- (ProcessEventsBlock)processEventsBlock:(AVAudioFormat *)format
{
    __block ASDSPBase * kernel = self.kernel;
    
    return ^(AudioBufferList *input,
             AudioBufferList *output,
             const AudioTimeStamp *timestamp,
             AVAudioFrameCount frameCount,
             const AURenderEvent *eventListHead)
    {
        kernel->setBuffers(input, output);
        kernel->processWithEvents(timestamp, frameCount, eventListHead);
    };
}

- (void)deallocateRenderResources
{
    [super deallocateRenderResources];
}

- (BOOL)canProcessInPlace
{
    return NO;
}

- (void)dealloc
{
    delete self.kernel;
}

@end

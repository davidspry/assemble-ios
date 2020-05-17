//  Assemble
//  ============================
//  Original author: Dave O'Neill.
//  Copyright 2018 AudioKit. All rights reserved.
//  License: <https://github.com/AudioKit/AudioKit/blob/master/LICENSE>

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^ProcessEventsBlock)(AudioBufferList * _Nullable IBuffer,
                                  AudioBufferList * _Nonnull  OBuffer,
                                  const AudioTimeStamp * _Nonnull  timestamp,
                                  AVAudioFrameCount                frameCount,
                                  const AURenderEvent  * _Nullable eventsListHead);

@interface ASAudioUnitBase : AUAudioUnit

/// A processing callback to be defined by subclasses
-(ProcessEventsBlock)processEventsBlock:(AVAudioFormat *)format;

/// An input bus should be allocated. True by default.
-(BOOL)shouldAllocateInputBus;

/// Output buffer samples should be set to zero prior to rendering. False by default.
-(BOOL)shouldClearOutputBuffer;

@end

NS_ASSUME_NONNULL_END

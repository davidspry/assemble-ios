//  Assemble
//  ============================
//  Original author: Andrew Voelkel.
//  Copyright 2018 AudioKit. All rights reserved.
//  License: <https://github.com/AudioKit/AudioKit/blob/master/LICENSE>

#pragma once

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import "ASAudioUnitBase.h"
#import "ASDSPBase.hpp"
#import "ASInteroperability.h"

@interface ASAudioUnit : ASAudioUnitBase

@property (readonly) ASDSPRef _Nonnull dsp;

- (ASDSPRef _Nonnull)initDSPWithSampleRate:(double)sampleRate channelCount:(AVAudioChannelCount)count;

- (void)setParameterTree:(AUParameterTree *_Nullable)tree;

- (AUValue)parameterWithAddress:(AUParameterAddress)address;
- (void)setParameterWithAddress:(AUParameterAddress)address value:(AUValue)value;
- (void)setParameterImmediatelyWithAddress:(AUParameterAddress)address value:(AUValue)value;

- (void)start;
- (void)stop;
- (void)clear;

@property (readonly) BOOL isPlaying;
@property (readonly) BOOL isSetUp;

@end

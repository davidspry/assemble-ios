//  Assemble
//  ============================
//  Modified by: David Spry.
//  Original author: Shane Dunne.
//  Copyright 2018 AudioKit. All rights reserved.
//  License: <https://github.com/AudioKit/AudioKit/blob/master/LICENSE>

#pragma once

#import <AVFoundation/AVFoundation.h>

// ============================================================ //
// ============ Swift interface to ASCommanderDSP ============= //
// ============================================================ //

#ifndef __cplusplus

ASDSPRef makeASCommanderDSP(int channels, double sampleRate);
void __interop__LoadNote(ASDSPRef, const int note, const int shape);
void __interop__WriteNote(ASDSPRef, const int x, const int y, const int note, const int shape);
void __interop__EraseNote(ASDSPRef, const int x, const int y);
const bool __interop__PlayOrPause(ASDSPRef);

#else

// ============================================================ //

#include "ASDSPBase.hpp"
#include "ASCommanderCore.hpp"

struct ASCommanderDSP : ASDSPBase, ASCommanderCore
{
    ASCommanderDSP() : ASCommanderCore() {}
    
    void init(int channelCount, double sampleRate) override;
    
    bool isPlaying() override;

    float getParameter(uint64_t address) override;
    
    void setParameter(uint64_t address, float value, bool immediate) override;
    
    void process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) override;
};

#endif

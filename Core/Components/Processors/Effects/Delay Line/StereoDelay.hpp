//  Assemble
//  ============================
//  Created by David Spry on 25/4/20.
//  Copyright © 2020 David Spry. All rights reserved.

#ifndef STEREODELAY_H
#define STEREODELAY_H

#include "Delay.hpp"
#include "ASHeaders.h"
#include "ASParameters.h"

class StereoDelay
{
public:
    StereoDelay(Clock *clock) :
    ldelay(clock),
    rdelay(clock)
    {
        ldelay.set(1.F);
        rdelay.set(1.F);
        inject(offsetInMs, static_cast<bool>(0));
    }

public:
    inline const float process(const float sample, const bool left)
    { return left ? ldelay.process(sample) : rdelay.process(sample); }
    
public:
    const float get(uint64_t parameter);
    void set(uint64_t parameter, const float value);
    void set(float time, const bool left) { left ? ldelay.set(time) : rdelay.set(time); }

public:
    void cycleDelayTime(const bool shorter, const bool left)
    { left ? ldelay.cycleDelayTime(shorter) : rdelay.cycleDelayTime(shorter); }
    
    void inject(int milliseconds, const bool left)
    { left ? ldelay.inject(milliseconds) : rdelay.inject(milliseconds); }

private:
    Delay ldelay;
    Delay rdelay;
    
private:
    std::atomic<bool> bypassed = {false};
    std::atomic<float> offsetInMs = 4.F;
    
};

#endif

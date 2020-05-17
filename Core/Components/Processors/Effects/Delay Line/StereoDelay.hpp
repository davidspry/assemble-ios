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
        inject(offsetInMs, static_cast<bool>(0));
    }

public:
    inline void process(float & lsample, float & rsample)
    {
        ldelay.process(lsample);
        rdelay.process(rsample);
    }
    
public:
    const float get(uint64_t parameter);
    void set(uint64_t parameter, const float value);
    void set(float time, const bool left) { left ? ldelay.setInMusicalTime(time) : rdelay.setInMusicalTime(time); }

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

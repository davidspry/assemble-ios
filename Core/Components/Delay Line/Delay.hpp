//  Delay.hpp
//  Assemble
//  Created by David Spry on 24/4/20.
//  Copyright © 2020 David Spry. All rights reserved.

#ifndef DELAY_HPP
#define DELAY_HPP

#include "ASHeaders.h"
#include "ASUtilities.h"
#include "ASParameters.h"
#include "Clock.hpp"

// TODO: Add static sine wavetable to codebase
// TODO: Add modulation by looking up the sine wavetable

class Delay
{
public:
    Delay(Clock *clock);
    
public:
    const float process(const float sample);
    
public:
    /// \brief Set the delay time in milliseconds
    /// \param time The duration of the delay time in milliseconds
    inline void set(int time)
    {
        target = Assemble::Utilities::samples(time, clock->sampleRate);
        target = target + offsetInSamples;
    }
    
    /// \brief Set the delay time as a factor of musical time
    /// \param time A factor of musical time, such as 0.5, 1.0, or 2.5.
    inline void set(float time)
    {
        this->time = time;
        target = clock->sampleRate * 60 / clock->bpm * time;
        target = target + offsetInSamples;
    }
    
public:
    const float get(uint64_t parameter);
    void set(uint64_t parameter, float value);
    void inject(int milliseconds);
    void cycleDelayTime(const bool shorter);
    const float parseMusicalTimeParameterIndex(const int index);

public:
    inline bool toggle()  { return (bypassed = !bypassed); }
    inline void fadeIn()  { gain = std::min(1.F, gain + 0.001F); }
    inline void fadeOut() { gain = std::max(0.F, gain - 0.001F); }

private:
    inline void update()  { set(time); }
    
private:
    int   whead;
    float rhead;

private:
    int offsetInSamples = 0;
    float delay, target;
    float gain = 1.F;
    float feedback = 0.85F;
    std::atomic<bool> bypassed = {false};

private:
    int capacity;
    std::vector<float> samples;

private:
    Clock *clock;
    uint16_t bpm;
    float time;
};

#endif

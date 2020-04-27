//  Assemble
//  Created by David Spry on 20/4/20.
//  Copyright © 2020 David Spry. All rights reserved.

#ifndef CLOCK_HPP
#define CLOCK_HPP

#include "ASHeaders.h"
#include "ASParameters.h"
#include "ASUtilities.h"

class Clock
{
public:
    Clock(int tempo);
    
public:
    const float get(uint64_t parameter);
    void set(uint64_t parameter, float value);

public:
    void setSampleRate(const float sampleRate);
    
    /// \brief This is called by the Commander class when the
    /// sequencer is about to resume playback. It ensures that the
    /// first 'tick' occurs immediately upon playback.

    inline void prepare() { time = tick - 1; }
    
    /// \brief Subdivide the BPM

    inline void setSubdivision(uint8_t subdivision);
    
    /// \brief Set a new BPM target for the Clock's ValueTransition
    /// and compute the duration of a tick in samples.

    inline void setBPM(int tempo)
    {
        bpm = std::max(0, tempo);
        valueTransition.set(bpm);
        update();
    }
    
    /// \brief Advance the clock by one sample.
    /// \return True if the clock ticked during the advance; False otherwise.

    inline const bool advance()
    {
        if ((++time) >= tick)
        {
            time = 0;
            return true;
        }

        if (!valueTransition.complete()) {
            bpm = valueTransition.get();
            update();
        }
        
        return false;
    }

public:
    inline const bool isTicking()   { return ticking; }
    inline const bool playOrPause() { return (ticking = !ticking); }

private:
    inline void update() { tick = sampleRate * 60 / bpm / subdivision; }

private:
    bool  ticking = false;
    float sampleRate = 48000.F;

private:
    uint16_t bpm = 140;
    uint8_t  subdivision = 4;
    uint32_t tick;
    uint32_t time;
    
private:
    ValueTransition valueTransition = {140.0F, 140.0F, 0.5F};
    
friend class Delay;
};

#endif

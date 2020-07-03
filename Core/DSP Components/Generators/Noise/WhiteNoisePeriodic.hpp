//  Assemble
//  Created by David Spry on 2/6/20.
//  Copyright © 2020 David Spry. All rights reserved.

#ifndef WHITENOISEGENERATOR_HPP
#define WHITENOISEGENERATOR_HPP

#include "ASHeaders.h"
#include "WhiteNoise.hpp"

/// \brief Generate white noise periodically

class WhiteNoisePeriodic
{
public:
    void setSampleRate(const float sampleRate)
    {
        if (this->sampleRate != sampleRate)
            this->sampleRate = sampleRate;
    }
    
    const float nextSample()
    {
        advance();

        if (amplitude > 0.0F)
            return noDenormals + scalar * amplitude * noise.nextSample();

        return 0.F;
    }
    
private:
    inline void advance()
    {
        time = time + 1;
        if (time >= sampleRate)
        {
            time = 0;
            seconds = seconds + 1;
        }
        
        if ((silent && seconds >= silence) ||
           (!silent && seconds >= audible))
        {
            seconds = 0;
            silent = !silent;
        }

        if (!silent) amplitude = std::fmin(1.0F, amplitude + 1E-5F);
        else         amplitude = std::fmax(0.0F, amplitude - 1E-5F);
    }

private:
    int time;
    int seconds;
    float scalar = 2E-2F;
    constexpr static int audible = 10;
    constexpr static int silence = 60;
    constexpr static float noDenormals = 1E-25F;

private:
    bool silent = false;
    float amplitude  = 0.F;
    float sampleRate = 48000.F;

private:
    WhiteNoise noise;
};

#endif

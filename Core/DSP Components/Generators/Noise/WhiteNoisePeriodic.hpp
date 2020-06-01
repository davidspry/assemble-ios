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
            return amplitude * noise.nextSample();

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

        if (!silent) amplitude = std::fmin(0.55F, amplitude + 1E-7F);
        else         amplitude = std::fmax(0.00F, amplitude - 1E-7F);
    }

private:
    int time;
    int seconds;
    const int audible = 20;
    const int silence = 120;

private:
    bool silent = false;
    float amplitude  = 0.F;
    float sampleRate = 48000.F;

private:
    WhiteNoise noise;
};

#endif

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
    /// \brief Get the parameter values of the WhiteNoisePeriodic device.
    /// \param parameter The hexadecimal address of the desired parameter

    const float get(uint64_t parameter)
    {
        if (parameter == kIAPToggle001)
            return static_cast<float>(bypassed);
        
        return 0.0F;
    }

    /// \brief Set the parameters of the WhiteNoisePeriodic device.
    /// \param parameter The hexadecimal address of the parameter to set
    /// \param value The value to set for the parameter

    void set(uint64_t parameter, float value)
    {
        if (parameter == kIAPToggle001)
            bypassed = static_cast<bool>(value);
    }
    
    void setSampleRate(const float sampleRate)
    {
        if (this->sampleRate != sampleRate)
            this->sampleRate = sampleRate;
    }
    
    const float nextSample()
    {
        advance();

        if (!(bypassed) && amplitude > 0.0F)
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

        if (!silent) amplitude = std::fmin(1.0F, amplitude + 5E-6F);
        else         amplitude = std::fmax(0.0F, amplitude - 5E-6F);
    }

private:
    int time;
    int seconds;
    float scalar = 15E-3F;
    constexpr static int audible = 15;
    constexpr static int silence = 60;
    constexpr static float noDenormals = 1E-25F;

private:
    bool silent = true;
    bool bypassed = false;
    float amplitude  = 0.F;
    float sampleRate = 48000.F;

private:
    WhiteNoise noise;
};

#endif

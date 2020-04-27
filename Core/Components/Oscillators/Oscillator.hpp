//  Assemble
//  ============================
//  Created by David Spry on 3/2/20.

#ifndef OSCILLATOR_HPP
#define OSCILLATOR_HPP

#include <stdio.h>
#include <random>

class Oscillator
{
public:
    Oscillator()
    {
        std::uniform_real_distribution<float>::param_type range(-1.F, 1.F);
        twister.seed(rd());
        distribution.param(range);
    }

    virtual const float nextSample() = 0;

    /// \brief Begin oscillating at a new frequency.
    /// The phase is randomised whenever it is initialised to a new frequency
    /// in order to simulate an always-running analog oscillator. The randomisation
    /// step takes about 400 nanoseconds to compute, which is likely preferable
    /// to incrementing the phase of each oscillator continually and will achieve
    /// a similar effect.
    /// \param frequency The frequency, in Hz, to load in the oscillator

    virtual void load(const float frequency)
    {
        phase = distribution(twister);
        translation = frequency / sampleRate;
    }
    
private:
    std::mt19937 twister;
    std::random_device rd;
    std::uniform_real_distribution<float> distribution;

public:
    /// \brief Set the sample rate of the oscillator.
    /// \param sampleRate The sample rate of the oscillator.
    
    void setSampleRate(float sampleRate) {
        this->sampleRate = sampleRate;
    }

protected:
    float phase = 0.F;
    float translation = 0.F;
    float sampleRate  = 48000.F;
};

#endif

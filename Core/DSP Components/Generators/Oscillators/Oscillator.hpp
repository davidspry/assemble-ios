//  Assemble
//  ============================
//  Created by David Spry on 3/2/20.

#ifndef OSCILLATOR_HPP
#define OSCILLATOR_HPP

#include <random>

class Oscillator
{
public:
    /// \brief Initialise an Oscillator capable of randomising its phase within the range [0, 1].
    
    Oscillator()
    {
        std::uniform_real_distribution<float>::param_type range(0.F, 1.F);
        distribution.param(range);
        twister.seed(rd());
    }

    /// \brief Compute the next sample.

    virtual inline const float nextSample() noexcept = 0;

    /// \brief Begin oscillating at a new frequency.
    /// The phase is randomised whenever it is initialised to a new frequency
    /// in order to simulate an always-running analog oscillator. The randomisation
    /// step takes about 400 nanoseconds to compute, which is likely preferable
    /// to incrementing the phase of each oscillator continually and will achieve
    /// a similar effect.
    ///
    /// \param frequency The frequency, in Hz, to load in the oscillator

    virtual void load(const float frequency)
    {
        phase = distribution(twister);
        translation = frequency / sampleRate;
    }
    
    /// \brief Update the frequency of the oscillator without randomising the phase
    /// This should be used if a series of successive, incremental updates are required,
    /// as in a gradual change between two frequencies (portamento).
    ///
    /// \param frequency The frequency, in Hz, to load in the oscillator

    virtual void update(const float frequency)
    {
        translation = frequency / sampleRate;
    }
    
protected:
    std::mt19937 twister;
    std::random_device rd;
    std::uniform_real_distribution<float> distribution;

public:
    /// \brief Set the sample rate of the oscillator.
    /// \param sampleRate The sample rate of the oscillator.
    
    virtual void setSampleRate(const float sampleRate) {
        Oscillator::sampleRate = sampleRate;
    }

protected:
    float phase = 0.F;
    float translation = 0.F;
    static inline float sampleRate = 48000.F;
};

#endif

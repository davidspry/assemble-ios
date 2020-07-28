//  Assemble
//  Created by David Spry on 24/4/20.
//  Copyright © 2020 David Spry. All rights reserved.

#ifndef DELAY_HPP
#define DELAY_HPP

#include "ASHeaders.h"
#include "ASUtilities.h"
#include "ASConstants.h"
#include "ASParameters.h"
#include "ASOscillators.h"
#include "Clock.hpp"

/// \brief A simple delay line with feedback that uses interpolation in order to smoothly vary between delay lengths.

class Delay
{
public:
    /// \brief Initialise the Delay with a Clock who should define the tempo of the Delay

    Delay(Clock *clock);

    /// \brief Consume a new sample and return the next sample
    /// \param sample The sample to consume

    void process(float& sample);
    
    /// \brief Set the delay time in milliseconds
    /// \param time The duration of the delay time in milliseconds
    
    inline void setInMilliseconds(int time)
    {
        const float sampleRate = clock->sampleRate * (float) OVERSAMPLING;
        const float target = Assemble::Utilities::samples(time, sampleRate) + offsetInSamples;
        delay.set(target);
    }
    
    /// \brief Set the delay time as a factor of musical time
    /// \param time A factor of musical time, such as 0.5, 1.0, or 2.5.

    inline void setInMusicalTime(float time)
    {
        this->time = time;
        this->bpm  = clock->bpm;
        const float target = clock->sampleRate * (float) OVERSAMPLING * 60 / bpm * time;
        delay.set(target + offsetInSamples);
    }

    /// \brief Get a parameter value from the Delay
    /// \param parameter The hexadecimal address of the desired parameter

    const float get(uint64_t parameter);
    
    /// \brief Set a parameter value for the Delay
    /// \param parameter The hexadecimal address of the target parameter
    /// \param value The value to set for the given parameter

    void set(uint64_t parameter, float value);
    
    /// \brief Inject a delay of the given number of milliseconds into the target delay
    /// \param milliseconds The number of milliseconds to inject

    void inject(int milliseconds);

    /// \brief Given an index, return the corresponding musical time factor.
    /// \note Indices are expected to reach this function as a parameter value via the parameter system.
    /// \param index The index whose corresponding musical time factor is being requested.
    /// \returns A musical time factor, such as 1.0f or 0.5f, which is used to set the delay time.

    const float parseMusicalTimeParameterIndex(const int index);

    /// \brief Set the state of the Delay to `status`, where status represents
    /// whether or not the Delay should consume new samples from its input.
    /// \param status A flag to indicate whether the Delay should be bypassed or not.

    inline bool toggle(const bool status)
    {
        return !(bypassed = !status);
    }

    /// \brief  Reduce the input gain of the Delay to 0 gradually
    /// \note   The pseudo-sinusoidal function f(x) = -(x^2 - 1.0)^2 + 1.0 is used to compute the gain.
    /// \pre    `gainLinear` must be in [0, 1]
    /// \author Frederick
    /// <https://www.musicdsp.org/en/latest/Other/166-cheap-pseudo-sinusoidal-lfo.html>

    inline void fadeOut() {
        if (gainLinear == 0.F) return;
        gainLinear = std::max(0.F, gainLinear - taper);
        gain = -(std::powf((std::powf(gainLinear, 2.F) - 1.F), 2.F)) + 1.F;
    }
    
    /// \brief  Increase the input gain of the Delay to 1 gradually
    /// \note   The pseudo-sinusoidal function f(x) = -(x^2 - 1.0)^2 + 1.0 is used to compute the gain.
    /// \pre    `gainLinear` must be in [0, 1]
    /// \author Frederick
    /// <https://www.musicdsp.org/en/latest/Other/166-cheap-pseudo-sinusoidal-lfo.html>

    inline void  fadeIn() {
        if (gainLinear == 1.F) return;
        gainLinear = std::min(1.F, gainLinear + taper);
        gain = -(std::powf((std::powf(gainLinear, 2.F) - 1.F), 2.F)) + 1.F;
    }

private:
    /// \brief Synchronise the Delay with its Clock's tempo

    inline void update() { setInMusicalTime(time); }

private:
    /// \brief The writehead as an array index
    
    int   whead;
    
    /// \brief The readhead as an array index

    float rhead;

private:
    int timeTargetIndex;
    int offsetInSamples = 0;

private:
    float gain       = 1.00F;
    float gainLinear = 1.00F;
    std::atomic<float> mix      = 0.25F;
    std::atomic<float> feedback = 0.55F;
    std::atomic<bool>  bypassed = {false};

private:
    constexpr static float taper = 1E-4F * (1.0F / (float) OVERSAMPLING);
    constexpr static float speed = 5E-5F * (1.0F / (float) OVERSAMPLING);

private:
    /// @brief The capacity of the delay buffer in samples.
    
    int capacity;

    /// @brief The delay buffer.
    
    std::vector<float> samples;

private:
    /// @brief The current tempo of the delay.
    
    uint16_t bpm;
    
    /// @brief The delay's current musical time factor.
    
    float time;
    
    /// @brief The delay's clock source.
    
    Clock * clock;
    
private:
    /// @brief The delay between the write head and the read head in samples.
    
    ValueTransition delay = {1E3F, 96E3F, 2.0F};
    
    /// @brief The modulation depth in [1, 2]. This range should be normalised to [0, 1] when interfacing with external classes.
   
    ValueTransition modulation = {1.0F, 1.0F, 1.00F};
    
private:
    /// @brief The factor to scale the depth of the delay modulation effect.
    
    constexpr static float scalar = 512.0F;
    
    /// @brief The frequency of the delay modulation, scaled by the oversampling factor.
    
    constexpr static float modulationRate = 2.0F * (1.0F / (float) OVERSAMPLING);
    
    /// @brief A sine wavetable oscillator to smoothly modulate the delay's read position.
    
    BandlimitedOscillator<SIN>  modulator = {modulationRate};
};

#endif

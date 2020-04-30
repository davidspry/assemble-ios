//  Delay.hpp
//  Assemble
//  Created by David Spry on 24/4/20.
//  Copyright © 2020 David Spry. All rights reserved.

#ifndef DELAY_HPP
#define DELAY_HPP

#include "ASHeaders.h"
#include "ASUtilities.h"
#include "ASParameters.h"
#include "ASOscillators.h"
#include "Clock.hpp"

class Delay
{
public:
    Delay(Clock *clock);
    
public:
    /// \brief Consume a new sample and return the next sample
    /// \param sample The sample to consume

    const float process(const float sample);
    
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
    
    /// \brief Select the next musical delay time factor from a list of delay times.
    /// \param shorter True if the delay time should become shorter, or false otherwise.

    void cycleDelayTime(const bool shorter);
    
    /// \brief Set the speed of the readhead position modulator, which is a sine oscillator.
    /// The default speed is 4Hz, or 4.0f. The domain of acceptable inputs is [0.1f, 25.f].
    /// \param speed The target speed, in Hz, for the modulator.
    
    void setModulationSpeed(float speed)
    {
        const float frequency = Assemble::Utilities::bound(speed, 0.1F, 25.F);
        modulator.load(frequency);
    }

private:
    /// \brief Given an index, return the corresponding musical time factor.
    /// \note Indices are expected to reach this function as a parameter value via the parameter system.
    /// \param index The index whose corresponding musical time factor is being requested.
    /// \returns A musical time factor, such as 1.0f or 0.5f, which is used to set the delay time.

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
    float delay;
    float target;

private:
    float mix      = 0.25F;
    float gain     = 1.00F;
    float feedback = 0.65F;
    float modulationSpeed = 10.0F;
    float modulationDepth = 0.50F;
    std::atomic<bool> bypassed = {false};

private:
    int capacity;
    std::vector<float> samples;

private:
    uint16_t bpm;
    float time;
    Clock *clock;
    SineWTOscillator modulator = {10.00F};
};

#endif

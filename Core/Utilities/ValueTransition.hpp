//  Assemble
//  Created by David Spry on 27/4/20.
//  Copyright © 2020 David Spry. All rights reserved.

#ifndef VALUETRANSITION_HPP
#define VALUETRANSITION_HPP

#include "ASHeaders.h"

/// @brief An object representing a value transitioning smoothly between a source and target over a specified number of samples.

class ValueTransition
{
public:
    ValueTransition()
    { set(0.1F, 1.0F, 1.0F); }
    
    ValueTransition(float target, float timeInSeconds)
    { set(target, timeInSeconds); }
    
    ValueTransition(float value, float target, float timeInSeconds)
    { set(value, target, timeInSeconds); }

public:
    const float get();
    
    void set(float target);
    
    void set(float target, float timeInSeconds) noexcept;
    
    void set(float value, float target, float timeinSeconds) noexcept;
    
    void setSampleRate(const float sampleRate);

    [[nodiscard]] inline const float getTarget() const noexcept
    {
        return (float) target;
    }

    [[nodiscard]] inline const bool complete() const noexcept
    {
        return timeInSamples <= 0;
    }

private:
    /// @author ROLI Ltd.
    /// =================================================================================
    /// @brief Compute the step that `value` should be multiplied by in order to reach `target` in `time` samples.
    /// Given positive values `target`, `value`, and `time`, this is given by: e ** [ (ln(target) - ln(value)) / time ]
    /// Now multipying `value` by `delta` `time` times will produce `target`.
    /// =================================================================================
    /// ISC licence and source: "juce_SmoothedValue.h" in:
    /// <https://github.com/juce-framework/JUCE/>
    /// =================================================================================
    void computeDelta()
    {
        delta = std::exp((std::log(target) - std::log(value)) / timeInSamples);
    }

private:
    std::atomic<double> target = 0.F;
    std::atomic<double> value  = 0.F;
    std::atomic<double> delta  = 0.F;

private:
    float timeInSeconds = 1.00F;
    int   timeInSamples = 48000;
    float sampleRate = 48000.0F;
};

#endif

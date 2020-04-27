//  Assemble
//  Created by David Spry on 27/4/20.
//  Copyright © 2020 David Spry. All rights reserved.

#ifndef VALUETRANSITION_HPP
#define VALUETRANSITION_HPP

#include "ASHeaders.h"

class ValueTransition {
    
public:
    ValueTransition()
    { set(0.1F, 1.0F, 1.0F); }
    
    ValueTransition(float value, float target, float timeInSeconds)
    { set(value, target, timeInSeconds); }
    
public:
    const float get();
    void set(float target);
    void set(float target, float timeInSeconds) noexcept(false);
    void set(float value, float target, float timeinSeconds) noexcept(false);
    void setSampleRate(const float sampleRate);
    inline const bool complete() { return !(timeInSamples > 0); }
    
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
    float target = 0.F;
    float value = 0.F;
    float delta = 0.F;
    
private:
    float timeInSamples;
    float timeInSeconds = 1.0F;
    float sampleRate = 48000.0F;
};

#endif

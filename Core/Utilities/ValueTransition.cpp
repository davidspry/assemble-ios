//  Assemble
//  Created by David Spry on 27/4/20.
//  Copyright © 2020 David Spry. All rights reserved.

#include "ValueTransition.hpp"

const float ValueTransition::get()
{
    if (timeInSamples > 0)
    {
        timeInSamples = timeInSamples - 1;
        value *= delta;
        return value;
    }
    
    return target;
}

void ValueTransition::set(float target)
{
    set(value, target, timeInSeconds);
}

void ValueTransition::set(float target, float timeInSeconds) noexcept(false)
{
    set(value, target, timeInSeconds);
}

void ValueTransition::set(float value, float target, float timeInSeconds) noexcept(false)
{
    if (value <= 0.F) throw "The initial value cannot be less than or equal to 0.";
    if (target <= 0.F) throw "The target value cannot be less than or equal to 0.";
    
    if (timeInSeconds <= 0.F) timeInSeconds = 0.F;
    if (timeInSeconds == 0.F) this->value = target;
    else
    {
        this->value = value;
        this->target = target;
        this->timeInSeconds = timeInSeconds;
        this->timeInSamples = timeInSeconds * sampleRate;
        computeDelta();
    }
}

void ValueTransition::setSampleRate(const float sampleRate)
{
    if (this->sampleRate != sampleRate)
    {
        this->sampleRate = sampleRate;
        computeDelta();
    }
}

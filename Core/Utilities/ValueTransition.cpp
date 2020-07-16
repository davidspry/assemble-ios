//  Assemble
//  Created by David Spry on 27/4/20.
//  Copyright © 2020 David Spry. All rights reserved.

#include "ValueTransition.hpp"

const float ValueTransition::get()
{
    if (timeInSamples > 0) {
        timeInSamples = timeInSamples - 1;
        value = value * delta;
        return (float) value;
    }

    return (float) target;
}

void ValueTransition::set(float target)
{
    set(value, target, timeInSeconds);
}

void ValueTransition::set(float target, float timeInSeconds) noexcept
{
    set(value, target, timeInSeconds);
}

void ValueTransition::set(float value, float target, float timeInSeconds) noexcept
{
    value  = std::fmax(0.001F, value);
    target = std::fmax(0.001F, target);

    if (timeInSeconds <= 0.F) timeInSeconds = 0.F;
    if (timeInSeconds == 0.F) this->value = target;
    else
    {
        this->value = value;
        this->target = target;
        this->timeInSeconds = timeInSeconds;
        this->timeInSamples = (int) (timeInSeconds * sampleRate);
        computeDelta();
    }
}

void ValueTransition::setSampleRate(const float sampleRate)
{
    if (this->sampleRate != sampleRate)
    {
        this->sampleRate = sampleRate;
        set(value, target, timeInSeconds);
    }
}

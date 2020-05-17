//  Assemble
//  Created by David Spry on 27/4/20.
//  Copyright © 2020 David Spry. All rights reserved.

#include "Clock.hpp"

Clock::Clock(int tempo)
{
    bpm = std::max(1, tempo);
    update();
    time = tick;
}

/// \brief Get a parameter value from the Clock
/// \param parameter The hexadecimal address of the parameter to retrieve

const float Clock::get(uint64_t parameter)
{
    switch (parameter)
    {
        case kClockBPM: return (float) bpm;
        case kClockSubdivision: return (float) subdivision;
        default: return 0.0F;
    }
}

/// \brief Set a parameter on the Clock
/// \param parameter The hexadecimal address of the parameter to set
/// \param value The value to set for the given parameter

void Clock::set(uint64_t parameter, float value)
{
    switch (parameter)
    {
        case kClockBPM: setBPM(static_cast<int>(value)); return;
        case kClockSubdivision: setSubdivision(static_cast<int>(value)); return;
        default: return;
    }
}

void Clock::setSubdivision(uint8_t subdivision)
{
    this->subdivision = subdivision;
    update();
}


void Clock::setSampleRate(const float sampleRate)
{
   if (sampleRate != this->sampleRate)
       this->sampleRate = sampleRate;
}

//  Assemble
//  Created by David Spry on 28/4/20.
//  Copyright © 2020 David Spry. All rights reserved.

#include "SineWTOscillator.hpp"

SineWTOscillator::SineWTOscillator(const float frequency)
{
    load(frequency);
    computeTableDelta();
}

void SineWTOscillator::computeTableDelta()
{
    SineWTOscillator::tableDelta = tableSize / Oscillator::sampleRate;
}

void SineWTOscillator::load(const float frequency)
{
    translation = frequency * SineWTOscillator::tableDelta;
}

void SineWTOscillator::setSampleRate(const float sampleRate)
{
    Oscillator::sampleRate = sampleRate;
    computeTableDelta();
}

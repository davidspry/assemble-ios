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

inline const float SineWTOscillator::nextSample() noexcept
{
    using namespace Assemble::Utilities;
    const float sample = lerp(tableIndex, &wt_sine[0], tableSize);

    tableIndex = tableIndex + tableDelta;
    tableIndex = tableIndex - static_cast<int>(tableIndex >= tableSize) * tableSize;

    return sample;
}

void SineWTOscillator::setSampleRate(const float sampleRate)
{
    Oscillator::sampleRate = sampleRate;
    computeTableDelta();
}

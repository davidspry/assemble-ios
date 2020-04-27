//  Assemble
//  ============================
//  Created by David Spry on 3/2/20.

#include "SquareOscillator.hpp"

SquareOscillator::SquareOscillator() {}

SquareOscillator::SquareOscillator(float frequency)
{
    load(frequency);
}

const float SquareOscillator::nextSample()
{
    phase += translation;
    phase += (phase > 1.0F) * -1.0F;
    const int index = static_cast<int>(phase < 0.5F);
    return wavetable[index];
}

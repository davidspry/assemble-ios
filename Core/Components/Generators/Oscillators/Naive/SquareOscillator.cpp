//  Assemble
//  ============================
//  Created by David Spry on 3/2/20.

#include "SquareOscillator.hpp"

SquareOscillator::SquareOscillator(const float frequency)
{
    load(frequency);
}

inline const float SquareOscillator::nextSample() noexcept
{
    phase += translation;
    phase += static_cast<int>(phase >= 1.0F) * -1.0F;
    const int index = static_cast<int>(phase < 0.5F);
    return SquareOscillator::wavetable[index];
}

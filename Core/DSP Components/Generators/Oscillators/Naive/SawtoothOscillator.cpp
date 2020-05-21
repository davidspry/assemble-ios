//  Assemble
//  ============================
//  Created by David Spry on 3/2/20.

#include "SawtoothOscillator.hpp"

SawtoothOscillator::SawtoothOscillator(const float frequency)
{
    load(frequency);
}

const float SawtoothOscillator::nextSample() noexcept
{
    phase += translation;
    phase += static_cast<int>(phase >= 1.0F) * -1.0F;

    return phase * 2.0F - 1.0F;
}

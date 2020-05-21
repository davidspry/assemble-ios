//  Assemble
//  ============================
//  Created by David Spry on 3/2/20.

#include "SineOscillator.hpp"

SineOscillator::SineOscillator(const float frequency)
{
    load(frequency);
}

void SineOscillator::load(const float frequency)
{
    phase = distribution(twister);
    translation = TWO_PI * frequency / sampleRate;
}

inline const float SineOscillator::nextSample() noexcept
{
    phase += translation;
    phase += static_cast<int>(phase >= TWO_PI) * -TWO_PI;

    return std::sinf(phase);
}

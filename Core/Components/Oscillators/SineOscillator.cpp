//  Assemble
//  ============================
//  Created by David Spry on 3/2/20.

#include "SineOscillator.hpp"

SineOscillator::SineOscillator() {}

SineOscillator::SineOscillator(float frequency)
{
    load(frequency);
}

void SineOscillator::load(const float frequency)
{
    phase = phase - 0.75F;
    phase = phase + static_cast<int>(phase < -TWO_PI) * TWO_PI;
    translation = TWO_PI * frequency / sampleRate;
}

const float SineOscillator::nextSample()
{
    phase += translation;
    phase += static_cast<int>(phase >= TWO_PI) * -TWO_PI;

    return std::sinf(phase);
}

//  Assemble
//  ============================
//  Created by David Spry on 3/2/20.

#include "TriangleOscillator.hpp"

TriangleOscillator::TriangleOscillator(const float frequency)
{
    load(frequency);
}

inline const float TriangleOscillator::nextSample() noexcept
{
    float sample;
    phase += translation;
    phase += static_cast<int>(phase >= 1.0) * -1.0;

    sample = static_cast<int>(phase < 0.5) * (4.0 * phase - 1.0);
    sample = sample + static_cast<int>(phase >= 0.5) * (1.0 - 4.0 * (phase - 0.5));

    return sample;
}

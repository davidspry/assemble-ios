//  Assemble
//  ============================
//  Created by David Spry on 3/2/20.

#ifndef SQUAREOSCILLATOR_HPP
#define SQUAREOSCILLATOR_HPP

#include "Oscillator.hpp"
#include <array>

/// \author This oscillator is based on an oscillator written by Rob Clifton Harvey.
/// <https://github.com/rcliftonharvey/rchoscillators/>

class SquareOscillator : public Oscillator
{
public:
    SquareOscillator() {};
    SquareOscillator(const float);
    
public:
    const float nextSample() noexcept override;

private:
    constexpr const static std::array<float,2> wavetable = {-0.5, 0.5};
};

#endif

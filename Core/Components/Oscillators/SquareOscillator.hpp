//  Assemble
//  ============================
//  Created by David Spry on 3/2/20.

#ifndef SQUAREOSCILLATOR_HPP
#define SQUAREOSCILLATOR_HPP

#include "Oscillator.hpp"
#include <array>

/// \author Rob Clifton Harvey
/// This oscillator is based on an oscillator written by Rob Clifton Harvey.
/// <https://github.com/rcliftonharvey/rchoscillators/>

class SquareOscillator : public Oscillator
{
public:
    SquareOscillator();
    SquareOscillator(float);
    
public:
    const float nextSample() override;

private:
    std::array<float,2> wavetable = {-0.5, 0.5};
};

#endif

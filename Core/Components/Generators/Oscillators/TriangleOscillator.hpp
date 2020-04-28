//  Assemble
//  ============================
//  Created by David Spry on 3/2/20.

#ifndef TRIANGLEOSCILLATOR_HPP
#define TRIANGLEOSCILLATOR_HPP

#include "Oscillator.hpp"

/// \author This oscillator is based on an oscillator written by Rob Clifton Harvey.
/// <https://github.com/rcliftonharvey/rchoscillators/>

class TriangleOscillator : public Oscillator {

public:
    TriangleOscillator() {};
    TriangleOscillator(const float);
    
public:
    const float nextSample() noexcept override;
};

#endif

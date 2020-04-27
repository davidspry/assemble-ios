//  Assemble
//  ============================
//  Created by David Spry on 3/2/20.

#ifndef TRIANGLEOSCILLATOR_HPP
#define TRIANGLEOSCILLATOR_HPP

#include "Oscillator.hpp"

/// \author Rob Clifton Harvey
/// This oscillator is based on an oscillator written by Rob Clifton Harvey.
/// <https://github.com/rcliftonharvey/rchoscillators/>

class TriangleOscillator : public Oscillator {

public:
    TriangleOscillator();
    TriangleOscillator(float);
    
public:
    const float nextSample() override;

};

#endif

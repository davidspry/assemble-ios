//  Assemble
//  ============================
//  Created by David Spry on 3/2/20.

#ifndef SINEOSCILLATOR_HPP
#define SINEOSCILLATOR_HPP

#include "Oscillator.hpp"
#include "ASConstants.h"
#include <numeric>

/// \author Rob Clifton Harvey
/// This oscillator is based on an oscillator written by Rob Clifton Harvey.
/// <https://github.com/rcliftonharvey/rchoscillators/>

class SineOscillator : public Oscillator
{
public:
    SineOscillator();
    SineOscillator(float);
    
public:
    const float nextSample() override;
    void load(const float frequency) override;
};

#endif

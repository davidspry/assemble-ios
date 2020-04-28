//  Assemble
//  ============================
//  Created by David Spry on 3/2/20.

#ifndef SAWTOOTHOSCILLATOR_HPP
#define SAWTOOTHOSCILLATOR_HPP

#include "Oscillator.hpp"

/// \author This oscillator is based on an oscillator written by Rob Clifton Harvey.
/// <https://github.com/rcliftonharvey/rchoscillators/>

class SawtoothOscillator : public Oscillator {

public:
    SawtoothOscillator() {};
    SawtoothOscillator(const float);

public:
    const float nextSample() noexcept override;
};

#endif

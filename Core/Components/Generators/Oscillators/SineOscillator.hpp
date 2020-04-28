//  Assemble
//  ============================
//  Created by David Spry on 3/2/20.

#ifndef SINEOSCILLATOR_HPP
#define SINEOSCILLATOR_HPP

#include "Oscillator.hpp"
#include "ASConstants.h"
#include <numeric>

/// \author This oscillator is based on an oscillator written by Rob Clifton Harvey.
/// <https://github.com/rcliftonharvey/rchoscillators/>
/// \note ASConstants.h is required to access the TWO_PI constant.
/// \note The C++ Numeric module is required to access std::sinf

class SineOscillator : public Oscillator
{
public:
    SineOscillator() {};
    SineOscillator(const float);
    
public:
    const float nextSample() noexcept override;
    void load(const float frequency) override;
};

#endif

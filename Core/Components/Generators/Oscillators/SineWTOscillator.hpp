//  Assemble
//  Created by David Spry on 28/4/20.
//  Copyright © 2020 David Spry. All rights reserved.

//  Assemble
//  ============================
//  Created by David Spry on 3/2/20.

#ifndef SINEWTOSCILLATOR_HPP
#define SINEWTOSCILLATOR_HPP

#include "ASSineWaveTable.h"
#include "Oscillator.hpp"
#include "ASUtilities.h"
#include "ASConstants.h"

/// \brief A sine oscillator that interpolates from a static wavetable.
/// \author ROLI, Ltd.
/// \note This oscillator is based the JUCE tutorial 'Wavetable synthesis'.
/// \note Source: https://docs.juce.com/master/tutorial_wavetable_synth.html

class SineWTOscillator : public Oscillator
{
public:
    SineWTOscillator() { computeTableDelta(); }
    SineWTOscillator(const float frequency);

public:
    void load(const float frequency) override;
    void setSampleRate(const float sampleRate) override;
    
public:
    inline const float nextSample() noexcept override
    {
        using namespace Assemble::Utilities;
        const float sample = lerp(tableIndex, &wt_sine[0], tableSize);

        tableIndex = tableIndex + tableDelta;
        tableIndex = tableIndex - static_cast<int>(tableIndex >= tableSize) * tableSize;

        return sample;
    }

private:
    void computeTableDelta();
    
private:
    float tableIndex = 0.F;
    static inline float tableDelta;
    constexpr const static uint32_t tableSize = wt_sine.size();
};

#endif

//  Assemble
//  Created by David Spry on 28/4/20.
//  Copyright © 2020 David Spry. All rights reserved.

#ifndef SINEWTOSCILLATOR_HPP
#define SINEWTOSCILLATOR_HPP

#include "ASSineTable.h"
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
    SineWTOscillator(const float frequency)
    {
        load(frequency);
        computeTableDelta();
    }

public:
    /// \brief Set the frequency of the oscillator
    /// \param frequency The target frequency for the oscillator in Hz

    void load(const float frequency) override
    {
        translation = frequency * SineWTOscillator::tableDelta;
    }
    
    /// \brief Update the sample rate of the oscillator.
    /// \param sampleRate The updated sample rate in Hz.
    /// \note  The sample rate is 48kHz by default.

    void setSampleRate(const float sampleRate) override
    {
        Oscillator::sampleRate = sampleRate;
        computeTableDelta();
    }
    
public:
    inline const float nextSample() noexcept override
    {
        using namespace Assemble::Utilities;
        const float sample = lerp(tableIndex, &(wt_sine[0]), tableSize);

        tableIndex = tableIndex + translation;
        tableIndex = tableIndex - static_cast<int>(tableIndex >= tableSize) * tableSize;

        return sample;
    }

private:
    inline void computeTableDelta()
    {
        SineWTOscillator::tableDelta = (float) SineWTOscillator::tableSize / Oscillator::sampleRate;
    }
    
private:
    float tableIndex = 0.F;
    static inline float tableDelta;
    constexpr const static uint32_t tableSize = wt_sine.size();
};

#endif

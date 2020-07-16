//  Assemble
//  Created by David Spry on 10/5/20.
//  Copyright © 2020 David Spry. All rights reserved.

#ifndef BANDLIMITEDOSCILLATOR_HPP
#define BANDLIMITEDOSCILLATOR_HPP

#include "Oscillator.hpp"
#include "ASUtilities.h"
#include "WaveTable.hpp"

/// \brief An oscillator that interpolates from a collection of bandlimited wavetables.
/// \see   Wavetables are stored in `/Core/Utilities/Headers/Wavetables/`

template <WaveTableType W>
class BandlimitedOscillator : public Oscillator
{
public:
    BandlimitedOscillator() { }
    BandlimitedOscillator(const float frequency)
    {
        load(frequency);
    }
    
public:
    /// \brief Set the frequency of the oscillator
    /// \param frequency The target frequency in Hz

    void load(const float frequency) override
    {
        Oscillator::load(frequency);
        wavetable.select(frequency);
    }

    /// \brief Compute the next sample using linear interpolation

    inline const float nextSample() noexcept override
    {
        using namespace Assemble::Utilities;
        const float index  = static_cast<float>(wavetable.length()) * phase;
        const float sample = hermite(index, wavetable.table(), wavetable.length());

        phase += translation;
        phase += static_cast<int>(phase >= 1.0F) * -1.0F;

        return sample;
    }

private:
    WaveTable<W> wavetable;
};

#endif

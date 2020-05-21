//  Assemble
//  Created by David Spry on 20/4/20.
//  Copyright © 2020 David Spry. All rights reserved.

#ifndef SYNTHESISER_HPP
#define SYNTHESISER_HPP

#include "ASHeaders.h"
#include "ASConstants.h"
#include "ASFrequencies.h"
#include "VoiceBank.hpp"

/// \brief A polyphonic synthesiser with four oscillator banks. Each oscillator bank is polyphonic.

class Synthesiser
{
public:
    Synthesiser() {}
    
public:
    /// \brief Poll each VoiceBank for its next sample

    const float nextSample();

    /// \brief Load a new note into the least recently used Voice whose oscillator
    /// matches the requested oscillator type.

    void loadNote(const int note, const int shape);
    
public:
    /// \brief Get the parameter values of the Synthesiser.
    /// \param parameter The hexadecimal address of the desired parameter

    const float get(uint64_t parameter);

    /// \brief Set the parameters of the Synthesiser.
    /// \param parameter The hexadecimal address of the parameter to set
    /// \param value The value to set for the parameter

    void set(uint64_t parameter, float value);

    /// \brief Set the sample rate of the Synthesiser.
    /// Any changes to the sample rate are propagated to underlying VoiceBanks.
    /// \param sampleRate The sample rate to set

    void setSampleRate(const float sampleRate);

private:
    VoiceBank<SIN, POLYPHONY> sin;
    VoiceBank<TRI, POLYPHONY> tri;
    VoiceBank<SQR, POLYPHONY> sqr;
    VoiceBank<SAW, POLYPHONY> saw;

private:
    float sampleRate = 48000.F;
};

#endif

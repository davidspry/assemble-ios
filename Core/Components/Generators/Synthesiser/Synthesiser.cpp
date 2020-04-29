//  Assemble
//  Created by David Spry on 20/4/20.
//  Copyright © 2020 David Spry. All rights reserved.

#include "Synthesiser.hpp"

/// \brief Initialise each Voice bank and ValueTransition object in the synthesiser.
/// Each Voice bank is assigned an Oscillator*, and each component is initialised with the
/// Synthesiser's sample rate.

Synthesiser::Synthesiser()
{
    for (int i = 0; i < OSCILLATORS; ++i)
    {
        nextVoice[i] = 0;
        for (int v = 0; v < POLYPHONY; ++v)
        {
            const int voice = i * POLYPHONY + v;
            switch (i) {
                case 0: voices[voice].osc = &sine[v]; break;
                case 1: voices[voice].osc = &triangle[v]; break;
                case 2: voices[voice].osc = &square[v]; break;
                case 3: voices[voice].osc = &sawtooth[v]; break;
            }
        }
    }
    
    for (auto &voice : voices)
        voice.setSampleRate(sampleRate);

    for (auto &vtrns : frequency)
    { vtrns.setSampleRate(sampleRate); vtrns.set(1.0F, 0.5F); }
    
    for (auto &vtrns : resonance)
    { vtrns.setSampleRate(sampleRate); vtrns.set(0.1F, 0.5F); }
}

/// \brief Load a new note into the least recently used Voice whose oscillator
/// matches the requested oscillator type.

void Synthesiser::loadNote(const int note, const int shape)
{
    const auto index = shape * POLYPHONY + nextVoice[shape];
    nextVoice[shape] = (nextVoice[shape] + 1) % POLYPHONY;
    const auto frequency = frequencies[note];
    voices[index].load(frequency);
}

/// \brief Poll each ValueTransition for its next value, and poll each Voice for its next sample.
/// If a ValueTransition has not yet reached its target value, it will be used to set the filter of each
/// Voice in the matching bank.

const float Synthesiser::nextSample()
{
    float bank = 0.F;
    float sample = 0.F;
    const float delta = 1.F / POLYPHONY;

    for (auto &voice : voices)
    {
        const int osc = std::floor(bank);
        if (!frequency[osc].complete()) voice.set(kFrequencyType, frequency[osc].get());
        if (!resonance[osc].complete()) voice.set(kResonanceType, resonance[osc].get());
        sample += voice.nextSample();
        bank = bank + delta;
    }

    return sample * 0.0625F;
}

const float Synthesiser::get(uint64_t parameter)
{
    return 0.F;
}

/// \brief Set the parameters of the synhesiser, including its Voice banks and
/// its ValueTransition objects, which define smooth transitions between values
/// for each Voice's filter.
/// \param parameter The hexadecimal address of the parameter to set
/// \param value The value to set for the parameter

void Synthesiser::set(uint64_t parameter, float value)
{
    const int type = (int) parameter / (2 << 7);
    const int bank = (int) parameter / 16 % 16 - 1;
    switch (type)
    {
        /// \brief Set the parameters for each Voice's amplitude or
        /// filter envelope. These can contain new attack, hold, or release
        /// durations in milliseconds.

        case 0xAE:
        case 0xFE:
        {
            const int oscillator = POLYPHONY * bank;
            for (size_t v = 0; v < POLYPHONY; ++v)
                voices[oscillator + v].set(parameter, value);

            return;
        }

        /// \brief Set the parameters of the ValueTransition objects who
        /// define smooth transitions for each Voice's filter frequency and resonance.
        /// ValueTransitions cannot be set to 0, given their underlying function, so
        /// a small value is added to any parameter that is entered as a new target.

        case 0xF0:
        {
            const int subtype = (int) parameter % 16;
            if (subtype == 0) { frequency[bank].set(0.01F + value); return; }
            if (subtype == 1) { resonance[bank].set(0.01F + value); return; }
        }

        default: return;
    }
}

void Synthesiser::setSampleRate(const float sampleRate)
{
    const bool shouldUpdate = this->sampleRate != sampleRate;
    
    if (shouldUpdate)
    {
        this->sampleRate = sampleRate;
        for (auto &voice : voices)
            voice.setSampleRate(sampleRate);
    }
}

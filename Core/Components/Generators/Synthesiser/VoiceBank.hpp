//  Assemble
//  Created by David Spry on 20/5/20.
//  Copyright © 2020 David Spry. All rights reserved.

#ifndef OSCILLATORBANK_HPP
#define OSCILLATORBANK_HPP

#include "Voice.hpp"
#include "ASHeaders.h"
#include "ASUtilities.h"
#include "ASParameters.h"
#include "ASOscillators.h"

/// \brief A bank of Voices, which are each comprised of an oscillator, envelopes, and a lowpass filter.

template <WaveTableType W, int N>
class VoiceBank
{
public:
    /// \brief Initialise each Voice and ValueTransition object in the VoiceBank.
    /// Each Voice bank is assigned with an Oscillator*.

    VoiceBank()
    {
        for (size_t v = 0; v < N; ++v)
        {
            voices[v].assign(&(oscillators[v]));
        }
        
        frequency.set(0.75F, 1.0F);
        resonance.set(0.05F, 1.0F);
    }

public:
    /// \brief Load a note into the least recently used Voice

    void load(const float frequency)
    {
        voices.at(nextVoice).load(frequency);

        nextVoice = nextVoice + 1;
        nextVoice = nextVoice - static_cast<int>(nextVoice >= N) * N;
    }

    /// \brief Poll each Voice for its next sample, and poll each ValueTransition for its next value.
    /// \note  If a ValueTransition has not yet reached its target value, it will be used to set the filter of each Voice

    inline const float nextSample() noexcept
    {
        float sample = 0.0F;
        
        for (auto& voice : voices)
        {
            if (!frequency.complete()) voice.set(kFrequencyType, frequency.get());
            if (!resonance.complete()) voice.set(kResonanceType, resonance.get());

            sample += voice.nextSample();
        }

        return sample;
    }
    
public:
    /// \brief Set the sample rate of each Voice in the VoiceBank.
    /// \param sampleRate The sample rate to set.

    inline void setSampleRate(const float sampleRate)
    {
        for (auto& voice : voices)
            voice.setSampleRate(sampleRate);
    }
    
    /// \brief Get the parameter values of the VoiceBank.
    /// \param parameter The hexadecimal address of the desired parameter

    const float get(uint64_t parameter)
    {
        const int type = (int) parameter / (2 << 7);
        switch (type)
        {
            /// Get the amplitude or filter envelope values for the target Voice
                
            case 0xAE: // Fallthrough
            case 0xFE: // Fallthrough
            {
                return voices[0].get(parameter);
            }

            case 0xF0:
            {
                const int subtype = (int) parameter % 16;
                if (subtype == 0) { return frequency.getTarget(); }
                if (subtype == 1) { return resonance.getTarget(); }
            }
            
            default:
                return 0.0F;
        }
    }
    
    /// \brief Set the parameters of the Synthesiser.
    /// \param parameter The hexadecimal address of the parameter to set
    /// \param value The value to set for the parameter

    void set(uint64_t parameter, const float value)
    {
        const int type = (int) parameter / (2 << 7);
        switch (type)
        {
            /// \brief Set the parameters for each Voice's amplitude or
            /// filter envelope. These can contain new attack, hold, or release
            /// durations in milliseconds.

            case 0xAE:
            case 0xFE:
            {
                for (auto& voice : voices)
                    voice.set(parameter, value);

                return;
            }

            /// \brief Set the parameters of the ValueTransition objects who
            /// define smooth transitions for each Voice's filter frequency and resonance.
            /// ValueTransitions cannot be set to 0, given their underlying function, so
            /// a small value is added to any parameter that is entered as a new target.

            case 0xF0:
            {
                const int subtype = (int) parameter % 16;
                if (subtype == 0) { frequency.set(value); return; }
                if (subtype == 1) { resonance.set(value); return; }
            }

            default: return;
        }
    }

private:
    int nextVoice = 0;
    
private:
    ValueTransition frequency;
    ValueTransition resonance;
    
private:
    std::array<Voice, N>                    voices;
    std::array<BandlimitedOscillator<W>, N> oscillators;
};

#endif
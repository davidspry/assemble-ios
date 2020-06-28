//  Assemble
//  Created by David Spry on 9/4/20.
//  Copyright © 2020 David Spry. All rights reserved.

#include "ASCommanderCore.hpp"

void ASCommanderCore::init(double sampleRate)
{
    const float audioRate = static_cast<float>(sampleRate);
    const bool shouldUpdate = this->sampleRate != audioRate;
    this->sampleRate = audioRate;

    if (shouldUpdate)
    {
        synthesiser.setSampleRate(audioRate);
        clock.setSampleRate(audioRate);
        noise.setSampleRate(audioRate);
    }

    __state__.reserve(2048);
    printf("[ASCommanderCore] Initialising with sample rate %.0fHz\n", audioRate);
}

const bool ASCommanderCore::playOrPause()
{
    if (!clock.isTicking())
    {
        clock.prepare();
        sequencer.prepare();
    }
    else
        sequencer.reset();

    return clock.playOrPause();
}

void ASCommanderCore::set(uint64_t parameter, const float value)
{
    const int type    = (int) parameter / (2 << 7);

    switch (type)
    {
        /// \brief The parameter address types 0xAE, 0xFE, and 0xF0
        /// address the envelopes and filters. These requests are handled by
        /// the synthesiser.

        case 0xAE:
        case 0xFE:
        case 0xF0: return synthesiser.set(parameter, value);
        
        /// \brief The parameter address type 0xEF addresses an effect processor.
        /// An effect request must be directed to its destination, so the request's
        /// subtype must be checked:
        /// 0xEF0 (Delay); 0xEF1 (Stereo Delay); 0xEF2 (Vibrato)

        case 0xEF:
        {
            const int subtype = (int) parameter / (2 << 3) % 16;
            switch (subtype)
            {
                case 0:
                case 1: return delay.set(parameter, value);
                case 2: return vibrato.set(parameter, value);
            }
        }

        case 0xAA: return sequencer.set(parameter, value);
        case 0xCA: return clock.set(parameter, value);

        default: return;
    }
}

const float ASCommanderCore::get(uint64_t parameter)
{
    const int type = (int) parameter / (2 << 7);

    switch (type)
    {
        case 0xAA: return sequencer.get(parameter);
        case 0xCA: return clock.get(parameter);

        case 0xAE: // Fallthrough
        case 0xFE: // Fallthrough
        case 0xF0: return synthesiser.get(parameter);
        
        case 0xEF:
        {
            const int subtype = (int) parameter / (2 << 3) % 16;
            switch (subtype)
            {
                case 0: // Fallthrough
                case 1: return delay.get(parameter);
                case 2: return vibrato.get(parameter);
            }
        }

        default:   return 0.F;
    }
}

void ASCommanderCore::render(unsigned int channels, unsigned int sampleCount, float * output[])
{
    for (size_t t = 0; t < sampleCount; ++t)
    {
        if (clock.isTicking() && clock.advance())
        {
            const auto row = sequencer.nextRow();
            std::vector<Note>::iterator notes = row.second;
            for (size_t n = 0; n < row.first; ++n)
            {
                const auto note = *notes;
                loadNote(note.note, note.shape);
                std::advance(notes, 1);
            }
        }

        sample = {0.f, 0.f};
        sample[0] = synthesiser.nextSample();
        vibrato.process(sample[0]);
        sample[1] = sample[0];
        delay.process(sample[0], sample[1]);
        
//        ===============================================
//        NOTE: The following three lines add a periodic white noise
//        generator into the audio output. The addition of periodic
//        white noise will be a limitation in the free version of Assemble.
//        It will be unlockable via an in-app purchase in the final release.
//        ===============================================
//        const float whiteNoise = noise.nextSample();
//        sample[0] += whiteNoise;
//        sample[1] += whiteNoise;
//        ===============================================

        for (size_t c = 0; c < channels; c++)
            output[c][t] = sample[c & 1];
    }
}

void ASCommanderCore::loadFromEncodedPatternState(const char* state, const int pattern)
{
    const char* n = strchr(state, '#');
    
    sequencer.hardReset(pattern);

    /// Decode the Pattern's on-off state
    const bool status = static_cast<bool>(std::atoi(&state[0]));
    sequencer.activePatterns += static_cast<int>(status);
    sequencer.patterns.at(pattern).set(status);

    /// Decode each encoded Note: "#<NumberOfAttributes><x><y><Note><Shape>"
    while (n != nullptr)
    {
        size_t index = n - state;
        const int x     = static_cast<int>((char) *(state + index + 2) - 1);
        const int y     = static_cast<int>((char) *(state + index + 3) - 1);
        const int note  = static_cast<int>((char) *(state + index + 4) - 1);
        const int shape = static_cast<int>((char) *(state + index + 5) - 1);
        sequencer.addOrModifyNonCurrent(pattern, x, y, note, shape);

        n = strchr(n + 1, '#');
    }
}

const char* ASCommanderCore::encodePatternState(const int pattern) noexcept(false)
{
    if (pattern < 0 || pattern >= PATTERNS) throw "[ASCommanderCore] Invalid Pattern index";

    __state__.clear();
    __state__ += sequencer.patterns.at(pattern).isActive() ? '1' : '0';
    
    auto length = sequencer.patterns.at(pattern).length();
    for (size_t i = 0; i < length; ++i)
    {
        const auto row = sequencer.patterns.at(pattern).window(0, (int) i);
        std::vector<Note>::iterator notes = row.second;
        for (size_t n = 0; n < row.first; ++n)
        {
            __state__.append((*notes).repr());
            std::advance(notes, 1);
        }
    }

    return __state__.c_str();
}

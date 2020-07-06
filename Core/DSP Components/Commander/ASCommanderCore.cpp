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
        vibrato.setSampleRate(audioRate);
        clock.setSampleRate(audioRate);
        noise.setSampleRate(audioRate);
    }

    for (size_t r = 0; r < 2; ++r)
    {
        if (r < upsamplers.size()) delete upsamplers[r];
        if (r < dnsamplers.size()) delete dnsamplers[r];
    }
    
    upsamplers.clear();
    dnsamplers.clear();
    for (size_t r = 0; r < 2; ++r)
    {
        const auto capacity = 4096 * (int) OVERSAMPLING;
        const auto destinationRate = sampleRate * (double) OVERSAMPLING;
        upsamplers.push_back(new r8b::CDSPResampler24(sampleRate, destinationRate, capacity));
        dnsamplers.push_back(new r8b::CDSPResampler24(destinationRate, sampleRate, capacity));
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

        float sample = synthesiser.nextSample();
        vibrato.process(sample);
        buffer[t] = sample;
    }

    const int loversampled = upsamplers.at(0)->process(buffer.data(), sampleCount, oversample[0]);
    const int roversampled = upsamplers.at(1)->process(buffer.data(), sampleCount, oversample[1]);
    
    for (size_t k = 0; k < loversampled; ++k)
    {
        float lsample = (float) oversample[0][k];
        float rsample = (float) oversample[1][k];
        delay.process(lsample, rsample);
        oversample[0][k] = (double) lsample;
        oversample[1][k] = (double) rsample;
    }
    
    const int ldownsampled = dnsamplers.at(0)->process(&(oversample[0][0]), loversampled, downsample[0]);
    const int rdownsampled = dnsamplers.at(1)->process(&(oversample[1][0]), roversampled, downsample[1]);
    const size_t size = std::min(static_cast<int>(sampleCount), std::min(ldownsampled, rdownsampled));
    
    for (size_t k = 0; k < size; ++k)
    {
        const float whiteNoise = 0.F;//noise.nextSample();
        for (size_t c = 0; c < channels; ++c)
            output[c & 1][k] = whiteNoise + (float) downsample[c & 1][k];
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

//  Assemble
//  Created by David Spry on 9/4/20.
//  Copyright © 2020 David Spry. All rights reserved.

#include "ASCommanderCore.hpp"

/// \brief Initialise the Commander. This is called by `init` from the DSP layer.
/// \param sampleRate The sample rate to propagate to the audio components

void ASCommanderCore::init(double sampleRate)
{
    const float audioRate = static_cast<float>(sampleRate);
    const bool shouldUpdate = this->sampleRate != audioRate;
    this->sampleRate = audioRate;

    if (shouldUpdate) {
        synthesiser.setSampleRate(audioRate);
        clock.setSampleRate(audioRate);
    }
}

/// \brief Toggle the state of the Clock, which drives the Sequencer.
/// \note  If the Clock is about to begin ticking, the Clock and the Sequencer need to prepare for playback.
/// Otherwise, the Sequencer should reset to its initial state for the current Pattern.

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

/// \brief Set a parameter value in one of the underlying components
/// \param parameter The hexadecimal address of the parameter to be set
/// \param value The value to be set for the given parameter

void ASCommanderCore::set(uint64_t parameter, float value)
{
    const int type    = (int) parameter / (2 << 7);
    const int subtype = (int) parameter / (2 << 3) % 16;

    switch (type)
    {
        /// \brief The parameter address types 0xAE, 0xFE, and 0xF0
        /// address the envelopes and filters. These requests are handled by
        /// the synthesiser.
            
        case 0xAE:
        case 0xFE:
        case 0xF0: return synthesiser.set(parameter, value);
        
        /// \brief The parameter address type 0xEF addresses an effect.
        /// An effect request must be directed to its destination, so the request's
        /// subtype must be checked:
        /// 0xEF0 (Delay); 0xEF1 (Stereo Delay); 0xEF2 (Vibrato)

        case 0xEF:
            switch (subtype)
            {
                case 0:
                case 1: return delay.set(parameter, value);
                case 2: return vibrato.set(parameter, value);
            }
        
        case 0xAA: return sequencer.set(parameter, value);
        case 0xCA: return clock.set(parameter, value);

        default: return;
    }
}

/// \brief Get a parameter value from one of the underlying components
/// \note The Commander does not return any parameters directly. Instead,
/// it directs requests to the underlying components that it coordinates.
/// Additionally, this is the interface via which the Swift contexts reads the
/// current tempo and details about the sequencer, such as its current pattern
/// number or its current row number.
/// \param parameter The hexadecimal address of the desired parameter.

const float ASCommanderCore::get(uint64_t parameter)
{
    const int type    = (int) parameter / (2 << 7);
    const int subtype = (int) parameter / (2 << 3) % 16;

    switch (type)
    {
        case 0xAA: return sequencer.get(parameter);
        case 0xCA: return clock.get(parameter);

        case 0xAE: // Fallthrough
        case 0xFE: // Fallthrough
        case 0xF0: return synthesiser.get(parameter);
        
        case 0xEF:
        switch (subtype)
        {
            case 0: // Fallthrough
            case 1: return delay.get(parameter);
            case 2: return vibrato.get(parameter);
        }

        default:   return 0.F;
    }
}

/// \brief Render some number of samples, defined in `sampleCount`, into `output`.
/// `output` is assumed to be initialised such that it can accommodate `sampleCount` samples for
/// `channels` channels, and it expects them to be stored in an interleaved fashion.
///
/// This callback is the engine that drives every component. It advances the Clock,
/// advances the Sequencer, and loads the next row of Notes into the Synthesiser, which is
/// subsequently polled for new samples. Finally, the samples are processed by any active
/// global audio effects, such as filters, delay, and vibrato.
///
/// \param channels The number of channels to be rendered
/// \param sampleCount The number of samples per channel to be rendered.
/// \param output A pointer to an array of floats, the output buffer.

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
        sample[0] = sample[1] = synthesiser.nextSample();
        sample[0] = sample[1] = vibrato.process(sample[0]);
//        sample[0] = delay.process(sample[0], static_cast<bool>(1));
//        sample[1] = delay.process(sample[1], static_cast<bool>(0));

        for (size_t c = 0; c < channels; c++)
            output[c][t] = sample[c & 1];
    }
}

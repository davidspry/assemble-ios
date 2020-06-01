//  Assemble
//  Created by David Spry on 10/04/2020.
//  Copyright © 2020 David Spry. All rights reserved.

#ifdef __cplusplus

#ifndef ASCOMMANDERCORE_H
#define ASCOMMANDERCORE_H

#include "ASHeaders.h"
#include "ASConstants.h"
#include "ASEffects.h"

#include "WhiteNoisePeriodic.hpp"
#include "Synthesiser.hpp"
#include "Sequencer.hpp"
#include "Clock.hpp"

/// \brief The interface to the Assemble core. This class coordinates propagates requests and pulls new samples from underlying DSP components.

class ASCommanderCore
{
public:
    /// \brief Initialise the Commander. This is called by `init` from the DSP layer.
    /// \param sampleRate The sample rate to propagate to the audio components
    
    void init(double sampleRate);
    
    /// \brief Render some number of samples, defined in `sampleCount`, into `output`.
    /// `output` is assumed to be initialised such that it can accommodate `sampleCount` samples for
    /// `channels` channels, and it expects them to be stored in an interleaved fashion.
    ///
    /// This callback is the engine that drives every component. It advances the Clock,
    /// advances the Sequencer, and loads the next row of Notes into the Synthesiser, which is
    /// subsequently polled for new samples. Finally, the samples are processed by any active
    /// global audio effects, such as filters, delay, and vibrato.
    ///
    /// \param channels The number of channels to be rendered.
    /// \param sampleCount The number of samples per channel to be rendered.
    /// \param output A pointer to an array of floats, the output buffer.

    void render(unsigned int channels, unsigned int sampleCount, float * output[]);

    /// \brief Load a note into the Synthesiser
    /// \param note The pitch of the note to load as a MIDI note number
    /// \param shape The index of the oscillator to use

    void loadNote(const int note, const int shape)
    {
        synthesiser.loadNote(note, shape);
    }
    
    /// \brief Get the note at position (x, y) in the Sequencer's current Pattern,
    /// then mutate the given pointers with the corresponding values, provided that a non-null
    /// note exists at position (x, y).
    /// \param x The x-coordinate of the desired note
    /// \param y The y-coordinate of the desired note
    /// \param note The location in memory where the MIDI note number should be stored
    /// \param shape The location in memory where the note's shape should be stored

    void getNote(const int x, const int y, int* note, int* shape)
    {
        const Note& datum = sequencer.patterns.at(sequencer.pattern).pattern.at(x, y);
        
        if (datum.null)
            return;

        *note  = datum.note;
        *shape = datum.shape;
    }
    
    /// \brief Write a note to the sequencer at position (x, y)
    /// \param x The x-coordinate of the position on the sequencer where the note should be written
    /// \param y The y-coordinate of the position on the sequencer where the note should be written
    /// \param note The pitch of the note to load as a MIDI note number
    /// \param shape The index of the oscillator to use

    void writeNote(int x, int y, int note, int shape)
    {
        sequencer.addOrModify(x, y, note, shape);
    }
    
    /// \brief Erase the contents of the sequencer at position (x, y)
    /// \param x The x-coordinate of the position on the sequencer that should be erased
    /// \param y The y-coordinate of the position on the sequencer that should be erased

    void eraseNote(int x, int y)
    {
        sequencer.erase(x, y);
    }

    /// \brief Toggle the state of the Clock, which drives the Sequencer.
    /// \note  If the Clock is about to begin ticking, the Clock and the Sequencer need to prepare for playback.
    /// Otherwise, the Sequencer should reset to its initial state for the current Pattern.

    const bool playOrPause();
    
    /// \brief Clear the state of the current Pattern.
    
    inline void clearCurrentPattern() { sequencer.hardReset(sequencer.pattern); }

    /// \brief Indicate whether or not the Clock is ticking.
    /// \return `true` if the Clock is ticking; `false` otherwise.

    const bool clockIsTicking() { return clock.isTicking();  }

    /// \brief From an encoded Pattern state, decode the on-off state and each Note, and initialise
    /// the corresponding Pattern accordingly.
    ///
    /// \note  See that when Notes are encoded, they are represented as a string of characters whose
    /// values are derived from integers. As `static_cast<char>(0)` is the null terminator character, and some
    /// integer values may be 0, each attribute in Note is increased by 1 before encoding. This prevents
    /// null-terminator characters from appearing before the end of the data, which effectively preserves
    /// information. In order to decode the correct value, the positive offset of 1 must be subtracted from the
    /// decoded value.
    ///
    /// \param state The encoded data for a Pattern
    /// \param pattern The Pattern who should be initialised

    void loadFromEncodedPatternState(const char* state, const int pattern);

    /// \brief Encode a Pattern's state as a string for the purpose of persistence.
    ///
    /// \note  Each state string ends with "#0" or "#1" to denote whether the Pattern is active or not.
    /// Encoding of Notes is performed by the Note class. Each attribute in Note is encoded as an ASCII
    /// character, and each Note's encoded data begins with the pound sign character, '#'. Only non-null Notes are saved.
    ///
    /// \param pattern The Pattern whose state should be encoded and returned.

    const char* encodePatternState(const int pattern) noexcept(false);

    /// \brief Set a parameter value in one of the underlying components
    /// \param parameter The hexadecimal address of the parameter to be set
    /// \param value The value to be set for the given parameter
    
    void set(uint64_t parameter, const float value);
    
    /// \brief Return a parameter value. If the parameter does not exist, 0 will be returned.
    /// \param parameter The hexadecimal address of the desired parameter.
    
    const float get(uint64_t parameter);

private:
    Clock       clock = {100};
    Sequencer   sequencer;
    Synthesiser synthesiser;
    Vibrato     vibrato;
    StereoDelay delay = {&clock};
    WhiteNoisePeriodic noise;

private:
    float sampleRate;
    std::array<float, 2> sample;

private:
    /// \brief A block of memory for storing encoded state that can be passed up to the Swift context

    std::string __state__;
};

#endif // END CLASS
#endif // END IFDEF

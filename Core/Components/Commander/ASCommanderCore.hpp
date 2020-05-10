//  Assemble
//  Created by David Spry on 10/04/2020.
//  Copyright © 2020 David Spry. All rights reserved.

#ifdef __cplusplus

#ifndef ASCOMMANDERCORE_H
#define ASCOMMANDERCORE_H

#include "ASHeaders.h"
#include "ASConstants.h"
#include "ASEffects.h"

#include "Synthesiser.hpp"
#include "Sequencer.hpp"
#include "Clock.hpp"

class ASCommanderCore
{
public:
    void init(double);
    void render(unsigned int, unsigned int, float *[]);

public:
    void loadNote(const int note, const int shape)    { synthesiser.loadNote(note, shape);        }
    void writeNote(int x, int y, int note, int shape) { sequencer.addOrModify(x, y, note, shape); }
    void eraseNote(int x, int y)                      { sequencer.erase(x, y); }
    
public:
    const bool playOrPause();
    const bool clockIsTicking() { return clock.isTicking();  }
    const bool toggleMode()     { return sequencer.toggle(); }
    
public:
    void prepareToLoadPatternState();
    void loadFromEncodedPatternState(const char* state, const int pattern);
    const char* encodePatternState(const int pattern) noexcept(false);

public:
    /// \brief Set a parameter value. If the parameter does not exist, nothing will happen.
    /// \param parameter The address of the parameter to set
    /// \param value The value to be set
    void set(uint64_t parameter, float value);
    
    /// \brief Return a parameter value. If the parameter does not exist, 0 will be returned.
    /// \param parameter The address of the parameter whose parameter should be returned.
    const float get(uint64_t parameter);

private:
    Clock       clock = { 90 };
    Sequencer   sequencer;
    Synthesiser synthesiser;
    Vibrato     vibrato;
    StereoDelay delay = {&clock};

private:
    float sampleRate;
    std::array<float, 2> sample;
    
private:
    std::string __state__;
};

#endif
#endif

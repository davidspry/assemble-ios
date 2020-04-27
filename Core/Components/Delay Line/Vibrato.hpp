//  Assemble
//  Created by David Spry on 24/4/20.
//  Copyright © 2020 David Spry. All rights reserved.

#ifndef VIBRATO_HPP
#define VIBRATO_HPP

#include "ASHeaders.h"
#include "ASUtilities.h"
#include "ASParameters.h"
#include "ASOscillators.h"

// TODO: Add static sine wavetable to codebase
// TODO: Add modulation by looking up the sine wavetable

class Vibrato
{
public:
    Vibrato();

public:
    const float process(float sample);
    
public:
    void  setSampleRate(float sampleRate);
    void  set(uint64_t parameter, float value);
    const float get(uint64_t parameter);

private:
    std::atomic<bool> bypassed = {false};
    std::atomic<float> depth = {0.35F};
    std::atomic<float> speed = {2.00F};
    SineOscillator modulator = {2.00F};

private:
    /// There must be a buffer between the whead, which increases linearly,
    /// and the rhead, which is modulated by a sine wave. If the buffer is not
    /// large enough, the rhead can move beyond the whead, which causes
    /// a glitching effect.

    int   whead = 550;
    float rhead = 0.F;
    
private:
    int capacity;
    float scalar = 0.05F;
    float sampleRate = 48000.F;
    std::vector<float> samples;
};

#endif

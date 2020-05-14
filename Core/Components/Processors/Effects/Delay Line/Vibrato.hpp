//  Assemble
//  Created by David Spry on 24/4/20.
//  Copyright © 2020 David Spry. All rights reserved.

#ifndef VIBRATO_HPP
#define VIBRATO_HPP

#include "ASHeaders.h"
#include "ASUtilities.h"
#include "ASParameters.h"
#include "ASOscillators.h"

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
    std::atomic<float> speed = {1.0F};
    std::atomic<float> depth = {1.0F};
    std::atomic<float> targetDepth = {1.0F};
    std::atomic<float> depthNormal = {1.0F};
    SineWTOscillator modulator = {1.0F};

private:
    inline void fadeOut(const float t) { depth = std::max(t, depth - 0.1F); }
    inline void  fadeIn(const float t) { depth = std::min(t, depth + 0.1F); }
    void update();

private:
    /// There must be a buffer between the whead, which increases linearly,
    /// and the rhead, which is modulated by a sine wave. If the buffer is not
    /// large enough, the rhead may move beyond the whead, which causes
    /// a glitching effect.

    int   whead = 0;
    float rhead;
    
private:
    int capacity;
    float scalar = 115.0F;
    float sampleRate = 48000.F;
    std::vector<float> samples;
};

#endif

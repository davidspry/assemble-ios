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
    void process(float& sample);
    
public:
    void setSampleRate(float sampleRate);
    void set(uint64_t parameter, float value);
    const float get(uint64_t parameter);

private:
    std::atomic<bool> bypassed = {false};
    std::atomic<float> speed;
    std::atomic<float> depth;
    std::atomic<float> targetDepth;
    std::atomic<float> depthNormal;
    
private:
    BandlimitedOscillator<SIN> modulator;
    ValueTransition portamento = { 0.5F, 1.0F };

private:
    inline void fadeOut(const float t) { depth = std::max(t, depth - 0.01F); }
    inline void  fadeIn(const float t) { depth = std::min(t, depth + 0.01F); }
    void update();

private:
    int   whead = 0;
    float rhead;
    
private:
    int capacity;
    float scalar = 250.0F;
    float sampleRate = 48000.F;
    std::vector<float> samples;
};

#endif

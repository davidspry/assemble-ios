//  Assemble
//  Created by David Spry on 20/4/20.
//  Copyright © 2020 David Spry. All rights reserved.

#include "Synthesiser.hpp"

void Synthesiser::loadNote(const int note, const int shape)
{
    const auto& frequency = frequencies[note];

    switch (shape)
    {
        case 0x0: return sin.load(frequency);
        case 0x1: return tri.load(frequency);
        case 0x2: return sqr.load(frequency);
        case 0x3: return saw.load(frequency);
        default:  return;
    }
}

const float Synthesiser::nextSample()
{
    float sample = 0.F;

    sample += sin.nextSample();
    sample += tri.nextSample();
    sample += sqr.nextSample();
    sample += saw.nextSample();

    return sample * 0.0625F;
}

const float Synthesiser::get(uint64_t parameter)
{
    const int bank = (int) parameter / 16 % 16 - 1;
    switch (bank)
    {
        case 0x0: return sin.get(parameter);
        case 0x1: return tri.get(parameter);
        case 0x2: return sqr.get(parameter);
        case 0x3: return saw.get(parameter);
        default:  return 0.0F;
    }
}

void Synthesiser::set(uint64_t parameter, float value)
{
    const int bank = (int) parameter / 16 % 16 - 1;
    switch (bank)
    {
        case 0x0: return sin.set(parameter, value);
        case 0x1: return tri.set(parameter, value);
        case 0x2: return sqr.set(parameter, value);
        case 0x3: return saw.set(parameter, value);
        default:  return;
    }
}

void Synthesiser::setSampleRate(const float sampleRate)
{
    const bool shouldUpdate = this->sampleRate != sampleRate;
    
    if (shouldUpdate)
    {
        this->sampleRate = sampleRate;
        sin.setSampleRate(sampleRate);
        tri.setSampleRate(sampleRate);
        sqr.setSampleRate(sampleRate);
        saw.setSampleRate(sampleRate);
    }
}

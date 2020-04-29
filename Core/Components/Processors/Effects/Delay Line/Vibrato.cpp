//  Assemble
//  Created by David Spry on 24/4/20.
//  Copyright © 2020 David Spry. All rights reserved.

#include "Vibrato.hpp"

Vibrato::Vibrato()
{
    capacity = sampleRate * 2;
    samples.reserve(capacity);
    samples.assign(capacity, 0.F);
}

const float Vibrato::get(uint64_t parameter)
{
    switch (parameter)
    {
        case kVibratoToggle: return static_cast<float>(bypassed);
        case kVibratoSpeed:  return speed;
        case kVibratoDepth:  return depth;
        default: return 0.F;
    }
}

void Vibrato::set(uint64_t parameter, float value)
{
    switch (parameter)
    {
        case kVibratoToggle:
        {
            bypassed = !bypassed;
            break;
        }
        case kVibratoSpeed:
        {
            speed.store(Assemble::Utilities::bound(value, 0.1F, 10.F));
            modulator.load(speed);
            break;
        }
        case kVibratoDepth:
        {
            depth.store(Assemble::Utilities::bound(value, 0.0F, 1.0F));
            break;
        }
        default: return;
    }
}

void Vibrato::setSampleRate(float sampleRate)
{
    if (this->sampleRate == sampleRate)
        this->sampleRate = sampleRate;
}

const float Vibrato::process(float sample)
{
    if (bypassed)
        return sample;

    samples[whead] = sample;

    const float modulated = Assemble::Utilities::lerp(rhead, &samples.at(0), capacity);

    whead = whead + 1;
    whead = whead - static_cast<int>(whead >= capacity) * capacity;
    
    rhead = rhead + 1;
    rhead = rhead + depth * scalar * modulator.nextSample();
    rhead = rhead + static_cast<int>(rhead <  0) * capacity;
    rhead = rhead - static_cast<int>(rhead >= capacity) * capacity;
    
    return modulated;
}

//  Assemble
//  Created by David Spry on 24/4/20.
//  Copyright © 2020 David Spry. All rights reserved.

#include "Vibrato.hpp"

Vibrato::Vibrato()
{
    capacity = sampleRate;
    samples.reserve(capacity);
    samples.assign (capacity, 0.F);
    
    set(kVibratoDepth, 3.0F);
    set(kVibratoSpeed, 0.1F);
}

const float Vibrato::get(uint64_t parameter)
{
    switch (parameter)
    {
        case kVibratoToggle: return static_cast<float>(!bypassed);
        case kVibratoDepth:  return depthNormal;
        case kVibratoSpeed:  return speed;
        default: return 0.F;
    }
}

void Vibrato::set(uint64_t parameter, float value)
{
    switch (parameter)
    {
        case kVibratoToggle:
        {
            const bool status = static_cast<bool>(value);
            bypassed = !status;
            break;
        }
        case kVibratoSpeed:
        {
            const float frequency = Assemble::Utilities::bound(value, 0.1F, 15.F);
            portamento.set(frequency * scale);
            speed.store(frequency);
            break;
        }
        case kVibratoDepth:
        {
            targetDepth.store(Assemble::Utilities::bound(value, 0.0F, 1.0F));
            depthNormal.store(targetDepth.load());
            targetDepth.store(value * scalar);
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

inline void Vibrato::update()
{
    const float x = depth.load();
    const float y = bypassed ? 0.F : targetDepth.load();
    
    if (x == y) return;
    if (depth.load() > y) fadeOut(y);
    else                   fadeIn(y);
}

void Vibrato::process(float& sample)
{
    update();

    samples[whead] = sample;

    sample = Assemble::Utilities::hermite(rhead, samples.data(), capacity);

    whead = whead + 1;
    whead = whead - static_cast<int>(whead >= capacity) * capacity;

    rhead = whead - depth + depth * modulator.nextSample();
    rhead = rhead + static_cast<int>(rhead <  0) * capacity;
    rhead = rhead - static_cast<int>(rhead >= capacity) * capacity;
    
    if (!portamento.complete()) modulator.update(portamento.get());
}

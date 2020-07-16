//  Assemble
//  Created by David Spry on 24/4/20.
//  Copyright © 2020 David Spry. All rights reserved.

#include "Vibrato.hpp"

Vibrato::Vibrato()
{
    capacity = 256;
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
    const float source = depth.load();
    const float target = bypassed ? 0.F : targetDepth.load();
    
    if (source == target) return;
    if (source >  target) fadeOut(target);
    else                   fadeIn(target);
}

void Vibrato::process(float& sample)
{
    update();

    samples[whead] = sample;

    sample = Assemble::Utilities::lerp(rhead, samples.data(), capacity);
    
    whead = whead + 1;
    whead = static_cast<int>(whead < capacity) * whead;

    rhead = whead - depth + depth * modulator.nextSample();
    
    while (rhead < 0)         rhead = rhead + capacity;
    while (rhead >= capacity) rhead = rhead - capacity;

    if (!portamento.complete()) modulator.update(portamento.get());
}

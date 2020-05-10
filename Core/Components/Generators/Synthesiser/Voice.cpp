//  Assemble
//  Created by David Spry on 26/2/20.
//  Copyright © 2020 David Spry. All rights reserved.

#include "Voice.hpp"

Voice::Voice()
{
    vca.set(5, 0, 2000);
    vcf.set(45, 0, 1500);
}

void Voice::load(float frequency)
{
    vca.prepare();
    vcf.prepare();
    osc->load(frequency);
}

const float Voice::get(uint64_t parameter)
{
    const int type = (int) parameter / (2 << 7);
    switch (type)
    {
        case 0xF0: return lpf.get(parameter);
        case 0xAE: return vca.get(parameter);
        case 0xFE: return vcf.get(parameter);
        default: return 0.F;
    }
}

void Voice::set(uint64_t parameter, float value)
{
    const int type = (int) parameter / (2 << 7);
    switch (type)
    {
        case 0xAE: vca.set(parameter, value); return;
        case 0xFE: vcf.set(parameter, value); return;
        case 0xF0: lpf.set(parameter, value); return;
        default: return;
    }
}

void Voice::setSampleRate(float sampleRate)
{
    osc->setSampleRate(sampleRate);
    lpf.setSampleRate(sampleRate);
    vca.setSampleRate(sampleRate);
    vcf.setSampleRate(sampleRate);
}

const float Voice::nextSample()
{
    if (vca.closed()) return 0.0F;

    float sample, envelope;
    envelope = vca.nextSample();
    sample = osc->nextSample();
    sample = lpf.process(sample);
    
    return envelope * sample;
}

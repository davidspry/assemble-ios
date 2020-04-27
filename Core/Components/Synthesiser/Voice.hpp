//  Assemble
//  Created by David Spry on 26/2/20.
//  Copyright © 2020 David Spry. All rights reserved.

#ifndef VOICE_HPP
#define VOICE_HPP

#include "ASParameters.h"
#include "Oscillator.hpp"
#include "AHREnvelope.hpp"
#include "HuovilainenFilter.hpp"

class Voice
{
public:
    Voice();
    
public:
    void load(float frequency);
    const float nextSample();

public:
    const float get(uint64_t parameter);
    void set(uint64_t parameter, float value);
    void setSampleRate(float sampleRate);
    void makeFree() { free = true; }
    bool isFree()   { return free; }
    
protected:
    bool free = true;

protected:
    Oscillator        *osc;
    AHREnvelope   vca, vcf;
    HuovilainenFilter  lpf = {&vcf};

friend class Synthesiser;
};

#endif

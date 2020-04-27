//  Assemble
//  Created by David Spry on 3/4/20.
//  =================================
//  Author: This implementation of the Moog Ladder Filter was derived from the work of Antti Huovilainen
//  <https://pdfs.semanticscholar.org/c490/4c04a7be1d675e360409178da71a1253f6d8.pdf>
//
//  Source: This implementation was derived from an implementation written for CSound 5
//  <https://github.com/ddiakopoulos/MoogLadders/blob/master/src/HuovilainenModel.h>
//
//  License: GNU Lesser General Public License v2.1
//  <https://github.com/csound/csound/blob/develop/COPYING>

#ifndef HUOVILAINENFILTER_HPP
#define HUOVILAINENFILTER_HPP

#include "AHREnvelope.hpp"
#include "ASParameters.h"
#include "ASConstants.h"
#include "ASHeaders.h"

class HuovilainenFilter
{
public:
    HuovilainenFilter() { initialise(); }
    HuovilainenFilter(AHREnvelope* vcf) { ahr = vcf; initialise(); }

public:
    const float get(uint64_t parameter);
    void set(uint64_t parameter, float value);
    void bind(AHREnvelope& vcf) { ahr = &vcf; }

public:
    const float process(float sample);
    inline void set(const float cutoff, const float resonance);
    void setSampleRate(float sampleRate) { this->sampleRate = sampleRate; }

private:
    void initialise();
    inline float quicktanh(float);
    
private:
    float sampleRate = 48000.F;
    std::atomic<float> targetFrequency = { 6E3F };
    std::atomic<float> targetResonance = { 0.0F };
    float frequency = targetFrequency;
    float resonance = targetResonance;
    
private:
    std::array<float, 6> delay;
    std::array<float, 4> stage;
    std::array<float, 3> tanhStage;
    
private:
    float G = 0.0F;
    float A = 0.0F;
    float thermal = 0.0F;
    float resonanceFour = 0.0F;

private:
    AHREnvelope* ahr;
};

#endif

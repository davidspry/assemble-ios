//  Assemble
//  Created by David Spry on 20/4/20.
//  Copyright © 2020 David Spry. All rights reserved.

#ifndef SYNTHESISER_HPP
#define SYNTHESISER_HPP

#include "Voice.hpp"
#include "ASHeaders.h"
#include "ASConstants.h"
#include "ASParameters.h"
#include "ASOscillators.h"
#include "ASFrequencies.h"

class Synthesiser
{
public:
    Synthesiser();
    
public:
    void loadNote(const int, const int);
    const float nextSample();
    
public:
    void setSampleRate(const float);
    void set(uint64_t, float);
    const float get(uint64_t);
    
private:
    std::array<int, OSCILLATORS> nextVoice;
    
private:
    std::array<Voice, OSCILLATORS * POLYPHONY> voices;
    std::array<BandlimitedOscillator<SIN>, POLYPHONY> sine;
    std::array<BandlimitedOscillator<TRI>, POLYPHONY> triangle;
    std::array<BandlimitedOscillator<SQR>, POLYPHONY> square;
    std::array<BandlimitedOscillator<SAW>, POLYPHONY> sawtooth;
    
private:
    std::array<ValueTransition, OSCILLATORS> frequency;
    std::array<ValueTransition, OSCILLATORS> resonance;

private:
    float sampleRate = 48000.F;
    
friend class Voice;
};

#endif

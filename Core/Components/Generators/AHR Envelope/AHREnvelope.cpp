//  Assemble
//  ============================
//  Created by David Spry on 10/4/20.
//  Copyright © 2020 David Spry. All rights reserved.

#include "AHREnvelope.hpp"

void AHREnvelope::set(float attack, float hold, float release)
{
    attack  = std::fmax(1.F, std::fmin(attack, 5000.F));
    hold    = std::fmax(0.F, std::fmin(hold,   5000.F));
    release = std::fmax(1.F, std::fmin(release,5000.F));

    attackInMs  = attack;
    holdInMs    = hold;
    releaseInMs = release;
    
    attackInSamples  = Assemble::Utilities::samples(attack, sampleRate);
    holdInSamples    = Assemble::Utilities::samples(hold,   sampleRate);
    releaseInSamples = Assemble::Utilities::samples(release,sampleRate);
}

void AHREnvelope::setSampleRate(float sampleRate)
{
    this->sampleRate = sampleRate;
    set(attackInMs, holdInMs, releaseInMs);
}

void AHREnvelope::prepare()
{
    setMode(Attack);
    amplitude = 0.0F;
    time = 0;
}

/// \brief Get the parameter values of the AHREnvelope.
/// Specifically, these are the attack, hold, and releaes times in milliseconds.
/// \param parameter The hexadecimal address of the desired parameter

const float AHREnvelope::get(uint64_t parameter)
{
    const int subtype = (int) parameter % 16;
    switch (subtype)
    {
        case 0: return attackInMs;
        case 1: return holdInMs;
        case 2: return releaseInMs;
        default: return 0.F;
    }
}

/// \brief Set the parameter values of the AHREnvelope.
/// \param parameter The hexadecimal address of the desired parameter
/// \param value The value to set for the given parameter

void AHREnvelope::set(uint64_t parameter, float value)
{
    const int subtype = (int) parameter % 16;
    switch (subtype)
    {
        case 0: set(value, holdInMs, releaseInMs);   return;
        case 1: set(attackInMs, value, releaseInMs); return;
        case 2: set(attackInMs, holdInMs, value);    return;
        default: return;
    }
}

const float AHREnvelope::nextSample()
{
    switch (mode)
    {
        case Attack:
            amplitude = std::pow(computeAttack(time), 3.0F);
            mode = static_cast<Mode>(Mode::Attack + static_cast<int>(amplitude >= 1.0F));
            break;
            
        case Hold:
            if ((holdInSamples == 0) || (time - attackInSamples >= holdInSamples))
            {
                time = 0;
                mode = static_cast<Mode>(Mode::Release);
            }   else break;

        case Release:
            amplitude = std::pow(computeRelease(time), 3.0F);
            mode = static_cast<Mode>(Release + static_cast<int>(amplitude <= 0.0F));
            break;

        case Closed:
            amplitude = 0.0F;
            break;
    }
    
    time++;
    return amplitude;
}

double AHREnvelope::computeAttack(int &time)
{
    return (double) time / (attackInSamples + 1);
}

double AHREnvelope::computeRelease(int &time)
{
    return (double) 1.0 + time * -(1.0 / (releaseInSamples + 1));
}

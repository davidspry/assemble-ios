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

    if (time > releaseInSamples) setMode(Recovery);
}

void AHREnvelope::setSampleRate(float sampleRate)
{
    this->sampleRate = sampleRate;
    set(attackInMs, holdInMs, releaseInMs);
}

/// \brief Prepare the envelope to begin a new cycle
/// If the envelope is not closed, compute the inverse function
/// of the attack curve in order to begin the envelope's phase
/// with a time value that corresponds to its current amplitude.

void AHREnvelope::prepare()
{
    amplitude = std::fmax(0.0F, amplitude);
    
    time = (amplitude > 0.0F) ? computeTimeOnRetrigger() : 0;
    
    setMode(Attack);
}

/// \brief Get the parameter values of the AHREnvelope.
/// Specifically, these are the attack, hold, and releaes times in milliseconds.
/// \param parameter The hexadecimal address of the desired parameter

const float AHREnvelope::get(uint64_t parameter)
{
    const int subtype = (int) parameter % 16;
    switch (subtype)
    {
        case 0x0: return attackInMs;
        case 0x1: return holdInMs;
        case 0x2: return releaseInMs;
        default:  return 0.F;
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
        case 0x0: set(value, holdInMs, releaseInMs);   return;
        case 0x1: set(attackInMs, value, releaseInMs); return;
        case 0x2: set(attackInMs, holdInMs, value);    return;
        default:  return;
    }
}

const float AHREnvelope::nextSample()
{
    switch (mode)
    {
        case Attack:
        {
            amplitude = std::pow(computeAttack(time), 3.0F);
            mode = static_cast<Mode>(Mode::Attack + static_cast<int>(amplitude >= 1.0F));
            break;
        }
            
        case Hold:
        {
            if ((holdInSamples == 0) || (time - attackInSamples >= holdInSamples))
            {
                time = 0;
                mode = static_cast<Mode>(Mode::Release);
            }   else break;
        }

        case Release:
        {
            amplitude = std::pow(computeRelease(time), 3.0F);
            mode = static_cast<Mode>(Release + static_cast<int>(amplitude <= 0.0F));
            break;
        }

        case Closed:
        {
            amplitude = 0.0F;
            break;
        }

        /// The recovery phase is reserved for cases where the duration of the release phase has been decreased
        /// such that releaseInSamples < time. This relationship produces a negative value for amplitude, which in
        /// turn causes loud popping and clicking sounds for several seconds.
        /// To avoid this, the recovery phase is entered manually when the envelope's properties are set, but only
        /// in cases where the time > releaseInSamples. The recovery phase lasts for as long as it takes for the
        /// amplitude to fade out linearly to zero.

        case Recovery:
        {
            amplitude = std::fmax(0.0F, amplitude - 1E-4F);
            mode = static_cast<Mode>(Recovery - static_cast<int>(amplitude == 0.0F));
        }

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
    return 1.0 - ((double) time / (releaseInSamples + 1));
}

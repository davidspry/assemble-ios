//  Assemble
//  ============================
//  Created by David Spry on 10/4/20.
//  Copyright © 2020 David Spry. All rights reserved.

#include "AHREnvelope.hpp"

void AHREnvelope::set(float attack, float hold, float release)
{
    attack  = Assemble::Utilities::bound(attack,  0.F, 3000.F);
    hold    = Assemble::Utilities::bound(hold,    0.F, 3000.F);
    release = Assemble::Utilities::bound(release, 5.F, 3000.F);

    attackInMs  = attack;
    holdInMs    = hold;
    releaseInMs = release;
    
    attackInSamples  = Assemble::Utilities::samples(attack, sampleRate);
    holdInSamples    = Assemble::Utilities::samples(hold,   sampleRate);
    releaseInSamples = Assemble::Utilities::samples(release,sampleRate);

    if ((mode == Mode::Attack  && !(time < attackInSamples)) ||
        (mode == Mode::Release && !(time < releaseInSamples)))
    {
        time.store(computeReleaseInverse());
        setMode(Mode::Release);
    }
    
    shouldUpdate.store(false);
}

void AHREnvelope::setSampleRate(float sampleRate)
{
    if (this->sampleRate == sampleRate)
        return;
    
    this->sampleRate = sampleRate;
    set(attackInMs, holdInMs, releaseInMs);
}

void AHREnvelope::prepare()
{
    amplitude = std::fmax(0.0F, amplitude);
    
    time = 0;

    if (shouldUpdate.load() == true)
        set(attackInMs, holdInMs, releaseInMs);

    if (amplitude > 0.0F)
        time = computeTimeOnRetrigger();

    setMode(Mode::Attack);
}

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

void AHREnvelope::set(uint64_t parameter, float value)
{
    shouldUpdate.store(true);

    const int subtype = (int) parameter % 16;
    switch (subtype)
    {
        case 0x0: attackInMs  = value; return;
        case 0x1: holdInMs    = value; return;
        case 0x2: releaseInMs = value; return;
        default:  return;
    }
}

const float AHREnvelope::nextSample()
{
    switch (mode)
    {
        case Attack:
        {
            amplitude = std::powf(computeAttack(time.load()), 3.0F);
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
            if (time <= releaseInSamples)
                amplitude = std::powf(computeRelease(time.load()), 3.0F);
            
            mode = static_cast<Mode>(Mode::Release + static_cast<int>(time == releaseInSamples) * 1);
            mode = static_cast<Mode>(Mode::Release + static_cast<int>(time >  releaseInSamples) * 2);
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
        /// amplitude to fade out linearly to zero, then the envelope will close.

        case Recovery:
        {
            amplitude = Assemble::Utilities::bound(amplitude - 1E-4F, 0.F, 1.F);
            mode = static_cast<Mode>(Mode::Recovery - static_cast<int>(amplitude == 0.0F));
        }

    }
    
    time++;
    return amplitude;
}

const float AHREnvelope::computeAttack(uint time)
{
    return (float) time / (float) (attackInSamples + 1);
}

const float AHREnvelope::computeRelease(uint time)
{
    return 1.0F - ((float) time / (float) (releaseInSamples + 1));
}

//  Assemble
//  Created by David Spry on 24/4/20.
//  Copyright © 2020 David Spry. All rights reserved.

#include "Delay.hpp"

Delay::Delay(Clock *clock)
{
    this->clock = clock;
    bpm = clock->bpm;
    capacity = clock->sampleRate * 4;
    samples.reserve(capacity);
    samples.assign(capacity, 0.F);
    set(1.5F);
}

/// \brief Get the value of the Delay Line's parameters
/// \param parameter The hexadecimal address of the desired parameter

const float Delay::get(uint64_t parameter)
{
    switch (parameter)
    {
        case kDelayMix:
        {
            return mix;
        }
            
        case kDelayMusicalTime:
        {
            return targetAsIndex;
        }
            
        case kDelayFeedback:
        {
            return feedback;
        }
            
        case kDelayTimeInMs:
        {
            return Assemble::Utilities::milliseconds(target, clock->sampleRate);
        }
         
        case kDelayModulationSpeed:
        {
            return modulationSpeed;
        }
            
        case kDelayModulationDepth:
        {
            return modulationDepth;
        }

        default: return 0.0F;
    }
}

/// \brief Set the parameters of the Delay Line
/// \param parameter The hexadecimal address of the parameter
/// \param value The value to set for the selected parameter

void Delay::set(uint64_t parameter, float value)
{
    switch (parameter)
    {
        case kDelayToggle:
        {
            bypassed = static_cast<bool>(value);
            break;
        }
        case kDelayFeedback:
        {
            feedback = Assemble::Utilities::bound(value, 0.F, 1.F);
            break;
        }
        case kDelayTimeInMs:
        {
            const int time = (int) std::floor(Assemble::Utilities::bound(value, 0.F, 4000.F));
            set(time);
            break;
        }
        case kDelayMusicalTime:
        {
            const float time = parseMusicalTimeParameterIndex((int) value);
            targetAsIndex = time;
            set(time);
            break;
        }
        case kDelayMix:
        {
            const float mix = Assemble::Utilities::bound(value, 0.F, 1.F);
            this->mix = mix;
        }
        case kDelayModulationSpeed:
        {
            const float speed = Assemble::Utilities::bound(value, 0.1F, 25.F);
            this->modulationSpeed = speed;
            modulator.load(speed);
        }
        case kDelayModulationDepth:
        {
            const float depth = Assemble::Utilities::bound(value, 0.F, 2.F);
            this->modulationDepth = depth;
        }
        default: return;
    }
}

/// \brief Parse an index from an input parameter value and return the matching
/// musical time factor constant.
/// \param index The input value

const float Delay::parseMusicalTimeParameterIndex(const int index)
{
    switch (index)
    {
        case 0:  return fDelayWholeNote;
        case 1:  return fDelayHalfNote;
        case 2:  return fDelayHalfDotted;
        case 3:  return fDelayEighthNote;
        case 4:  return fDelayEighthDotted;
        case 5:  return fDelayQuarterNote;
        case 6:  return fDelayQuarterDotted;
        case 7:  return fDelaySixteenthNote;
        case 8:  return fDelaySixteenthDotted;
        default: return 1.F;
    }
}

/// \brief Inject an offset of some number of milliseconds into the delay target.
/// When combining two delays for a stereo effect, injecting a 3-5 millisecond offset
/// creates a wider effect.
/// \param milliseconds The number of milliseconds to inject into the delay target

void Delay::inject(int milliseconds)
{
    offsetInSamples = Assemble::Utilities::samples(milliseconds, clock->sampleRate);
    set(time);
}

void Delay::cycleDelayTime(const bool shorter)
{
    printf("[Unimplemented] Delay::cycleDelayTime(const bool shorter)");
}

/// \brief Process the incoming sample
/// \param sample A sample to process

const float Delay::process(const float sample)
{
    if (bpm != clock->bpm) update();
    
    if (bypassed)
        fadeOut();
    else           fadeIn();

    delay = delay + 5e-5f * (target - delay);
    samples[whead] = gain * sample + feedback * samples[rhead];
    const float lerp = Assemble::Utilities::lerp(rhead, &samples[0], capacity);

    whead = whead + 1;
    if (whead >= capacity) whead = 0;

    rhead = whead - delay;
//    rhead = rhead + modulationDepth * (150 * modulator.nextSample());
    rhead = rhead - static_cast<int>(rhead >= capacity) * capacity;
    rhead = rhead + static_cast<int>(rhead <  0) * capacity;

    return (1.F - mix) * sample + mix * lerp;
}

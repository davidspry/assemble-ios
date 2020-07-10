//  Assemble
//  Created by David Spry on 24/4/20.
//  Copyright © 2020 David Spry. All rights reserved.

#include "Delay.hpp"

Delay::Delay(Clock *clock)
{
    bpm = clock->bpm;
    this->clock = clock;
    
    capacity = static_cast<int>(clock->sampleRate * OVERSAMPLING) * 3;

    samples.reserve(capacity);
    samples.assign (capacity, 0.F);
    
    set(kDelayMusicalTime, 4.F);
}

const float Delay::get(uint64_t parameter)
{
    switch (parameter)
    {
        case kDelayMix:
            return mix;
            
        case kDelayMusicalTime:
            return targetAsIndex;
            
        case kDelayFeedback:
            return feedback;
            
        case kDelayTimeInMs:
            return Assemble::Utilities::milliseconds(target, clock->sampleRate);

        default: return 0.0F;
    }
}

void Delay::set(uint64_t parameter, float value)
{
    switch (parameter)
    {
        case kStereoDelayToggle:
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
            const int time = (int) std::floorf(Assemble::Utilities::bound(value, 0.F, 4000.F));
            setInMilliseconds(time);
            break;
        }
        case kDelayMusicalTime:
        {
            targetAsIndex = static_cast<int>(value);
            const float time = parseMusicalTimeParameterIndex(targetAsIndex);
            setInMusicalTime(time);
            break;
        }
        case kDelayMix:
        {
            const float mix = Assemble::Utilities::bound(value, 0.F, 1.F);
            this->mix = mix;
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
        case 1:  return fDelayHalfDotted;
        case 2:  return fDelayHalfNote;
        case 3:  return fDelayEighthDotted;
        case 4:  return fDelayEighthNote;
        case 5:  return fDelayQuarterDotted;
        case 6:  return fDelayQuarterNote;
        case 7:  return fDelaySixteenthDotted;
        case 8:  return fDelaySixteenthNote;
        case 9:  return fDelayThirtySecondNote;
        case 10: return fDelaySixtyFourthNote;
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
    setInMusicalTime(time);
}

/// \brief Process the incoming sample
/// \param sample A sample to process

void Delay::process(float& sample)
{
    if (bpm != clock->bpm) update();
    
    if (bypassed) fadeOut();
    else           fadeIn();

    samples[whead] = gain * sample + feedback * samples[rhead];
    const float interpolated = Assemble::Utilities::hermite(rhead, samples.data(), capacity);

    whead = whead + 1;
    whead = static_cast<int>(whead < capacity) * whead;

    delay = delay + speed * (target - delay);
    rhead = whead - delay;
    while (rhead <  0)        rhead = rhead + capacity;
    while (rhead >= capacity) rhead = rhead - capacity;

    sample = (1.0F - gain * mix) * sample + mix * interpolated;
}

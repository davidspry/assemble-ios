//  Assemble
//  Created by David Spry on 24/4/20.
//  Copyright © 2020 David Spry. All rights reserved.

#include "Delay.hpp"

Delay::Delay(Clock *clock)
{
    bpm = clock->bpm;
    this->clock = clock;
    
    const float sampleRate = clock->sampleRate * (float) OVERSAMPLING;

    /// @brief Allocate enough space for the longest delay possible
    /// @note  1/1 + 25ms at 30bpm: 0.25 * (SR * OS) + (SR * OS) * 60 / 30bpm * 4 beats

    capacity = static_cast<int>(sampleRate * 8.25F);

    samples.reserve(capacity);
    samples.assign (capacity, 0.F);

    set(kDelayMusicalTime, 4.F);

    delay.setSampleRate(sampleRate);
    modulation.setSampleRate(sampleRate);
}

const float Delay::get(uint64_t parameter)
{
    switch (parameter)
    {
        case kDelayMix:
            return mix;
            
        case kDelayMusicalTime:
            return timeTargetIndex;
            
        case kDelayFeedback:
            return feedback.load();
            
        case kDelayModulation:
            return modulation.getTarget() - 1.0F;

        case kDelayTimeInMs:
        {
            const float target = delay.getTarget();
            const float sampleRate = clock->sampleRate * (float) OVERSAMPLING;
            return Assemble::Utilities::milliseconds(target, sampleRate);
        }

        default: return 0.0F;
    }
}

void Delay::set(uint64_t parameter, float value)
{
    switch (parameter)
    {
        case kStereoDelayToggle:
        {
            bypassed.store(static_cast<bool>(value));
            break;
        }
        case kDelayFeedback:
        {
            feedback.store(Assemble::Utilities::bound(value, 0.F, 1.F));
            break;
        }
        case kDelayModulation:
        {
            const float depth = Assemble::Utilities::bound(value, 0.F, 1.F);
            modulation.set(depth + 1.0F);
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
            timeTargetIndex = static_cast<int>(value);
            const float time = parseMusicalTimeParameterIndex(timeTargetIndex);
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
        case 3:  return fDelayQuarterDotted;
        case 4:  return fDelayQuarterNote;
        case 5:  return fDelayEighthDotted;
        case 6:  return fDelayEighthNote;
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
    const float sampleRate = clock->sampleRate * (float) OVERSAMPLING;
    offsetInSamples = Assemble::Utilities::samples(milliseconds, sampleRate);
    setInMusicalTime(time);
}

/// \brief Process the incoming sample
/// \param sample A sample to process

void Delay::process(float& sample)
{
    if (bpm != clock->bpm) update();

    if (bypassed) fadeOut();
    else           fadeIn();

    samples[whead] = gain * sample + feedback.load() * samples[rhead];
    const float interpolated = Assemble::Utilities::hermite(rhead, samples.data(), capacity);

    whead = whead + 1;
    whead = static_cast<int>(whead < capacity) * whead;

    rhead = whead - delay.get();
    rhead = rhead + scalar * (modulation.get() - 1.0F) * modulator.nextSample();
    while (rhead <  0)        rhead = rhead + capacity;
    while (rhead >= capacity) rhead = rhead - capacity;

    sample = (1.0F - gain * mix) * sample + mix * interpolated;
}

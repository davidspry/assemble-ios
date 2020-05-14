//  Assemble
//  ============================
//  Created by David Spry on 25/4/20.
//  Copyright © 2020 David Spry. All rights reserved.

#include "StereoDelay.hpp"

/// \brief Get the value of the Stereo Delay's parameters
/// \param parameter The hexadecimal address of the desired parameter

const float StereoDelay::get(uint64_t parameter)
{
    switch (parameter)
    {
        case kStereoDelayToggle: return static_cast<float>(!bypassed);
        case kStereoDelayLTime:  return ldelay.get(kDelayMusicalTime);
        case kStereoDelayRTime:  return rdelay.get(kDelayMusicalTime);
        default:                 return ldelay.get(parameter);
    }
}

/// \brief Set the parameters of the Stereo Delay
/// \param parameter The hexadecimal address of the parameter
/// \param value The value to set for the selected parameter

void StereoDelay::set(uint64_t parameter, const float value)
{
    switch (parameter)
    {
        case kStereoDelayToggle:
        {
            const bool status = static_cast<bool>(value);
            rdelay.toggle(status);
            ldelay.toggle(status);
            bypassed = !status;
            return;
        }

        case kDelayMix:
        case kDelayFeedback:
        case kDelayTimeInMs:
        case kDelayMusicalTime:
        case kDelayModulationDepth:
        case kDelayModulationSpeed:
        {
            ldelay.set(parameter, value);
            rdelay.set(parameter, value);
            return;
        }

        case kStereoDelayLTime: return ldelay.set(kDelayMusicalTime, value); return;
        case kStereoDelayRTime: return rdelay.set(kDelayMusicalTime, value); return;
        default: return;
    }
}

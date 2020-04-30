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
        case kDelayToggle:       return static_cast<float>(bypassed);
        case kDelayFeedback:     return ldelay.get(kDelayFeedback);
        case kStereoDelayLTime:  return ldelay.get(kDelayMusicalTime);
        case kStereoDelayRTime:  return rdelay.get(kDelayMusicalTime);
        default: return 0.F;
    }
}

/// \brief Set the parameters of the Stereo Delay
/// \param parameter The hexadecimal address of the parameter
/// \param value The value to set for the selected parameter

void StereoDelay::set(uint64_t parameter, const float value)
{
    switch (parameter)
    {
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

        case kDelayToggle: bypassed = (rdelay.toggle() && ldelay.toggle()); return;
        case kStereoDelayLTime: return ldelay.set(kDelayMusicalTime, value); return;
        case kStereoDelayRTime: return rdelay.set(kDelayMusicalTime, value); return;
        default: return;
    }
}

//  Assemble
//  Created by David Spry on 2/6/20.
//  Copyright © 2020 David Spry. All rights reserved.

#ifndef WHITENOISE_HPP
#define WHITENOISE_HPP

#include "ASHeaders.h"
#include <random>

/// \brief A white noise generator

class WhiteNoise
{
public:
    WhiteNoise()
    {
        std::uniform_real_distribution<float>::param_type range(-0.8F, 0.8F);
        distribution.param(range);
        twister.seed(rd());
    }

    const float nextSample()
    {
        return distribution(twister);
    }

private:
    std::mt19937 twister;
    std::random_device rd;
    std::uniform_real_distribution<float> distribution;
};

#endif

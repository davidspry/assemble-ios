//  Assemble
//  ============================
//  Created by David Spry on 24/4/20.
//  Copyright © 2020 David Spry. All rights reserved.

#ifndef ASUTILITIES_H
#define ASUTILITIES_H

#include "ValueTransition.hpp"

namespace Assemble::Utilities
{
    /// \brief Convert samples at the given frequency to milliseconds
    /// \param samples The number of samples whose duration in milliseconds should be computed
    /// \param frequency The frequency of the samples, or the sampling rate
    /// \return The number of milliseconds spanned by the given number samples at the given frequency

    static inline const int milliseconds(int samples, float frequency)
    {
        return samples / frequency * 1e3f;
    }

    /// \brief Convert milliseconds to samples at the given frequency
    /// \param milliseconds The number of milliseconds whose duration in samples should be computed
    /// \param frequency The frequency of the samples, or the sampling rate
    /// \return The number of samples at the given frequency required to span the given number of milliseconds

    static inline const int samples(int milliseconds, float frequency)
    {
        return milliseconds * frequency * 1e-3f;
    }

    /// \brief Compute linear interpolation at the given index in the given table
    /// \param index The position in the table to interpolate a value for
    /// \param table A pointer to an array of floats
    /// \param capacity The capacity of the table

    static inline const float lerp(const float index, const float *table, const int capacity)
    {
        const int l = (int) index;
        const int r = l + 1 - static_cast<int>((l + 1) >= capacity) * capacity;
        const float t = index - l;
        
        const float a = table[l];
        const float b = table[r];

        return a + t * (b - a);
    }

    /// \brief Return the input value bounded by the range [min, max].
    /// \param input The value to be bounded by the given range
    /// \param min The minimum value of the output range, inclusive.
    /// \param max The maximum value of the output range, inclusive.

    static inline const float bound(const float input, const float min, const float max)
    {
        return std::fmax(min, std::fmin(max, input));
    }
};

#endif

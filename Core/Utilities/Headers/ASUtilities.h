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

    [[nodiscard]] static inline const float lerp(const float index, const float *table, const int capacity)
    {
        const int l = (int) index;
        const int r = l + 1 - static_cast<int>((l + 1) >= capacity) * capacity;
        const float t = index - l;
        
        const float a = table[l];
        const float b = table[r];

        return a + t * (b - a);
    }

    /// \brief Compute four-point, fourth-order Hermite interpolation
    /// \param index The position in the table to interpolate a value for
    /// \param table A pointer to an array of floats
    /// \param capacity The capacity of the table
    /// \author Laurent de Soras

    [[nodiscard]] static inline const float hermite(const float index, const float *table, const int capacity)
    {
        const int   a = (int) index;
        const float k = index - a;
        
        const float xa = table[a];
        const float xb = table[(a - 1 + capacity) % capacity];
        const float xc = table[(a + 1) % capacity];
        const float xd = table[(a + 2) % capacity];
        
//        const float xb = table[a - 1 + static_cast<int>((a - 1) <  0) * capacity];
//        const float xc = table[a + 1 - static_cast<int>((a + 1) >= capacity) * capacity];
//        const float xd = table[a + 2 - static_cast<int>((a + 2) >= capacity) * capacity];
        
        const float C = (xc - xb) * 0.5F;
        const float V = (xa - xc);
        const float W = C + V;
        const float A = W + V + (xd - xa) * 0.5F;
        const float B = W + A;

        return ((((A * k) - B) * k + C) * k + xa);
    }

    /// \brief Compute Catmull-Rom cubic interpolation at the given index in the given table
    /// \param index The position in the table to interpolate a value for
    /// \param table A pointed to an array of floats
    /// \param capacity The capacity of the table

    [[nodiscard]] static inline const float cerp(const float index, const float *table, const int capacity)
    {
        const int a = (int) index;
        const int b = a + 1 - static_cast<int>((a + 1) >= capacity) * capacity;
        const int c = b + 1 - static_cast<int>((b + 1) >= capacity) * capacity;
        const int d = a - 1 + capacity - static_cast<int>((a - 1 + capacity) >= capacity) * capacity;
        const float t = index - a;
        const float T = t * t;
        
        const float A = -0.5F * table[d] + 1.5F * table[a] - 1.5F * table[b] + 0.5F * table[c];
        const float B = table[d] - 2.5F * table[a] + 2.0F * table[b] - 0.5F * table[c];
        const float C = -0.5F * table[d] + 0.5F * table[b];
        const float D = table[a];
        
        return A * t * T + B * T + C * t + D;
    }

    /// \brief Return the input value bounded by the range [min, max].
    /// \param input The value to be bounded by the given range
    /// \param min The minimum value of the output range, inclusive.
    /// \param max The maximum value of the output range, inclusive.

    [[nodiscard]] static inline const float bound(const float input, const float min, const float max)
    {
        return std::fmax(min, std::fmin(max, input));
    }
};

#endif

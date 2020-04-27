//  Assemble
//  Created by David Spry on 3/4/20.

#include "HuovilainenFilter.hpp"

/// \brief Fill an array with floats

inline void set(const float element, const size_t length, float *array)
{
    for (size_t i = 0; i < length; ++i)
        array[i] = element;
}

void HuovilainenFilter::initialise()
{
    ::set(0.F, stage.size(), stage.data());
    ::set(0.F, delay.size(), delay.data());
    ::set(0.F, tanhStage.size(), tanhStage.data());

    thermal = 25E-6F;
    set(12E3F, 0.F);
}

/// \brief Get a parameter value from the Huovilainen Filter
/// \pre The parameter address must belong to the Huovilainen Filter type (0xF0).
/// For the sake of efficiency, this is not being checked.

const float HuovilainenFilter::get(uint64_t parameter)
{
    const int subtype = (int) parameter % 16;
    switch (subtype)
    {
        case 0:  return targetFrequency;
        case 1:  return targetResonance;
        default: return 0.F;
    }
}

/// \brief Set the parameters of the Huovilainen Filter
/// \pre The parameter address must belong to the Huovilainen Filter type (0xF0).
/// For the sake of effficiency, this is not being checked.
/// \note All continuous parameters are modified by interface components whose
/// range is [0, 1] in the Swift context. In order to map this range to the frequency
/// of the filter, which is [20Hz, 20kHz], the function e ** [ln(20) + x * (ln(20e3) - ln(20)] is used.
/// The natural logs of 20 and 20,000 are defined as macros in ASConstants.h.

void HuovilainenFilter::set(uint64_t parameter, float value)
{
    const int subtype = (int) parameter % 16;
    switch (subtype)
    {
        case 1: targetResonance.store(value); return;
        case 0:
        {
            const float map = std::exp(LN20 + value * (LN20E3 - LN20));
            targetFrequency.store(map);
            return;
        }
        default: return;
    }
}

/// \brief Return an approximation of the tanh function that reduces some number of calculations.
/// \author John Fitch

float HuovilainenFilter::quicktanh(float x)
{
    float sign = x < 0 ? -1.F : 1.F;
    
    x = std::abs(x);
    if (x >= 4.F) return sign;
    if (x <  0.5) return sign * x;
    return sign * std::tanh(x);
}

void HuovilainenFilter::set(const float cutoff, const float resonance)
{
    this->frequency = std::fmax(0.F, cutoff);
    this->resonance = std::fmax(0.F, std::fmin(resonance, 1.F));

    const float FS = cutoff / sampleRate;
    const float OS = FS * 0.5;
    const float FF = FS * FS;
    const float FFF = FF * FS;
    const float FCR = 1.873 * FFF + 0.4955 * FF - 0.649 * FS + 0.9988;
    
    A = -3.9364 * FF + 1.8409 * FS + 0.9968;
    G = (1.F - std::exp(-(TWO_PI * OS * FCR))) / thermal;
    resonanceFour = 4.F * resonance * A;
}

const float HuovilainenFilter::process(float sample)
{
    float W, E = 1.F;

    if (ahr != nullptr) E = ahr->nextSample();
    
    set(E * targetFrequency, E * targetResonance);

    for (size_t oversampling = 0; oversampling < 1; ++oversampling)
    {
        sample = sample - resonanceFour * delay[5];
        delay[0] = delay[0] + G * (quicktanh(sample * thermal) - tanhStage[0]);
        stage[0] = delay[0];
        
        for (size_t k = 1; k < 4; ++k)
        {
            sample = stage[k-1];
            tanhStage[k-1] = quicktanh(sample * thermal);
            W = k != 3 ? tanhStage[k] : quicktanh(delay[k] * thermal);
            stage[k] = delay[k] + G * (tanhStage[k-1] - W);
            delay[k] = stage[k];
        }

        delay[5] = 0.5 * (stage[3] + delay[4]);
        delay[4] = stage[3];
    }
    
    return delay[5];
}

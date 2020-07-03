//  Assemble
//  Created by David Spry on 3/4/20.

#include "HuovilainenFilter.hpp"

void HuovilainenFilter::initialise()
{
    std::fill(stage.begin(), stage.end(), 0.F);
    std::fill(delay.begin(), delay.end(), 0.F);
    std::fill(tanhStage.begin(), tanhStage.end(), 0.F);

    targetFrequencyNormal.store(1.0F);
    set(20E3F, 1.0F);
}

/// \brief Get a parameter value from the Huovilainen Filter
/// \pre The parameter address must belong to the Huovilainen Filter type (0xF0).
/// For the sake of efficiency, this is not being checked.

const float HuovilainenFilter::get(uint64_t parameter)
{
    const int subtype = (int) parameter % 16;
    switch (subtype)
    {
        case 0:  return targetFrequencyNormal;
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
/// The input value is stored in `targetFrequencyNormal` for later retrieval.

void HuovilainenFilter::set(uint64_t parameter, float value)
{
    value = Assemble::Utilities::bound(value, 0.0F, 1.0F);
    const int subtype = (int) parameter % 16;
    switch (subtype)
    {
        case 1: targetResonance.store(value); return;
        case 0:
        {
            const float map = std::exp(LN100 + value * (LN20E3 - LN100));
            targetFrequencyNormal.store(value);
            targetFrequency.store(map);
            return;
        }

        default: return;
    }
}

/// \brief An approximation of the tanh function.
/// \author John Fitch

float HuovilainenFilter::quicktanh(float x)
{
    float sign = x < 0 ? -1.F : 1.F;
    
    x = std::abs(x);
    if (x >= 4.0F) return sign;
    if (x <  0.5F) return sign * x;
    return sign * std::tanh(x);
}

void HuovilainenFilter::set(const float frequency, const float resonance)
{
    this->frequency = Assemble::Utilities::bound(frequency, 0.F, 20E3F);
    this->resonance = Assemble::Utilities::bound(resonance, 0.F, 1.00F);

    const float cutoff = frequency / sampleRate;
    const float oversampledCutoff = cutoff * 0.5F;
    const float cutoffSquared = cutoff * cutoff;
    const float cutoffCubed = cutoffSquared * cutoff;
    const float F = 1.873F * cutoffCubed + 0.4955F * cutoffSquared - 0.649F * cutoff + 0.9988F;

    A = -3.9364F * cutoffSquared + 1.8409F * cutoff + 0.9968F;
    G = (1.F - std::exp(-(TWO_PI * oversampledCutoff * F))) / thermal;
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

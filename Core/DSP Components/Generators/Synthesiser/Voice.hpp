//  Assemble
//  Created by David Spry on 26/2/20.
//  Copyright © 2020 David Spry. All rights reserved.

#ifndef VOICE_HPP
#define VOICE_HPP

#include "Oscillator.hpp"
#include "WhiteNoise.hpp"
#include "AHREnvelope.hpp"
#include "HuovilainenFilter.hpp"

/// \brief A Synthesiser Voice, which is comprised of a BandlimitedOscillator, an amplitude envelope, a filter envelope, and a Huovilainen lowpass filter.

class Voice
{
public:
    Voice();
    
public:
    /// \brief Set the frequency of the underlying Oscillator
    /// \param frequency The frequency to load in Hertz

    void load(const float frequency);
    
    /// \brief Poll the Voice for its next sample

    const float nextSample();

public:
    /// \brief Assign an Oscillator to the Voice.
    /// \param osc The Oscillator that should correspond with the Voice.

    inline void assign(Oscillator* osc)
    {
        this->osc = osc;
    }
    
    /// \brief Get the parameter values of the Voice.
    /// \param parameter The hexadecimal address of the desired parameter

    const float get(uint64_t parameter);
    
    /// \brief Set the parameters of the Voice.
    /// \param parameter The hexadecimal address of the parameter to set
    /// \param value The value to set for the parameter

    void set(uint64_t parameter, float value);
    
    /// \brief Set the sample rate of the Voice.
    /// Any changes to the sample rate are propagated to associated components.
    /// \param sampleRate The sample rate to set

    void setSampleRate(float sampleRate);

protected:
    Oscillator        *osc;
    WhiteNoise       noise;
    AHREnvelope   vca, vcf;
    HuovilainenFilter  lpf = {&vcf};
    
private:
    std::atomic<float> noiseGain = {0.0F};
    constexpr static float noiseUpperBound = 0.35F;
    
};

#endif

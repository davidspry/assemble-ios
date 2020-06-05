//  Assemble
//  ============================
//  Created by David Spry on 10/4/20.
//--------------------------------------------------------
//  The release function is based on a post by 'Guest':
//  Post:  <https://dsp.stackexchange.com/a/47419>
//  Graph: <https://www.desmos.com/calculator/nduy9l2pez>
//--------------------------------------------------------

#ifdef __cplusplus
#pragma once

#include "ASHeaders.h"
#include "ASUtilities.h"

class AHREnvelope
{
public:
    AHREnvelope()
    {
        set(5, 0, 500);
    }

    AHREnvelope(const int attack, const int hold, const int release)
    {
        set(attack, hold, release);
    }

public:
    void prepare();
    const float nextSample();

public:
    /// \brief  Compute the inverse function of the attack curve
    /// \return The time value that corresponds with the envelope's
    /// current amplitude value.

    inline const int computeTimeOnRetrigger()
    {
        return attackInSamples * std::cbrt(amplitude);
    }

public:
    const float get(uint64_t parameter);
    void set(uint64_t parameter, float value);
    void set(float attack, float hold, float release);
    void setSampleRate(float sampleRate);
    
private:
    enum Mode { Attack, Hold, Release, Closed, Recovery };
    Mode mode = Closed;
    
public:
    const bool closed() { return mode == Closed; }
    
private:
    inline void setMode(Mode mode) { this->mode = mode; }
    inline double computeAttack(int & time);
    inline double computeRelease(int & time);

private:
    int time;
    int attackInMs, holdInMs, releaseInMs;
    int attackInSamples, holdInSamples, releaseInSamples;

private:
    float amplitude  = 0.F;
    float sampleRate = 48000.F;
};

#endif

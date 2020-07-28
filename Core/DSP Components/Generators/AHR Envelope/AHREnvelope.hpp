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

/// \brief An amplitude envelope with three phases whose durations are defined in milliseconds.

class AHREnvelope
{
public:
    /// \brief Initailise an envelope with default values A: 5, H: 0, R: 500

    AHREnvelope()
    {
        set(5, 0, 500);
    }

    /// \brief Initialise an envelope with the given AHR values.
    /// \param attack The duration of the attack phase in milliseconds.
    /// \param hold The duration of the hold phase in milliseconds.
    /// \param release The duration of the release phase in milliseconds.

    AHREnvelope(const int attack, const int hold, const int release)
    {
        set(attack, hold, release);
    }

public:
    /// \brief Prepare the envelope to begin a new cycle
    /// If the envelope is not closed, compute the inverse function
    /// of the attack curve in order to begin the envelope's phase
    /// with a time value that corresponds to its current amplitude.

    void prepare();
    
    /// \brief Compute the inverse function of the attack curve in order to yield
    /// the time value that will maintain the current amplitude. This should be called
    /// if the envelope is retriggered before it has closed.
    /// \return The time value that corresponds with the envelope's current amplitude value.

    inline const int computeTimeOnRetrigger()
    {
        return (int) ((double) attackInSamples * std::cbrt(amplitude));
    }
    
    /// \brief Compute the inverse function of the release curve in order to yield
    /// the time value that will maintain the current amplitude. This should be called
    /// if the envelope's properties are changed and an envelope in its attack phase
    /// should enter its release phase.
    /// \return The time value for the release curve that corresponds with the envelope's current amplitude value.

    inline const int computeReleaseInverse()
    {
        return (int) ((double) releaseInSamples - (double) releaseInSamples * std::cbrt(amplitude));
    }
    
    /// \brief Indicate whether the envelope is closed or not.
    
    const bool closed() { return mode == Closed; }
    
    /// \brief Compute the next sample from the envelope
    /// \return A value in the range [0, 1] representing the openness of the envelope

    const float nextSample();

    /// \brief Get the parameter values of the AHREnvelope.
    /// Specifically, these are the attack, hold, and releaes times in milliseconds.
    /// \param parameter The hexadecimal address of the desired parameter
    
    const float get(uint64_t parameter);
    
    /// \brief Set the parameter values of the AHREnvelope.
    /// \param parameter The hexadecimal address of the desired parameter
    /// \param value The value to set for the given parameter

    void set(uint64_t parameter, float value);
    
    /// \brief Set the attack, hold, and release times for the envelope in milliseconds.
    /// \param attack The duration the attack phase in milliseconds.
    /// \param hold The duration the hold phase in milliseconds.
    /// \param release The duration the release phase in milliseconds.

    void set(float attack, float hold, float release);
    
    /// \brief Set the sample rate of the envelope, then recompute the duration of each phase.
    /// \param sampleRate The sample rate to use

    void setSampleRate(float sampleRate);
    
private:
    /// \brief Constants defining the available envelope phases

    enum Mode { Attack, Hold, Release, Closed, Recovery };
    
    /// \brief The envelope's current mode

    Mode mode = Closed;

    /// \brief Set the current mode of the envelope
    /// \param mode The mode to enter

    inline void setMode(Mode mode) { this->mode = mode; }

    /// \brief Compute the attack function at the given time value
    /// \param time The current time value in samples
    
    inline const float computeAttack(uint time);
    
    /// \brief Compute the release function at the given time value
    /// \param time The current time value in samples
    
    inline const float computeRelease(uint time);

private:
    std::atomic<uint> time = {0};
    std::atomic<bool> shouldUpdate = {false};

private:
    int  attackInMs, holdInMs, releaseInMs;
    int  attackInSamples, holdInSamples, releaseInSamples;

private:
    float amplitude  = 0.0F;
    float sampleRate = 48000.F;
};

#endif

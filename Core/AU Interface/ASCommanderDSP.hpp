//  Assemble
//  ============================
//  Modified by: David Spry.
//  Original author: Shane Dunne.
//  Copyright 2018 AudioKit. All rights reserved.
//  License: <https://github.com/AudioKit/AudioKit/blob/master/LICENSE>

#pragma once

#import <AVFoundation/AVFoundation.h>

// ============================================================ //
// ============ Swift interface to ASCommanderDSP ============= //
// ============================================================ //

#ifndef __cplusplus

/// \brief Allocate an ASCommanderDSP on the heap and return a void pointer.

ASDSPRef makeASCommanderDSP(int channels, double sampleRate);

/// \brief Load a note in the synthesiser immediately

void __interop__LoadNote(ASDSPRef, const int note, const int shape);

/// \brief Add a note to the sequencer

void __interop__WriteNote(ASDSPRef, const int x, const int y, const int note, const int shape);

/// \brief Remove a note from the sequencer

void __interop__EraseNote(ASDSPRef, const int x, const int y);

/// \brief Pass an encoded state string for the pattern that matches the given pattern number to the core for loading.

void __interop__LoadPatternState(ASDSPRef, const char* state, const int pattern);

/// \brief Prompt the core to encode the current state of the pattern matching the given pattern number and return a pointer to the string

const char* __interop__GetPatternState(ASDSPRef, const int pattern);

/// \brief Play or pause the sequencer by toggling the state of the clock

const bool  __interop__PlayOrPause(ASDSPRef);

const void  __interop__ClearCurrentPattern(ASDSPRef);

#else

// ============================================================ //

#include "ASDSPBase.hpp"
#include "ASCommanderCore.hpp"

/// \brief ASCommanderDSP represents the layer that performs all real-time audio work. A void pointer to this struct
/// is owned by the ASAudioUnit instance for the purpose of facilitating communication from the Swift context
/// down to the C/C++ context. The C functions above allow the Swift context to call functions in the C++ core
/// virtually directly.

struct ASCommanderDSP : ASDSPBase, ASCommanderCore
{
    ASCommanderDSP() : ASCommanderCore() {}
    
    /// \brief Initialise the ASDSPBase and the ASCommanderCore
    /// \param channelCount The number of output channels to serve
    /// \param sampleRate The sample rate to use

    void init(int channelCount, double sampleRate) override;
    
    /// \brief Indicate whether the underlying clock is ticking or not

    bool isPlaying() override;

    /// \brief Return the state of a parameter
    /// \param address The hexadecimal address of the desired parameter

    float getParameter(uint64_t address) override;
    
    /// \brief Set the value of a parameter
    /// \param address The hexadecimal address of the desired parameter
    /// \param value The target value
    /// \param immediate Whether the change should occur immediately or gradually. However, this argument is not used.

    void setParameter(uint64_t address, float value, bool immediate) override;
    
    /// \brief Render the requested number of sample frames accounting for the given buffer offset.
    /// \param frameCount The number of sample frames to render
    /// \param bufferOffset An offset of some number of sample frames from the beginning of each channel's buffer

    void process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) override;
};

#endif

//  Assemble
//  ============================
//  Original author: Shane Dunne.
//  Copyright 2018 AudioKit. All rights reserved.
//  License: <https://github.com/AudioKit/AudioKit/blob/master/LICENSE>

#import "ASCommanderDSP.hpp"

// ============================================================ //
// ============ Swift interface to ASCommanderDSP ============= //
// ============================================================ //

extern "C" void * makeASCommanderDSP(int channels, double sampleRate)
{
    return new ASCommanderDSP();
}

extern "C" const bool __interop__PlayOrPause(void *DSP)
{
    return ((ASCommanderDSP*) DSP)->playOrPause();
}

extern "C" const bool __interop__ToggleMode(void *DSP)
{
    return ((ASCommanderDSP*) DSP)->toggleMode();
}

extern "C" void __interop__LoadNote(void *DSP, const int note, const int shape)
{
    ((ASCommanderDSP*) DSP)->loadNote(note, shape);
}

extern "C" void __interop__WriteNote(void *DSP, const int x, const int y, const int note, const int shape)
{
    ((ASCommanderDSP*) DSP)->writeNote(x, y, note, shape);
}

extern "C" void __interop__EraseNote(void *DSP, const int x, const int y)
{
    ((ASCommanderDSP*) DSP)->eraseNote(x, y);
}

extern "C" const char* __interop__GetPatternState(void *DSP, const int pattern)
{
    return ((ASCommanderDSP*) DSP)->encodePatternState(pattern);
}

extern "C" void __interop__LoadPatternState(void *DSP, const char* state, const int pattern)
{
    ((ASCommanderDSP*) DSP)->loadFromEncodedPatternState(state, pattern);
}

// ============================================================ //

void ASCommanderDSP::init(int channels, double sampleRate)
{
    ASDSPBase::init(channels, sampleRate);
    ASCommanderCore::init(sampleRate);
}

bool ASCommanderDSP::isPlaying()
{
    return ASCommanderCore::clockIsTicking();
}

void ASCommanderDSP::setParameter(uint64_t parameter, float value, bool immediate)
{
    ASCommanderCore::set(parameter, value);
}

float ASCommanderDSP::getParameter(uint64_t parameter)
{
    return ASCommanderCore::get(parameter);
}

void ASCommanderDSP::process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset)
{
    const auto channels = outBufferListPtr->mNumberBuffers;
    
    float *output[channels];
    for (auto c = 0; c < channels; ++c)
        output[c] = (float *) outBufferListPtr->mBuffers[c].mData + bufferOffset;
    
    ASCommanderCore::render(channels, frameCount, output);
}

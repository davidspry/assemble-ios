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

extern "C" const bool __interop__IsTicking(void *DSP)
{
    return ((ASCommanderDSP*) DSP)->clockIsTicking();
}

extern "C" const bool __interop__PlayOrPause(void *DSP)
{
    return ((ASCommanderDSP*) DSP)->playOrPause();
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

extern "C" void __interop__SetParameter(void *DSP, uint32_t parameter, float value)
{
    ((ASCommanderDSP*) DSP)->setParameter(parameter, value, true);
}

extern "C" float __interop__GetParameter(void *DSP, uint32_t parameter)
{
    return ((ASCommanderDSP*) DSP)->getParameter(parameter);
}

// ============================================================ //

void ASCommanderDSP::init(int channels, double sampleRate)
{
    ASDSPBase::init(channels, sampleRate);
    ASCommanderCore::init(sampleRate);
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
    
    float *output[2];
    output[0] = (float *) outBufferListPtr->mBuffers[0].mData + bufferOffset;
    output[1] = (float *) outBufferListPtr->mBuffers[1].mData + bufferOffset;
    
    ASCommanderCore::render(channels, frameCount, output);
}

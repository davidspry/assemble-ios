//  Assemble
//  ============================
//  Original author: Andrew Voelkel.
//  Copyright 2018 AudioKit. All rights reserved.
//  License: <https://github.com/AudioKit/AudioKit/blob/master/LICENSE>

#pragma once
#ifdef __cplusplus

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import <algorithm>
#import <string>

#include "ASInteroperability.h"

class ASDSPBase
{
public:
    virtual ~ASDSPBase() {}
    
    virtual void init(int channels, double sampleRate)
    {
        this->channels = channels;
        this->sampleRate = sampleRate;
    }

    virtual bool isPlaying() = 0;
    
    virtual bool isSetup()   { return isInitialized; }

    virtual void process(AUAudioFrameCount, AUAudioFrameCount) = 0;

    void processWithEvents(AudioTimeStamp const *, AUAudioFrameCount, AURenderEvent const *);

    virtual void setParameter(AUParameterAddress, float, bool immediate = false) {}
    
    virtual float getParameter(AUParameterAddress) = 0;
    
    virtual void setBuffer(AudioBufferList *out) { outBufferListPtr = out; }
    
    virtual void setBuffers(AudioBufferList *input, AudioBufferList *output)
    {
        inBufferListPtr = input;
        outBufferListPtr = output;
    }

private:
    void handleOneEvent(AURenderEvent const *);
    void performAllSimultaneousEvents(AUEventSampleTime, AURenderEvent const *&);
    
protected:
    int channels;
    double sampleRate;
    
    AUEventSampleTime now = 0;
    AudioBufferList *inBufferListPtr = nullptr;
    AudioBufferList *outBufferListPtr = nullptr;

    bool isInitialized = true;
    std::string teststring;
};

#endif

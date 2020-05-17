//  Assemble
//  ============================
//  Original author: Andrew Voelkel.
//  Copyright 2018 AudioKit. All rights reserved.
//  License: <https://github.com/AudioKit/AudioKit/blob/master/LICENSE>

#include "ASDSPBase.hpp"

void ASDSPBase::processWithEvents(AudioTimeStamp const *timestamp, AUAudioFrameCount frameCount, AURenderEvent const *events)
{
    now = timestamp->mSampleTime;
    AURenderEvent const *event = events;
    AUAudioFrameCount framesRemaining = frameCount;

    while (framesRemaining > 0)
    {
        if (event == nullptr)
        {
            AUAudioFrameCount const bufferOffset = frameCount - framesRemaining;
            process(framesRemaining, bufferOffset);
            return;
        }

        const auto zero = AUEventSampleTime(0);
        const auto headEventTime = event->head.eventSampleTime;
        AUAudioFrameCount const framesThisSegment = AUAudioFrameCount(std::max(zero, headEventTime - now));

        if (framesThisSegment > 0)
        {
            AUAudioFrameCount const bufferOffset = frameCount - framesRemaining;
            process(framesThisSegment, bufferOffset);
            now += framesThisSegment;
            framesRemaining -= framesThisSegment;
        }

        performAllSimultaneousEvents(now, event);
    }
}

void ASDSPBase::performAllSimultaneousEvents(AUEventSampleTime now, AURenderEvent const *& event)
{
    do
    {
        handleOneEvent(event);
        event = event->head.next;
    }
    
    while (event != nullptr && event->head.eventSampleTime <= now);
}

void ASDSPBase::handleOneEvent(AURenderEvent const * event)
{
    switch (event->head.eventType)
    {
        case AURenderEventParameter:
        case AURenderEventParameterRamp:
        default: break;
    }
}

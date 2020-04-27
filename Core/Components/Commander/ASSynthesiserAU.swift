//  ASMOscillator.swift
//  Assemble
//
//  Created by Aurelius Prochazka
//  Copyright 2018 AudioKit. All rights reserved.
//  License: <https://github.com/AudioKit/AudioKit/blob/master/LICENSE>

import AVFoundation

public class ASCommanderAU : ASAudioUnit
{
    public override var canProcessInPlace: Bool { return true }
    
    public override func shouldAllocateInputBus() -> Bool { return false }
    
    public override func initDSP(withSampleRate sampleRate: Double, channelCount count: AVAudioChannelCount) -> ASDSPRef
    {
        return createASSynthesiserDSP(Int32(count), sampleRate)
    }

    override init(componentDescription: AudioComponentDescription,
                  options: AudioComponentInstantiationOptions = []) throws
    {
        try super.init(componentDescription: componentDescription, options: options);
    }
    
    public func playNote(note: Int, frequency: Float, shape: Int)
    {
        doPlayNote(dsp, Int32(note), frequency, Int32(shape))
    }
    
    public func getCurrentRow() -> Int {
        return Int(getParameter(dsp, Int32(0xFA)))
    }
    
    public override func setParameterImmediatelyWithAddress(_ address: AUParameterAddress, value: AUValue) {
        setFilter(dsp, Int32(address), Float(value))
    }
    
    public override func shouldClearOutputBuffer() -> Bool
    {
        return true
    }
}

//  Assemble
//  ============================
//  Original author: Aurelius Prochazka.
//  Copyright 2018 AudioKit. All rights reserved.
//  License: <https://github.com/AudioKit/AudioKit/blob/master/LICENSE>

import AVFoundation

public class ASCommanderAU : ASAudioUnit
{
    public override var canProcessInPlace: Bool           { return true  }
    
    public override func shouldAllocateInputBus() -> Bool { return false }
    
    public override var supportsUserPresets: Bool         { return true  }

    public var length: Int {
        return Int(__interop__GetParameter(dsp, kSequencerLength))
    }
    
    /**
     Initialise the DSP layer for the specified number of channels and the given sample rate.
     - Parameter sampleRate: The sample rate of the DSP layer
     - Parameter count: The number of channels required
     */
    public override func initDSP(withSampleRate sampleRate: Double,
                                 channelCount count: AVAudioChannelCount) -> ASDSPRef {
        return makeASCommanderDSP(Int32(count), sampleRate)
    }

    override init(componentDescription: AudioComponentDescription,
                  options: AudioComponentInstantiationOptions = []) throws {
        try super.init(componentDescription: componentDescription, options: options);
    }
    
    public func playOrPause() -> Bool
    {
        return __interop__PlayOrPause(dsp)
    }
    
    public func isTicking() -> Bool
    {
        return __interop__IsTicking(dsp)
    }

    public func playNote(note: Int, shape: Int) {
        __interop__LoadNote(dsp, Int32(note), Int32(shape))
    }
    
    public func addNote(x: Int, y: Int, note: Int, shape: Int) {
        __interop__WriteNote(dsp, Int32(x), Int32(y), Int32(note), Int32(shape))
    }
    
    public func eraseNote(x: Int, y: Int) {
        __interop__EraseNote(dsp, Int32(x), Int32(y))
    }

    public func getCurrentRow() -> Int {
        return Int(__interop__GetParameter(dsp, kSequencerCurrentRow))
    }
    
    public func getCurrentPattern() -> Int {
        return Int(__interop__GetParameter(dsp, kSequencerCurrentPattern))
    }
    
    public func getParameterWithAddress(_ address: Int32) -> Float {
        return __interop__GetParameter(dsp, address)
    }
    
    public func setParameterWithAddress(_ address: Int32, value: AUValue) {
        __interop__SetParameter(dsp, address, value)
    }
    
    public override func shouldClearOutputBuffer() -> Bool {
        return true
    }
}

//  Assemble
//  ============================
//  Original author: Aurelius Prochazka.
//  Copyright 2018 AudioKit. All rights reserved.
//  License: <https://github.com/AudioKit/AudioKit/blob/master/LICENSE>

import AVFoundation
 
public class ASCommanderAU : ASAudioUnit
{
    public override var canProcessInPlace: Bool           { return true  }
    
    public override var supportsUserPresets: Bool         { return true  }
    
    public override func shouldAllocateInputBus() -> Bool { return false }

    public var length: Int {
        return Int(parameter(withAddress: AUParameterAddress(kSequencerLength)))
    }
    
    public var currentRow: Int {
        return Int(parameter(withAddress: AUParameterAddress(kSequencerCurrentRow)))
    }
    
    public var currentPattern: Int {
        return Int(parameter(withAddress: AUParameterAddress(kSequencerCurrentPattern)))
    }
    
    public var ticking: Bool {
        return isPlaying;
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
        
        
//        print(userPresets)
//        let newPreset = AUAudioUnitPreset()
//        newPreset.name = "Test number 2"
//        newPreset.number = -2
//        do { try saveUserPreset(newPreset); print("Woohoo!") }
//        catch { print("Failed to save! \(error)") }
//
//        userPresets.forEach( {print($0.name) } )
        
    }
    
    public func playOrPause() -> Bool
    {
        return __interop__PlayOrPause(dsp)
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
    
    public override func shouldClearOutputBuffer() -> Bool {
        return true
    }
}

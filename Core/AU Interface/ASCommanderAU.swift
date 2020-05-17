//  Assemble
//  ============================
//  Copyright © 2020 David Spry. All rights reserved.

import CoreAudio
import AVFoundation

public class ASCommanderAU : ASAudioUnit
{
    /// The number of rows in the current pattern
    
    public var length: Int {
        return Int(parameter(withAddress: AUParameterAddress(kSequencerLength)))
    }

    /// The current row number
    
    public var currentRow: Int {
        return Int(parameter(withAddress: AUParameterAddress(kSequencerCurrentRow)))
    }
    
    /// The current pattern number

    public var currentPattern: Int {
        return Int(parameter(withAddress: AUParameterAddress(kSequencerCurrentPattern)))
    }
    
    /// The state of the underlying clock

    public var ticking: Bool {
        return isPlaying;
    }
    
    /// The current mode of the sequencer. This property will return`0` during Pattern Mode, and `1` during Song Mode.

    public var mode: Float {
        return parameter(withAddress: AUParameterAddress(kSequencerMode))
    }

    /// Initialise the DSP layer for the specified number of channels and the given sample rate.
    /// - Parameter sampleRate: The sample rate of the DSP layer
    /// - Parameter count: The number of channels required

    public override func initDSP(withSampleRate sampleRate: Double,
                                 channelCount count: AVAudioChannelCount) -> ASDSPRef {
        return makeASCommanderDSP(Int32(count), sampleRate)
    }

    /// Instantiate an AudioUnit
    override init(componentDescription: AudioComponentDescription,
                  options: AudioComponentInstantiationOptions = []) throws {
        try super.init(componentDescription: componentDescription, options: options);

        /// Create an `AUParameterTree` comprised of `AUParameterGroup` nodes,
        /// which are defined in `ASCommanderAUParameters.swift`

        let tree = AUParameterTree.createTree(withChildren:
        [
            ASCommanderAUParameters.parametersClock,
            ASCommanderAUParameters.parametersSine,
            ASCommanderAUParameters.parametersSquare,
            ASCommanderAUParameters.parametersTriangle,
            ASCommanderAUParameters.parametersSawtooth,
            ASCommanderAUParameters.parametersFilter,
            ASCommanderAUParameters.parametersDelay,
            ASCommanderAUParameters.parametersVibrato
        ])

        setParameterTree(tree)
        
        /// Observe changes to parameter values
        /// - SeeAlso: https://developer.apple.com/documentation/audiotoolbox/creating_custom_audio_effects

        tree.implementorValueObserver = { parameter, value in
            self.setParameterWithAddress(parameter.address, value: value)
        }
        
        /// Return the state of a requested parameter
        /// - SeeAlso: https://developer.apple.com/documentation/audiotoolbox/creating_custom_audio_effects

        tree.implementorValueProvider = { parameter in
            return self.parameter(withAddress: parameter.address)
        }
        
        /// Return a String representation of a requested parameter
        /// - SeeAlso: https://developer.apple.com/documentation/audiotoolbox/creating_custom_audio_effects
        
        tree.implementorStringFromValueCallback = { parameter, value in
            return String(format: "%.2f", value ?? parameter.value)
        }

        userPresets.forEach { print("User Preset: Name: \($0.name), Number: \($0.number)") }
    }
    
    /// Play or pause the sequencer by toggling the state of the underlying clock.
    /// - Returns: `true` if the clock begins to tick; `false` otherwise

    public func playOrPause() -> Bool {
        return __interop__PlayOrPause(dsp)
    }

    /// Play a note using the given oscillator shape immediately
    /// - Parameter note:  The pitch of the note to play as a MIDI note number
    /// - Parameter shape: The index of the oscillator to use.

    public func playNote(note: Int, shape: Int) {
        __interop__LoadNote(dsp, Int32(note), Int32(shape))
    }
    
    /// Add a note to the sequencer
    /// - Parameter x: The x-coordinate of the position where the note should be placed
    /// - Parameter y: The y-coordinate of the position where the note should be placed
    /// - Parameter note:  The pitch of the note to add as a MIDI note number
    /// - Parameter shape: The index of the oscillator to use
    
    public func addNote(x: Int, y: Int, note: Int, shape: Int) {
        __interop__WriteNote(dsp, Int32(x), Int32(y), Int32(note), Int32(shape))
    }
    
    /// Erase a note from the sequencer
    /// - Parameter x: The x-coordinate of the position that should be erased
    /// - Parameter y: The y-coordinate of the position that should be erased
    /// - Note: If the position (x, y) is empty, nothing will happen.

    public func eraseNote(x: Int, y: Int) {
        __interop__EraseNote(dsp, Int32(x), Int32(y))
    }
    
    public override var factoryPresets: [AUAudioUnitPreset]? {
        return [
            AUAudioUnitPreset(),
            AUAudioUnitPreset()
        ]
    }

    public override func shouldAllocateInputBus() -> Bool  { return false }

    public override func shouldClearOutputBuffer() -> Bool { return false }
    
    public override var supportsUserPresets: Bool          { return true  }

    /// This property represents the total state of the AudioUnit. The state of the parameters, as well as
    /// arbitrary data (such as the contents of the underlying sequencer) are associated with each
    /// `AUAudioUnitPreset`, which enables local data persistence.

    public override var fullStateForDocument: [String : Any]?
    {
        /// Retrieve the full state of the core. This is called when a user preset is being saved.
        /// - Note: The `super` implementation of `get` retrieves the state of the
        /// `AUParameterTree` as well as some data about the `AudioUnit`, including
        /// details from its `AudioComponentDescription`.
        
        get {
            guard let coreState = collateCoreState() else { return nil }
            let presetState = super.fullStateForDocument
            return presetState?.merging(coreState) { a, b in b }
        }
        
        /// Set the state of the core. This is called when a user preset is being loaded.
        /// - Note: The `super` implementation of `set` sets the state of each
        /// parameter in the `AUParameterTree`. This is performed before the state
        /// of the underlying sequencer is loaded.

        set (state) {
            guard let state = state else { return }
            super.fullStateForDocument = state
            for (key, value) in state {
                if key.prefix(1) == "P" {
                    let data = value as? String ?? ""
                    let pattern = Int32(key.suffix(1)) ?? 0
                    __interop__LoadPatternState(dsp, data, pattern)
                }
            }
        }
    }
    
    /// Load the state of a user's AUAudioUnitPreset into the Assemble core.
    /// In order to synchronise the SKSequencer and the core, the SKSequencer must poll the core
    /// for its state after a preset has been loaded. Therefore, this method should be called from a layer
    /// where the instance of `SKSequencer` being used is in scope.
    ///
    /// - Parameter number: The number of the user preset.

    @discardableResult
    public func loadFromPreset(number: Int) -> Bool {
        guard !(number < 0) && number < userPresets.count else { return false }

        let preset = userPresets[number]
        do    { fullStateForDocument = try presetState(for: preset) }
        catch { return false }

        return true
    }

    /// Save the current state as a user preset.
    /// If the preset name, `name`, already exists, then the preset wil be overwritten with the current state.
    /// Otherwise, the preset will be created.
    /// - Note: The preset number of a user preset must be negative. This function takes positive integer
    /// arguments and negates them prior to saving.
    ///
    /// - Parameter name: The name of the preset.
    /// - Parameter number: The number of the preset, which must be a positive integer.

    @discardableResult
    public func saveState(named name: String, at number: Int) -> Bool {
        guard number > 0 else { return false }

        let preset = AUAudioUnitPreset()
        preset.name = name
        preset.number = -(number)

        do    { try saveUserPreset(preset) }
        catch { return false }

        print("[ASCommanderAU] User preset \(number) saved successfully!")
        return true
    }
    
    /// Encode and collate the state of each pattern from the core.
    /// Each pattern's state is encoded to a string of characters from the ASCII set.

    public func collateCoreState() -> [String : Any]? {
        var state = [String:Any]()
        
        for pattern in 0 ..< PATTERNS {
            if let data = __interop__GetPatternState(dsp, pattern) {
                let string = String(cString: data, encoding: .ascii)
                state["P\(pattern)"] = string
            }
        }

        return state
    }
}

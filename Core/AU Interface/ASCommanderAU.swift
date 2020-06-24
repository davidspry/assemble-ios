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
    /// - Parameter componentDescription: The `AudioComponentDescription` containing
    /// information (manufacturer code, component type, etc.) about the `AudioUnit`. This information is
    /// defined in the `acd` property in `ASCommander.swift`.
    /// - Parameter options: Options for loading the `AudioUnit` in process or out of process.

    override init(componentDescription: AudioComponentDescription,
                  options: AudioComponentInstantiationOptions = []) throws {
        try super.init(componentDescription: componentDescription, options: options);

        /// Create an `AUParameterTree` comprised of `AUParameterGroup` subtrees,
        /// which are defined in `ASCommanderAUParameters.swift`. Each group
        /// defines a subtree of `AUParameter` vertices, which each define a parameter
        /// with an address, a value type, a value range, etc. recognised by Assemble.

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
        /// This callback defines the action taken when a parameter is used to set a value in Assemble (from the Swift layer).
        /// - SeeAlso: https://developer.apple.com/documentation/audiotoolbox/creating_custom_audio_effects

        tree.implementorValueObserver = { parameter, value in
            self.setParameterWithAddress(parameter.address, value: value)
        }
        
        /// Return the state of a requested parameter
        /// This callback defines the action taken when a parameter's value is requested from the Assemble core.
        /// - SeeAlso: https://developer.apple.com/documentation/audiotoolbox/creating_custom_audio_effects

        tree.implementorValueProvider = { parameter in
            return self.parameter(withAddress: parameter.address)
        }

        /// Return a String representation of a requested parameter
        /// This callback defines the action taken when a String representation of a parameter's value is requested.
        /// If desired, a switch statement could be used in order to provide different representations for different parameters.
        /// - SeeAlso: https://developer.apple.com/documentation/audiotoolbox/creating_custom_audio_effects
        
        tree.implementorStringFromValueCallback = { parameter, value in
            return String(format: "%.2f", value ?? parameter.value)
        }

        /// Create a new, empty preset.
        /// Setting the `currentPreset` property loads the preset automatically. Loading an empty preset
        /// ensures that a preset exists to be saved

        let preset = AUAudioUnitPreset()
            preset.number = -userPresets.count
            preset.name = "Init"

        currentPreset = preset
        userPresets.forEach { print("User Preset: Name: \($0.name), Number: \($0.number)") }
    }
    
    /// Play or pause the sequencer by toggling the state of the underlying clock.
    /// - Returns: `true` if the clock begins to tick; `false` otherwise

    @discardableResult
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
    
    /// Return the MIDI note number and the `OscillatorShape` of the note at the given position
    /// in the sequencer's current pattern.
    /// - Parameter xy: The position of the note whose values should be retrieved

    func note(at xy: CGPoint) -> (note: Int, shape: OscillatorShape)? {
        var note:  Int32 = 0
        var shape: Int32 = 0
        __interop__Note(dsp, Int32(xy.nx), Int32(xy.ny), &note, &shape)
        
        guard note > 0 else { return nil }
        return (Int(note), OscillatorShape(rawValue: Int(shape)) ?? .sine)
    }
    
    /// Erase a note from the sequencer
    /// - Parameter x: The x-coordinate of the position that should be erased
    /// - Parameter y: The y-coordinate of the position that should be erased
    /// - Note: If the position (x, y) is empty, nothing will happen.

    public func eraseNote(x: Int, y: Int) {
        __interop__EraseNote(dsp, Int32(x), Int32(y))
    }
    
    /// Clear the sequencer's current pattern.

    public func clearCurrentPattern() {
        __interop__ClearCurrentPattern(dsp)
    }

    public override func shouldAllocateInputBus() -> Bool  { return false }

    public override func shouldClearOutputBuffer() -> Bool { return false }
    
    /// Factory presets are associated with an associative state array, `[String:Any]`, in
    /// `factoryPresetsState`.

    public override var factoryPresets: [AUAudioUnitPreset]? {
        return [EmptyPreset.preset, FactoryPresetA.preset, FactoryPresetB.preset]
    }
    
    /// The state of each factory preset

    public var factoryPresetsState: [[String:Any]?] {
        return [EmptyPreset.state, FactoryPresetA.state, FactoryPresetB.state]
    }
    
    /// The current preset of the AudioUnit. Assigning to this property loads the state of a user preset.
    ///
    /// - Note: Setting this property will throw an exception in the case where the preset
    /// has not been saved locally. This applies to factory presets, which are encoded in the binary
    /// rather than on disk as an `.aupreset` file.

    public override var currentPreset: AUAudioUnitPreset? {
        didSet {
            guard let preset = currentPreset else { return }
            do    { fullStateForDocument = try presetState(for: preset) }
            catch { print("[ASCommanderAU] The selected preset is not stored locally.") }
        }
    }
    
    /// The index of the currently selected preset.
    /// This index can be used to select the preset from the `userPresets` array.

    public var selectedPreset: Int?

    public override var supportsUserPresets: Bool { return true }

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
    
    /// Copy the factory preset with the given index number to the user presets folder and select it.
    /// - Parameter number: The index of the desired factory preset

    @discardableResult
    public func copyFactoryPreset(number: Int) -> Bool {
        guard let presets = factoryPresets else { return false }
        guard !(number < 0) && number < presets.count else { return false }
        
        currentPreset = presets[number]
        fullStateForDocument = factoryPresetsState[number]
        saveState(named: currentPreset?.name ?? "Factory Preset")
        
        return true
    }
    
    /// Load a factory preset
    /// - Parameter number: The index of the desired factory preset

    @discardableResult
    public func loadFactoryPreset(number: Int) -> Bool {
        guard let presets = factoryPresets else { return false }
        guard !(number < 0) && number < presets.count else { return false }

        currentPreset = presets[number]
        fullStateForDocument = factoryPresetsState[number]

        return true
    }
    
    public func loadInitialState() {
        selectedPreset = nil
        loadFactoryPreset(number: 0)
    }
    
    /// Load the state of a user's AUAudioUnitPreset into the Assemble core.
    ///
    /// In order to synchronise the SKSequencer and the core, the SKSequencer must poll the core
    /// for its state after a preset has been loaded. Therefore, this method should be called from a context
    /// where the instance of `SKSequencer` being used is in scope.
    ///
    /// - Parameter number: The index of the desired user preset.

    @discardableResult
    public func loadFromPreset(number: Int) -> Bool {
        guard !(number < 0) && number < userPresets.count else { return false }

        selectedPreset = number
        currentPreset = userPresets[number]

        return true
    }
    
    /// Save the currently loaded preset and re-select it as the current preset.
    ///
    /// - Note: The `userPresets` array appears to be sorted by modification date in descending order,
    /// so the most recently created or modified presets appear first in the list.

    @discardableResult
    public func saveCurrentPreset() -> Bool {
        guard let preset = currentPreset else { return false }
        
        do    { try saveUserPreset(preset) }
        catch { return false }
        
        print("[ASCommanderAU] User preset \(preset.number) saved successfully!")
        selectPresetZero(named: preset.name, after: 25)

        return true
    }

    /// Save the current state as a new user preset using the next available number, then select the new preset.
    /// - Parameter name: The name of the preset.
    /// - Complexity: O(N), where `N` is the number of user presets.

    @discardableResult
    public func saveState(named name: String) -> Bool {
        let number = nextAvailablePresetNumber()
        let preset = AUAudioUnitPreset()
            preset.name = name
            preset.number = number

        do    { try saveUserPreset(preset) }
        catch { return false }

        print("[ASCommanderAU] User preset \(number) saved successfully!")
        selectPresetZero(named: name, after: 25)
        return true
    }
    
    /// Select the newest preset from index 0, when its name matches the given name, after some number of milliseconds.
    ///
    /// This is an idiosyncratic function designed to work around Apple's implementation of preset saving.
    /// Saving a preset to disk takes an nondeterministic amount of time, but the API provides no callback
    /// or notification system. In order to update the UI to match the saved files, it's necessary to repeatedly
    /// check the `userPresets` array for a particular object to appear.
    ///
    /// - Parameter name: The name of the preset to select.
    /// - Parameter delay: The number of milliseconds to wait before beginning the process.
    
    private func selectPresetZero(named name: String, after delay: Int) {
        var tries = 0
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(delay)) {
            while self.userPresets[0].name != name, tries < 10 {
                Thread.sleep(forTimeInterval: 0.05)
                tries = tries + 1
            }
            
            print("[ASCommanderAU] Selecting Preset #0 after \(tries) thread sleeps.")
            self.loadFromPreset(number: 0)
            self.selectedPreset = 0
        }
    }
    
    /// Return the next available preset number in linear time.
    ///
    /// Each unique preset should have a unique number. Unfortunately Apple's implementations
    /// of preset saving does not allow presets to be updated with new names or numbers.

    private func nextAvailablePresetNumber() -> Int {
        let presets = userPresets.sorted { $0.number > $1.number }
        guard let first = presets.first, let last = presets.last else { return -1 }

        if first.number  < -1            { return first.number + 1 }
        if -last.number == presets.count { return last.number - 1  }
        
        for k in 0 ..< presets.count {
            let preset = presets[k]
            let number = -(k + 1)
            if  preset.number != number { return number }
        }

        return -(userPresets.count + 1)
    }

    /// Rename the given preset with the given name, then re-select the preset.
    ///
    /// In order to rename a preset, it must be saved as a new preset with the new name,
    /// then the original preset file must be deleted. Apple's implementation of `saveUserPreset`
    /// will duplicate an `AUAudioUnitPreset` if its `name` property has been changed.
    ///
    /// - Parameter preset: The preset to rename
    /// - Parameter name:   The desired name for the preset.

    @discardableResult
    public func renamePreset(_ preset: AUAudioUnitPreset, to name: String) -> Bool {
        guard  saveState(named: name) else { return false }
        return deletePreset(preset)
    }

    /// Delete the given preset
    /// - Parameter preset: The preset to be deleted
    /// - Returns: `true` if the preset was deleted correctly; `false` otherwise.

    @discardableResult
    public func deletePreset(_ preset: AUAudioUnitPreset) -> Bool {
        do    { try deleteUserPreset(preset) }
        catch { return false }
        
        return true
    }
    
    /// Find the counterpart of the given preset in the `userPresets` array and select it
    /// to be the current preset.

    private func findAndSelectPreset(named name: String, number: Int) {
        DispatchQueue.main.async {
            for k in 0 ..< self.userPresets.count {
                if self.userPresets[k].number == number &&
                   self.userPresets[k].name == name {
                    self.currentPreset = self.userPresets[k]
                    return
                }
            }
        }
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

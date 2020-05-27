//  Assemble
//  Created by David Spry on 10/3/20.
//  Copyright © 2020 David Spry. All rights reserved.

import UIKit
import AVFoundation
import ReplayKit

class MainViewController : UIViewController, RPPreviewViewControllerDelegate
{
    let engine = Engine()
    var updater: CADisplayLink!
    let computerKeyboard = ComputerKeyboard()
    
    @IBOutlet weak var keyboard:  Keyboard!
    @IBOutlet weak var sequencer: Sequencer!
    @IBOutlet weak var waveform:  Waveform!
    @IBOutlet weak var patterns:  PatternOverview!
    @IBOutlet weak var transport: Transport!

    @IBOutlet weak var modeButton: UIButton!
    @IBOutlet weak var tempoLabel: ParameterLabel!
    @IBOutlet weak var descriptionLabel: PaddedLabel!
    
    @IBOutlet weak var presetLabel: UILabel!
    
    /// Connect classes and UI components together as listeners in order that
    /// user interaction and other signals can be propagated throughout the application interface

    private func connectListeners() {
        /// Connect listeners to the musical Keyboard component

        keyboard.listeners.add(sequencer)
        keyboard.listeners.add(Assemble.core)
        keyboard.settingsListeners.add(computerKeyboard)
        
        /// Connect listeners to the ComputerKeyboard interface

        computerKeyboard.listeners.add(sequencer)
        computerKeyboard.listeners.add(Assemble.core)
        computerKeyboard.settingsListeners.add(keyboard)
        computerKeyboard.settingsListeners.add(transport)
        computerKeyboard.transportListeners.add(transport)

        /// Connect listeners to the Transport component

        transport.listeners.add(keyboard)
        transport.listeners.add(computerKeyboard)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addInBackground(computerKeyboard)

        updater = CADisplayLink(target: self, selector: #selector(refreshInterface))
        updater.add(to: .main, forMode: .default)
        updater.preferredFramesPerSecond = 20
        
        tempoLabel.initialise(with: kClockBPM, increment: 1.0, and: .discreteFast)
        connectListeners()
        engine.start()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated);
        loadFactoryPresetOnFirstUse()
        waveform.start()
    }
    
    // MARK: - UI-Core Interaction
    
    @IBAction func didChangeMode(_ sender: UIButton) {
        Assemble.core.didToggleMode()
    }

    // MARK: - Save/Load Facilitation

    public func beginNewSong() {
        if Assemble.core.ticking { transport.pressPlayOrPause() }
        let preset = AUAudioUnitPreset()
            preset.name = "Init"
        Assemble.core.commander?.currentPreset = preset
        updateUIFromState()
    }
    
    /// Load the user preset with the index `position` in the underlying `userPresets` array
    /// and subsequently update the UI to reflect it.

    public func loadState(_ position: Int) {
        if Assemble.core.ticking { transport.pressPlayOrPause() }
        Assemble.core.commander?.loadFromPreset(number: position)
        updateUIFromState()
    }
    
    /// Save the current preset with the given name
    /// - Parameter name: The desired name for the preset

    public func saveState(named name: String) {
        guard let preset = Assemble.core.commander?.currentPreset
        else { return print("[MainViewController] CurrentPreset is nil") }

        let renamed = name != preset.name
        
        if !renamed { Assemble.core.commander?.saveState(named: name, at: preset.number) }
        else        { renamePreset(preset, named: name) }
        presetLabel.text = name
    }
    
    /// Create a new preset with the given name and save the new preset.
    /// - Parameter name: The desired name for the preset.
    /// - Returns: `true` if the preset saved correctly; `false` otherwise.

    @discardableResult
    public func copyState(named name: String) -> Bool {
        guard let number = Assemble.core.commander?.userPresets.count
        else { return false }

        let preset = AUAudioUnitPreset()
            preset.number = -number
            preset.name = name

        if let saved = Assemble.core.commander?.saveState(named: name, at: preset.number) {
            if saved { presetLabel.text = name }
            return saved
        }

        return false
    }
    
    /// Rename the given preset with the given name.
    ///
    /// In order to rename a preset, it must be saved as a new preset with the new name,
    /// then the original preset file must be deleted. Apple's implementation of `saveUserPreset`
    /// will duplicate an `AUAudioUnitPreset` if its `name` property has been changed.
    ///
    /// - Parameter preset: The preset to rename
    /// - Parameter name:   The desired name for the preset.

    private func renamePreset(_ preset: AUAudioUnitPreset, named name: String) {
        guard copyState(named: name) else { return }

        do    { try Assemble.core.commander?.deleteUserPreset(preset) }
        catch { print("[MainViewController] User Preset could not be deleted.") }
    }

    /// If the application is being loaded for the first time, load the factory preset and update
    /// the UI to reflect it.
    ///
    /// <TODO: Consider a welcome panel with a few tips on first launch>

    private func loadFactoryPresetOnFirstUse() {
        let defaults = UserDefaults()
        if let value = defaults.value(forKey: "FirstUse") as? Bool,
               value == false {
            return
        }   else { defaults.setValue(false, forKey: "FirstUse") }

        Assemble.core.commander?.loadFactoryPreset(number: 0)
        sequencer.initialiseFromUnderlyingState()
        patterns.loadStates()
        tempoLabel.reinitialise()
    }
    
    private func updateUIFromState() {
        presetLabel.text = Assemble.core.commander?.currentPreset?.name
        sequencer.initialiseFromUnderlyingState()
        tempoLabel.reinitialise()
        patterns.loadStates()
    }
    
    @objc func refreshInterface() {
        descriptionLabel.text = sequencer.UI.noteString
        descriptionLabel.isHidden = descriptionLabel.text == nil

        let mode = Int(Assemble.core.getParameter(kSequencerMode))
        let modes = ["PATTERN MODE", "SONG MODE"]
        modeButton.setTitle(modes[mode & 1], for: .normal)

        sequencer.UI.patternDidChange(to: Assemble.core.currentPattern)
        patterns.setNeedsDisplay()

        let row = Assemble.core.currentRow
        sequencer.UI.row.moveTo(row: row)
    }
    
    // MARK: - Storyboard Navigation
    
    /// Prepare to perform a segue to some other `UIViewController`

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        if segue.identifier == "persistenceSegue" {
            guard let destination = segue.destination as? PersistenceViewController
            else { return }

            destination.delegate = self
        }
        
        if segue.identifier == "saveCopySegue" {
            guard let destination = segue.destination as? SaveCopyViewController
            else { return }

            destination.delegate = self
        }
    }
}

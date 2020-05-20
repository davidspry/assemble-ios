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
    
    @IBAction func didTrySave(_ sender: UIButton) {
        Assemble.core.commander?.saveState(named: "Preset Three", at: 3)
    }

    // MARK: - Save/Load Facilitation

    /// Load the user preset with the index `position` in the underlying `userPresets` array
    /// and subsequently update the UI to reflect it.

    public func loadState(_ position: Int) {
        Assemble.core.ticking = false
        Assemble.core.commander?.loadFromPreset(number: position)
        sequencer.initialiseFromUnderlyingState()
        tempoLabel.reinitialise()
        patterns.loadStates()
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
    
    // MARK: - Storyboard Navigation
    
    /// Prepare to perform a segue to some other `UIViewController`

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        if segue.identifier == "persistenceSegue" {
            guard let destination = segue.destination as? PersistenceViewController
            else { return }

            destination.delegate = self
        }
    }
}

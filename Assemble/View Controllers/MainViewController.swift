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
    
    @IBAction func didTrySave(_ sender: UIButton) {
        Assemble.core.commander?.saveState(named: "Test Two", at: 1)
    }
    
    @IBAction func didTryLoad(_ sender: UIButton) {
        loadState()
    }
    
    @objc func refreshInterface() {
        descriptionLabel.text = sequencer.UI.noteString
        descriptionLabel.isHidden = descriptionLabel.text == nil

        // Either:
        // 1. Listen for changes on the kSequencerMode parameter
        // 2. Set this at the same time as pushing a value to the core
        let mode = Int(Assemble.core.getParameter(kSequencerMode))
        let modes = ["PATTERN MODE", "SONG MODE"]
        modeButton.setTitle(modes[mode & 1], for: .normal)
        // ======================================================

        sequencer.UI.patternDidChange(to: Assemble.core.currentPattern)

        patterns.setNeedsDisplay()

        let row = Assemble.core.currentRow
        sequencer.UI.row.moveTo(row: row)
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        addInBackground(computerKeyboard)

        // Test: Update Sequencer position
        updater = CADisplayLink(target: self, selector: #selector(refreshInterface))
        updater.add(to: .main, forMode: .default)
        updater.preferredFramesPerSecond = 20
        
        tempoLabel.initialise(with: kClockBPM, increment: 1.0, and: .discreteFast)
        
        keyboard.listeners.add(sequencer)
        keyboard.listeners.add(Assemble.core)
        keyboard.settingsListeners.add(computerKeyboard)
        
        computerKeyboard.listeners.add(sequencer)
        computerKeyboard.listeners.add(Assemble.core)
        computerKeyboard.settingsListeners.add(keyboard)
        computerKeyboard.settingsListeners.add(transport)
        computerKeyboard.transportListeners.add(transport)

        transport.listeners.add(keyboard)
        transport.listeners.add(computerKeyboard)

        engine.start()
    }

    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(animated);
        waveform.start()
    }
    
    @IBAction func didChangeMode(_ sender: UIButton) {
        Assemble.core.didToggleMode()
    }
    
    func loadState() {
        if Assemble.core.ticking
        {
            transport.pressPlayOrPause()
        }

        Assemble.core.commander?.loadFromPreset(number: 0)
        sequencer.initialiseFromUnderlyingState()
        patterns.loadStates()
        tempoLabel.reinitialise()
    }
}

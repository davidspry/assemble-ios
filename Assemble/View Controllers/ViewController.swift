//  Assemble
//  Created by David Spry on 10/3/20.
//  Copyright © 2020 David Spry. All rights reserved.

import UIKit

class ViewController : UIViewController
{
    let engine = Engine()
    var updater : CADisplayLink!
    let computerKeyboard = ComputerKeyboard()
    
    @IBOutlet weak var keyboard: Keyboard!
    @IBOutlet weak var sequencer: Sequencer!
    @IBOutlet weak var waveform: Waveform!
    @IBOutlet weak var patterns: PatternOverview!
    @IBOutlet weak var transport: Transport!
    
    @IBOutlet weak var modeLabel: UILabel!
    @IBOutlet weak var tempoLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!

    @objc func refreshInterface() {
        descriptionLabel.text = sequencer.SK.noteString
        descriptionLabel.isHidden = descriptionLabel.text == nil

        // Either:
        // 1. Listen for changes on the kSequencerMode parameter
        // 2. Set this at the same time as pushing a value to the core
        let mode = Int(Assemble.core.getParameter(kSequencerMode))
        let modes = ["PATTERN MODE", "SONG MODE"]
        modeLabel.text = modes[mode & 1]

        
        sequencer.SK.patternDidChange(to: Assemble.core.currentPattern)

        // Test out listening to parameters that aren't tweaked by the user.
        // If it works, Pattern could listen to the core. Otherwise,
        // there should be two CADisplayLinks: 60fps, and 20fps, perhaps.
        // One for smooth animation; one for continuous polling.
        patterns.setNeedsDisplay()
        // ==========

        // The current row needs to be refreshed at a frame rate
        // that's at least as fast as the BPM.
        let row = Assemble.core.currentRow
        sequencer.SK.row.moveTo(row: row)
    }

    // all of this will go into the effects / settings menu
    // ========================================================================
    internal func desiredInitialFrequency(_ frequency: Float) -> Float {
        return (log(frequency) - log(20)) / (log(20E3) - log(20))
    }

    let tempo = 30...300
    internal func desiredInitialTempo(_ tempo: Int) -> Float {
        return Float(tempo - self.tempo.lowerBound) / Float(self.tempo.upperBound - self.tempo.lowerBound)
    }
    // ========================================================================

    override func viewDidLoad()
    {
        super.viewDidLoad()
        addInBackground(computerKeyboard)

        // Test: Update Sequencer position
        updater = CADisplayLink(target: self, selector: #selector(refreshInterface))
        updater.add(to: .main, forMode: .default)
        updater.preferredFramesPerSecond = 40
        
        keyboard.listeners.add(sequencer)
        keyboard.listeners.add(Assemble.core)
        keyboard.settingsListeners.add(computerKeyboard)
        
        computerKeyboard.listeners.add(sequencer)
        computerKeyboard.listeners.add(transport)
        computerKeyboard.listeners.add(Assemble.core)
        computerKeyboard.settingsListeners.add(keyboard)
        computerKeyboard.settingsListeners.add(transport)

        transport.listeners.add(keyboard)
        transport.listeners.add(computerKeyboard)

        engine.start()
    }

    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(animated);
        waveform.start()
    }
}

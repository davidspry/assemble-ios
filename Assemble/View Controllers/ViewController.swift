//  Assemble
//  Created by David Spry on 10/3/20.
//  Copyright © 2020 David Spry. All rights reserved.

import UIKit

class ViewController : UIViewController
{
    let engine = Engine()
    var updater : CADisplayLink!
    var computerKeyboard = ComputerKeyboard()
    
    var pttrn = 0
    
    @IBOutlet weak var keyboard: Keyboard!
    @IBOutlet weak var sequencer: Sequencer!
    @IBOutlet weak var waveform: Waveform!
    @IBOutlet weak var patterns: PatternOverview!

    @IBOutlet weak var tempoLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var modeLabel: UILabel!
    
    @IBOutlet weak var resonanceSlider: UISlider!
    @IBOutlet weak var frequencySlider: UISlider!
    
    @objc func refreshInterface() {
        descriptionLabel.text = sequencer.SK.noteString
        descriptionLabel.isHidden = descriptionLabel.text == nil
        
        // Listen for mode, pattern
        let mode = Assemble.core.getParameter(kSequencerMode)
        if mode == 0 { modeLabel.text = "PATTERN MODE" }
        else         { modeLabel.text = "SONG MODE" }
        
        // listening for pattern...
        let pattern = Assemble.core.currentPattern
        if pttrn != pattern {
            sequencer.SK.patternDidChange(to: pattern, from: pttrn)
            pttrn = pattern
        }
        
        patterns.setNeedsDisplay()
        // ==========
        
        // Update this from the setParameter(...) function instead
        let bpm = Assemble.core.getParameter(kClockBPM)
        let row = Assemble.core.currentRow
        sequencer.SK.row.moveTo(row: row)
        tempoLabel.text = "\(bpm)BPM"
    }
    
    internal func desiredInitialFrequency(_ frequency: Float) -> Float {
        return (log(frequency) - log(20)) / (log(20E3) - log(20))
    }

    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        engine.connect(Assemble.core);
        addInBackground(computerKeyboard)
        
        // Test: Update Sequencer position
        updater = CADisplayLink(target: self, selector: #selector(refreshInterface))
        updater.add(to: .main, forMode: .default)
        updater.preferredFramesPerSecond = 40
        
        // Test: Set filter frequency
        frequencySlider.maximumValue = 1
        frequencySlider.minimumValue = 0.55
        frequencySlider.isContinuous = true
        frequencySlider.setValue(desiredInitialFrequency(8000), animated: true)
        
        // Test: Set filter resonance
        resonanceSlider.maximumValue = 1
        resonanceSlider.minimumValue = 0.0
        resonanceSlider.setValue(0.0, animated: true)
        resonanceSlider.isContinuous = true
        
        keyboard.listeners.add(sequencer)
        keyboard.listeners.add(Assemble.core)
        keyboard.settingsListeners.add(computerKeyboard)
        computerKeyboard.listeners.add(sequencer)
        computerKeyboard.listeners.add(Assemble.core)
        computerKeyboard.settingsListeners.add(keyboard)
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(animated);
        engine.start()
        waveform.start()
    }

    @IBAction func playOrPause(_ sender: UIButton)
    {
        // Returns Bool (for play button animation)
        Assemble.core.playOrPause()
    }

    @IBAction func sliderChanged(_ sender: UISlider) {
        let tempo = sender.value.map(from: 0.55...1, to: 30...300)
        Assemble.core.setParameter(kClockBPM, to: tempo)
//        Assemble.core.setFilter(frequency: sender.value, oscillator: .triangle)
    }
    
    @IBAction func resonanceChanged(_ sender: UISlider) {
        Assemble.core.setFilter(resonance: sender.value, oscillator: .triangle)
    }
}


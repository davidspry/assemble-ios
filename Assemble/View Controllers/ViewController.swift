//  Assemble
//  Created by David Spry on 10/3/20.
//  Copyright © 2020 David Spry. All rights reserved.

import UIKit

class ViewController : UIViewController
{
    let engine = Engine()
    var updater : CADisplayLink!
    var computerKeyboard = ComputerKeyboard()
    
    @IBOutlet weak var keyboard: Keyboard!
    @IBOutlet weak var sequencer: Sequencer!
    @IBOutlet weak var waveform: Waveform!
    @IBOutlet weak var patterns: PatternOverview!
    @IBOutlet weak var transport: Transport!
    
    @IBOutlet weak var tempoLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var modeLabel: UILabel!
    
    @IBOutlet weak var frequencySlider: UISlider!
    
    @objc func refreshInterface() {
        descriptionLabel.text = sequencer.SK.noteString
        descriptionLabel.isHidden = descriptionLabel.text == nil

        // A mode parameter should be listened to. Swift cannot
        // cast between Bool and numeric values, so this should be
        // done in either the C++ or Objective-C context.
        let mode = Assemble.core.getParameter(kSequencerMode)
        if  mode == 0 { modeLabel.text = "PATTERN MODE" }
        else          { modeLabel.text = "SONG MODE"    }

        // Rather than CADisplayLink, Sequencer should listen for
        // changes in the value of the Pattern parameter
        sequencer.SK.patternDidChange(to: Assemble.core.currentPattern)
        
        // This does not need to be redrawn at 60fps.
        // This needs to be redrawn whenever the pattern changes
        // Consequently, Patterns should listen for changes in the
        // currentPattern parameter, and it should also listen for
        // changes in parameters that describe whether each pattern
        // is on or off, i.e. (address: 0x..., value: [Pattern][State],
        // e.g. [PatternNumber] * 10 + static_cast<int>(pattern == active),
        // which would be equal to the value 101
        // To read it, take the value mod 10 to retrieve the state (101 % 10 = 1), then
        // divide by 10 in order to retrieve the pattern number (101 / 10 = 10).
        patterns.setNeedsDisplay()
        // ==========
        
        let row = Assemble.core.currentRow
        sequencer.SK.row.moveTo(row: row)
    }

    internal func desiredInitialFrequency(_ frequency: Float) -> Float {
        return (log(frequency) - log(20)) / (log(20E3) - log(20))
    }
    
    internal func desiredInitialTempo(_ tempo: Int) -> Float {
        return Float(tempo - 30) / Float(300 - 30)
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
        frequencySlider.minimumValue = 0
        frequencySlider.isContinuous = true
        frequencySlider.setValue(desiredInitialTempo(140), animated: true)
        
        keyboard.listeners.add(sequencer)
        keyboard.listeners.add(Assemble.core)
        keyboard.settingsListeners.add(computerKeyboard)
        computerKeyboard.listeners.add(sequencer)
        computerKeyboard.listeners.add(Assemble.core)
        computerKeyboard.settingsListeners.add(keyboard)
        transport.listeners.add(keyboard)
        transport.listeners.add(computerKeyboard)
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
        let tempo = sender.value.map(from: 0...1, to: 30...300)
        let bpm = Int(tempo)
        tempoLabel.text = "\(bpm)BPM"
        Assemble.core.setParameter(kClockBPM, to: tempo)
    }
}


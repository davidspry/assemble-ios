//  Assemble
//  ============================
//  Created by David Spry on 28/3/20.
//  Copyright © 2020 David Spry. All rights reserved.

import UIKit

/**
 A single-touch musical keyboard that can broadcast MIDI note numbers from its keys.
 
 - Note: This class owes its design in part to `AKKeyboardView.swift` from the **AudioKit** framework,
         which was written by Aurelius Prochazka.
 */

class Keyboard : UIView, KeyboardSettingsListener, OscillatorSelectorListener
{
    var keyOnColour  : UIColor = UIColor.sawtoothNoteColour
    var keyOffColour : UIColor = UIColor.white

    var shapeLayers = [CAShapeLayer]()
    var octaveLabel = UILabel()
    
    var listeners = MulticastDelegate<KeyboardListener>()
    var settingsListeners = MulticastDelegate<KeyboardSettingsListener>()

    var octave : Int = 4
    let octaves: Int = 2
    var oscillator: OscillatorShape = .triangle

    internal var margins: UIEdgeInsets {
        return UIEdgeInsets(top: 25.0, left: 25.0, bottom: 25.0, right: 25.0)
    }

    internal var octaveSize: CGSize {
        let W = bounds.width;
        return CGSize(width: W / CGFloat(octaves) - margins.left - margins.right, height: 35.0);
    }
    
    var keyStroke: CGFloat = 3.0

    var keyStep: CGFloat {
        return octaveSize.width / 7.0
    }
    
    var keyRadius: CGFloat {
        return keySize.height * 0.5
    }
    
    var keySize: CGSize {
        return CGSize(width: octaveSize.width / 7.0 / 2.0, height: octaveSize.height / 2.0);
    }

    let whiteKeyIndices = [0, 2, 4, 5, 7, 9, 11]
    let blackKeyIndices = [0, 1, 3, 0, 6, 8, 10]
    var pressedKey: Int?

    internal func pressNote(_ note: Int)
    {
        pressedKey = note
        listeners.invoke({$0.pressNote(note, shape: oscillator)});
    }

    internal func releaseNote(_ note: Int)
    {
        pressedKey = nil
    }
    
    // MARK: - Oscillator Selector Listener
    
    func didChangeOscillator(to oscillator: OscillatorShape) {
        self.oscillator = oscillator
        keyOnColour = .from(oscillator)
    }
    
    // MARK: - Keyboard Settings Listener
    
    func didChangeOctave(to octave: Int) {
        self.octave = octave
        octaveLabel.text = octave.description
    }
    
    @objc internal func setOctave(sender: UIButton) {
        switch sender.tag {
        case 0x0: octave = max(octave - 1, 1); break
        case 0x1: octave = min(octave + 1, 7); break
        default: break
        }
        
        octaveLabel.text = octave.description
        settingsListeners.invoke({$0.didChangeOctave(to: octave)})
    }

    func initialise(in frame: CGRect) {
        isMultipleTouchEnabled = false;
        initialiseControls(in: frame)
        initialisePaths()
    }
    
    internal func initialiseControls(in frame: CGRect) {
        let button: Int = 35
        let controlMargin: CGFloat = 5.0
        var origin = CGPoint(x: 0, y: frame.midY - CGFloat(button) * 0.5)
        let weight = UIImage.SymbolConfiguration(weight: .medium)
        var arrow: UIImage!
        
        let octaveU = UIButton()
        let octaveD = UIButton()
        
        origin.x = controlMargin
        arrow = UIImage(systemName: "minus", withConfiguration: weight)
        octaveD.frame = CGRect(origin: origin, size: .square(button))
        octaveD.setImage(arrow, for: .normal)
        octaveD.tintColor = .white
        octaveD.tag = 0x0
        octaveD.addTarget(self, action: #selector(setOctave), for: .touchDown)
        addSubview(octaveD)
        
        origin.x = bounds.width - controlMargin - CGFloat(button)
        arrow = UIImage(systemName: "plus", withConfiguration: weight)
        octaveU.frame = CGRect(origin: origin, size: .square(button))
        octaveU.setImage(arrow, for: .normal)
        octaveU.tintColor = .white
        octaveU.tag = 0x1
        octaveU.addTarget(self, action: #selector(setOctave), for: .touchDown)
        addSubview(octaveU)
        
        origin.x = frame.midX
        origin.y = controlMargin
        octaveLabel.frame = CGRect(origin: origin, size: .square(10))
        octaveLabel.text = octave.description
        octaveLabel.font = UIFont(name: "JetBrainsMono-Regular", size: 16)
        octaveLabel.textAlignment = .center
        octaveLabel.textColor = .white
        addSubview(octaveLabel)
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder);
        initialise(in: bounds)
    }

    override public init(frame: CGRect) {
        super.init(frame: frame)
        initialise(in: frame)
    }

    // MARK: - View Content Methods

    override class var requiresConstraintBasedLayout: Bool {
        return true
    }

}

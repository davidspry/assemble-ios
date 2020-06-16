//  Assemble
//  ============================
//  Created by David Spry on 28/3/20.
//  Copyright © 2020 David Spry. All rights reserved.

import UIKit

/// A single-touch musical keyboard that can broadcast MIDI note numbers from its keys.
///
/// - Note: This class owes its design in part to `AKKeyboardView.swift` from the **AudioKit** framework,
/// which was written by Aurelius Prochazka.

class Keyboard : UIView, KeyboardSettingsListener
{
    var keyOnColour  : UIColor = UIColor.sineNoteColour
    var keyOffColour : UIColor = UIColor.init(named: "Secondary") ?? .white
    
    let visibilityTranslation: CGFloat = 50
    
    var shapeLayers = [CAShapeLayer]()

    var listeners = MulticastDelegate<KeyboardListener>()
    var settingsListeners = MulticastDelegate<KeyboardSettingsListener>()

    var octave : Int = 3
    let octaves: Int = 1
    var octaveLabel = UILabel()
    var octaveString : String {
        return "OCT \(octave)"
    }

    private let octaveButtons = (u: UIButton(), d: UIButton())
    
    var oscillator: OscillatorShape = .sine

    internal var margins: UIEdgeInsets {
        return UIEdgeInsets(top: 5.0, left: 35.0, bottom: 5.0, right: 35.0)
    }

    internal var octaveSize: CGSize {
        let W = bounds.width;
        return CGSize(width: W / CGFloat(octaves) - margins.left - margins.right, height: 35.0);
    }
    
    let keyStroke: CGFloat = 3.0

    var keyStep: CGFloat {
        return octaveSize.width / 7.0
    }
    
    var keyRadius: CGFloat {
        return keySize.width / 2.0
    }
    
    var keySize: CGSize {
        return CGSize(width: octaveSize.width / 7.0 / 2.0, height: octaveSize.height / 2.0);
    }

    let whiteKeyIndices = [0, 2, 4, 5, 7, 9, 11]
    let blackKeyIndices = [0, 1, 3, 0, 6, 8, 10]
    var pressedKey: Int?

    internal func pressNote(_ note: Int) {
        pressedKey = note
        listeners.invoke({$0.pressNote(note, shape: oscillator)});
    }

    internal func releaseNote(_ note: Int) {
        pressedKey = nil
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        let colour = UIColor.init(named: "Secondary") ?? .white
        keyOffColour = colour
        shapeLayers.forEach {
            $0.fillColor = keyOffColour.cgColor
            $0.strokeColor = keyOffColour.cgColor
        }
    }
    
    @objc internal func setOctave(sender: UIButton) {
        switch sender.tag {
        case 0x0: octave = max(octave - 1, 1); break
        case 0x1: octave = min(octave + 1, 7); break
        default: break
        }
        
        octaveLabel.text = octaveString
        settingsListeners.invoke({$0.didChangeOctave(to: octave)})
    }

    func initialise(in frame: CGRect) {
        isMultipleTouchEnabled = false;
        initialiseControls(in: frame)
        initialisePaths()
        didToggleKeyboardDisplay(false)
    }

    internal func initialiseControls(in frame: CGRect) {
        let button: Int = 35
        let controlMargin: CGFloat = 0.0
        let configuration = UIImage.SymbolConfiguration(pointSize: 20, weight: .semibold)
        var origin = CGPoint(x: 0, y: frame.midY - CGFloat(button) * 0.5)
        let colour = UIColor.init(named: "Secondary") ?? .white
        var arrow: UIImage!
        
        origin.x = controlMargin
        arrow = UIImage(systemName: "arrowtriangle.down.fill", withConfiguration: configuration)
        octaveButtons.d.frame = CGRect(origin: origin, size: .square(button))
        octaveButtons.d.setImage(arrow, for: .normal)
        octaveButtons.d.tintColor = colour
        octaveButtons.d.tag = 0x0
        octaveButtons.d.addTarget(self, action: #selector(setOctave), for: .touchDown)
        addSubview(octaveButtons.d)
        
        origin.x = bounds.width - controlMargin - CGFloat(button)
        arrow = UIImage(systemName: "arrowtriangle.up.fill", withConfiguration: configuration)
        octaveButtons.u.frame = CGRect(origin: origin, size: .square(button))
        octaveButtons.u.setImage(arrow, for: .normal)
        octaveButtons.u.tintColor = colour
        octaveButtons.u.tag = 0x1
        octaveButtons.u.addTarget(self, action: #selector(setOctave), for: .touchDown)
        addSubview(octaveButtons.u)
        
        origin.x = frame.minX
        origin.y = frame.minY
        octaveLabel.frame = CGRect(origin: origin, size: CGSize(width: 55, height: 15))
        octaveLabel.font = UIFont(name: "JetBrainsMono-Regular", size: 12)
        octaveLabel.text = octaveString
        octaveLabel.textAlignment = .center
        octaveLabel.textColor = colour
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
    
    // MARK: - Keyboard Settings Listener

    func didChangeOctave(to octave: Int) {
        self.octave = octave
        octaveLabel.text = octaveString
    }
    
    func didChangeOscillator(to oscillator: OscillatorShape) {
        self.oscillator = oscillator
        keyOnColour = .from(oscillator)
    }
    
    /// Hide or show the keyboard view in an animated fashion

    func didToggleKeyboardDisplay(_ show: Bool) {
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.15) {
                self.alpha = show ? 1.0 : 0.0
                let dy: CGFloat = show ? 0 : self.visibilityTranslation
                let translation = CGAffineTransform(translationX: 0, y: dy)
                self.layer.setAffineTransform(translation)
            }
        }
    }

}

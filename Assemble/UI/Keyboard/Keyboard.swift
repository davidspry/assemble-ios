//  Assemble
//  ============================
//  Created by David Spry on 28/3/20.
//  Copyright © 2020 David Spry. All rights reserved.

import UIKit

/// A single-touch musical keyboard that can broadcast MIDI note numbers from its keys.

class Keyboard : UIView, KeyboardSettingsListener
{
    /// The colour used to highlight a pressed key

    private(set) var keyOnColour = UIColor.sineNoteColour
    
    /// The default, off-state colour for the keyboard's keys

    internal let keyOffColour: UIColor? = UIColor.init(named: "Secondary")
    
    /// Whether or not the `Keyboard` has been initialised and is ready for drawing.

    internal var initialised = false
    
    /// The number of points to translate the keyboard's view by during its show/hide animation

    public let visibilityTranslation: CGFloat = 50
    
    /// An array of `CAShapeLayer` that each represent one key

    internal var shapeLayers = [CAShapeLayer]()

    /// The keyboard's listeners, who are notified when a note is pressed

    public let listeners = MulticastDelegate<KeyboardListener>()
    
    /// The keyboard's settings listeners, who are notified when the keyboard's octave is changed

    public let settingsListeners = MulticastDelegate<KeyboardSettingsListener>()
    
    /// The keyboard's current octave

    private(set) var octave: Int = 3
    
    /// The currently selected oscillator
    ///
    /// This information is included with each key press, but it's updated
    /// via the keyboard's `didChangeOscillator` callback, which is
    /// a `KeyboardSettingsListener` protocol method.
    
    private(set) var oscillator: OscillatorShape = .sine
    
    /// The number of octaves drawn to the screen

    internal let octaves: Int = 1
    
    /// A label displaying the keyboard's current octave
    
    internal var octaveLabel = UILabel()
    
    /// Buttons used by the user to select the next or the previous octave

    private let octaveButtons = (u: UIButton(), d: UIButton())
    
    /// The keyboard's current octave represented as a string

    internal var octaveString: String {
        return "OCT \(octave)"
    }

    /// The keyboard's layout margins

    internal var margins: UIEdgeInsets {
        return UIEdgeInsets(top: 5.0, left: 35.0, bottom: 5.0, right: 35.0)
    }

    /// The size, in points, of an octave on the keyboard

    internal var octaveSize: CGSize {
        let W = bounds.width;
        return CGSize(width: W / CGFloat(octaves) - margins.left - margins.right, height: 35.0);
    }
    
    /// The width of a key's off-state border stroke.

    let keyStroke: CGFloat = 4.0

    /// The width, in points, of one key and its margins

    var keyStep: CGFloat {
        return octaveSize.width / 7.0
    }
    
    /// The radius of a key

    var keyRadius: CGFloat {
        return keySize.width / 2.0
    }
    
    /// The space, in points, required by each key

    var keySize: CGSize {
        return CGSize(width: octaveSize.width / 7.0 / 2.0, height: octaveSize.height / 2.0);
    }

    internal let whiteKeyIndices = [0, 2, 4, 5, 7, 9, 11]
    
    internal let blackKeyIndices = [0, 1, 3, 0, 6, 8, 10]
    
    /// The note number of the currently pressed key or nil if no key is being pressed

    internal var pressedKey: Int?

    /// Press the note whose note number is given, notify all listeners, and redraw the keyboard.
    /// - Parameter note: The note number of the note to be pressed

    internal func pressNote(_ note: Int) {
        listeners.invoke({$0.pressNote(note, shape: oscillator)});
        pressedKey = note
        layer.setNeedsDisplay()
    }

    /// Release the pressed note, then redraw the keyboard.

    internal func releaseNote() {
        pressedKey = nil
        layer.setNeedsDisplay()
    }

    /// Redraw the keyboard in order that its `CAShapeLayer`s reflect a change in the user interface style.

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        layer.setNeedsDisplay()
        print("[Keyboard] Redrawing")
    }
    
    /// Set the octave of the keyboard and update all settings listeners.
    /// - Parameter sender: The octave button that was pressed

    @objc internal func setOctave(sender: UIButton) {
        switch sender.tag {
        case 0x0: octave = max(octave - 1, 1); break
        case 0x1: octave = min(octave + 1, 7); break
        default: break
        }
        
        octaveLabel.text = octaveString
        settingsListeners.invoke({$0.didChangeOctave(to: octave)})
    }

    /// Initialise the keyboard and its controls, then hide it from view.
    /// - Parameter frame: The frame in which to draw the keyboard

    public func initialise(in frame: CGRect) {
        isHidden = true
        isMultipleTouchEnabled = false
        initialiseControls(in: frame)
        initialisePaths()
        didToggleKeyboardDisplay(false)
    }
    
    /// Hide or show the keyboard view in an animated fashion
    /// - Parameter show: A flag to indicate whether the keyboard should be shown (`true`) or hidden (`false`).

    func didToggleKeyboardDisplay(_ show: Bool) {
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.15, animations: {
                self.alpha = show ? 1.0 : 0.0
                let dy: CGFloat = show ? 0 : self.visibilityTranslation
                let translation = CGAffineTransform(translationX: 0, y: dy)
                self.layer.setAffineTransform(translation)
            }) { complete in self.isHidden = false }
        }
    }

    /// Establish the keyboard's controls, which include its octave buttons and octave label.
    /// - Parameter frame: The keyboard's frame

    internal func initialiseControls(in frame: CGRect) {
        var icon: UIImage!
        let buttonSize: Int = 35
        var origin = CGPoint(x: 0, y: frame.midY - CGFloat(buttonSize) * 0.5)
        let colour = UIColor.init(named: "Secondary") ?? UIColor.systemGray5
        let configuration = UIImage.SymbolConfiguration(pointSize: 20, weight: .semibold)
        
        origin.x = 0.0
        icon = UIImage(systemName: "arrowtriangle.down.fill", withConfiguration: configuration)
        octaveButtons.d.tag = 0x0
        octaveButtons.d.tintColor = colour
        octaveButtons.d.setImage(icon, for: .normal)
        octaveButtons.d.frame = CGRect(origin: origin, size: .square(buttonSize))
        octaveButtons.d.addTarget(self, action: #selector(setOctave), for: .touchDown)
        addSubview(octaveButtons.d)
        
        origin.x = bounds.width - CGFloat(buttonSize)
        icon = UIImage(systemName: "arrowtriangle.up.fill", withConfiguration: configuration)
        octaveButtons.u.tag = 0x1
        octaveButtons.u.tintColor = colour
        octaveButtons.u.setImage(icon, for: .normal)
        octaveButtons.u.frame = CGRect(origin: origin, size: .square(buttonSize))
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
        super.init(coder: coder)
        translatesAutoresizingMaskIntoConstraints = false
        DispatchQueue.main.async {
            self.initialise(in: self.bounds)
        }
    }

    override public init(frame: CGRect) {
        super.init(frame: frame)
        translatesAutoresizingMaskIntoConstraints = false
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

}

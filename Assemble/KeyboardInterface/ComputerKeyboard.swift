//  Assemble
//  Created by David Spry on 25/4/20.
//  Copyright © 2020 David Spry. All rights reserved.

import UIKit

/// A view controller who parses presses from an external computer keyboard and
/// notifies registered listeners of the user's commands.
///
/// This view controller should be added as a child to some other view controller on the bottom layer of its subview hierarchy.
///
/// - SeeAlso: KeyboardHandler.swift

class ComputerKeyboard : UIViewController, KeyboardSettingsListener
{
    let listeners = MulticastDelegate<KeyboardListener>()
    let settingsListeners = MulticastDelegate<KeyboardSettingsListener>()
    let transportListeners = MulticastDelegate<TransportListener>()

    /// The first note of the keyboard's current octave

    lazy private var octaveAsNoteNumber: Int = 60
    
    /// The currently selected oscillator.
    ///
    /// This information is included with new note messages, but it's set
    /// in the `didChangeOscillator` callback, which is a
    /// `KeyboardSettingsListener` protocol method.

    private(set) var oscillator: OscillatorShape = .sine
    
    /// The `ComputerKeyboard`'s current octave number

    public var octave: Int = 4 {
        didSet {
            octaveAsNoteNumber = (octave + 1) * 12
            settingsListeners.invoke({$0.didChangeOctave(to: octave)})
        }
    }

    // MARK: - KeyboardSettingsListener
    
    func didChangeOctave(to octave: Int) {
        self.octave = octave
    }
    
    func didChangeOscillator(to oscillator: OscillatorShape) {
        self.oscillator = oscillator
    }
    
    // MARK: - Presses callback

    override func pressesBegan(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
        for press in presses {
            KeyboardHandler.parse(press) { action, value in
                switch (action) {
                case .navigate:
                    self.listeners.invoke({ $0.didNavigate(by: value) })
                    break
                
                case .transport:
                    self.transportListeners.invoke({ $0.pressPlayOrPause() })
                    break
                
                case .place:
                    self.listeners.invoke({
                        $0.pressNote(self.octaveAsNoteNumber + value, shape: self.oscillator)
                    });
                    break

                case .erase:
                    self.listeners.invoke({ $0.eraseNote() })
                    break
                    
                case .mode:
                    Assemble.core.didToggleMode()
                    break

                case .noctave:
                    self.listeners.invoke({ $0.setOctave(value) })
                    break
                
                case .uoctave:
                    self.octave = value
                    self.settingsListeners.invoke({ $0.didChangeOctave(to: self.octave )})
                    break

                case .noscillator:
                    self.listeners.invoke({ $0.setOscillator(Bool(value)) })
                    break

                case .uoscillator:
                    self.oscillator = value == 0 ? self.oscillator.previous() : self.oscillator.next()
                    self.settingsListeners.invoke({ $0.didChangeOscillator(to: self.oscillator)})
                    break

                default: break
                }
            }

        }
    }
}

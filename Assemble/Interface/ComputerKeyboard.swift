//  Assemble
//  Created by David Spry on 25/4/20.
//  Copyright © 2020 David Spry. All rights reserved.

import UIKit

class ComputerKeyboard : UIViewController, KeyboardSettingsListener
{
    var listeners = MulticastDelegate<KeyboardListener>()
    
    var settingsListeners = MulticastDelegate<KeyboardSettingsListener>()

    lazy private var _octave: Int = 60
    
    var octave: Int = 4 {
        didSet {
            _octave = (octave + 1) * 12
            settingsListeners.invoke({$0.didChangeOctave(to: octave)})
        }
    }

    var oscillator: OscillatorShape = .sine

    func didChangeOctave(to octave: Int) {
        self.octave = octave
    }
    
    func didChangeOscillator(to oscillator: OscillatorShape) {
        self.oscillator = oscillator
    }
    
    override func pressesBegan(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
        for press in presses {
            
            KeyboardHandler.parse(press) { action, value in
                switch (action) {
                case .navigate:
                    self.listeners.invoke({ $0.didNavigate(by: value) }); break
                
                case .transport:
                    self.listeners.invoke({ $0.pressPlayOrPause() }); break
                
                case .place:
                    self.listeners.invoke({
                        $0.pressNote(self._octave + value, shape: self.oscillator)
                    });
                    break

                case .erase:
                    self.listeners.invoke({ $0.eraseNote() }); break
                
                case .noctave:
                    self.listeners.invoke({ $0.setOctave(value) })
                    break
                
                case .uoctave:
                    self.octave = value
                    self.settingsListeners.invoke({ $0.didChangeOctave(to: self.octave )})
                    break

                case .noscillator:
                    self.listeners.invoke({ $0.setOscillator(Bool(value)) }); break

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

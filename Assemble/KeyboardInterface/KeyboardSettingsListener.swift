//  Assemble
//  Created by David Spry on 25/4/20.
//  Copyright © 2020 David Spry. All rights reserved.

import Foundation

/// `KeyboardSettingsListener`s are notified when the master octave or oscillator settings are changed,
/// or the on-screen piano keyboard should be shown or hidden.

protocol KeyboardSettingsListener: AnyObject {
    
    /// This method should be called when a keyboard interface's octave has changed.
    
    func didChangeOctave(to octave: Int)
    
    /// This method should be called when the current oscillator selection has changed.

    func didChangeOscillator(to oscillator: OscillatorShape)
    
    /// This method should be called when the user wishes to hide or show the on-screen piano keyboard.

    func didToggleKeyboardDisplay(_ show: Bool)
}

/// This extension provides default implementations for the KeyboardSettingsListener protocol,
/// thereby relaxing the requirement for subclassers to implement each one.

extension KeyboardSettingsListener {
    func didChangeOctave(to octave: Int) {}
    func didChangeOscillator(to oscillator: OscillatorShape) {}
    func didToggleKeyboardDisplay(_ show: Bool) {}
}

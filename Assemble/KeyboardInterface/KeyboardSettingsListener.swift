//  Assemble
//  Created by David Spry on 25/4/20.
//  Copyright © 2020 David Spry. All rights reserved.

import Foundation

protocol KeyboardSettingsListener: AnyObject {
    func didChangeOctave(to octave: Int)
    func didChangeOscillator(to oscillator: OscillatorShape)
}

/**
 This extension provides default implementations for the KeyboardSettingsListener protocol,
 thereby relaxing the requirement for subclassers to implement each one.
*/

extension KeyboardSettingsListener {
    func didChangeOctave(to octave: Int) {}
    func didChangeOscillator(to oscillator: OscillatorShape) {}
}

//  Assemble
//  Created by David Spry on 25/4/20.
//  Copyright © 2020 David Spry. All rights reserved.

import Foundation

protocol KeyboardListener
{
    func pressNote(_ note: Int, shape: OscillatorShape)
    func eraseNote()
    func setOctave(_ octave: Int)
    func didNavigate(by direction: Int)
}

/**
 This extension provides default implementations for the KeyboardListener protocol,
 thereby relaxing the requirement for subclassers to implement each one.
*/

extension KeyboardListener {
    func pressNote(_ note: Int, shape: OscillatorShape) {}
    func eraseNote() {}
    func setOctave(_ octave: Int) {}
    func didNavigate(by direction: Int) {}
}

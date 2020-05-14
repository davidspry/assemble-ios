//  Assemble
//  Created by David Spry on 25/4/20.
//  Copyright © 2020 David Spry. All rights reserved.

import Foundation

protocol KeyboardListener
{
    /// This method is called when a note has been pressed by some
    /// keyboard interface
    /// - Parameter note: A MIDI note number
    /// - Parameter shape: The `OscillatorShape` of the note

    func pressNote(_ note: Int, shape: OscillatorShape)
    
    /// Erase the current note

    func eraseNote()
    
    /// This method is called when a navigation command is sent from a
    /// keyboard interface, such as a computer keyboard.
    /// - Parameter direction: The navigation direction

    func didNavigate(by direction: Int)
    
    /// Set the octave of the current note
    /// - Parameter octave: The desired octave
    
    func setOctave(_ octave: Int)
    
    /// Set the oscillator of the current note
    /// - Parameter next: Whether the next oscillator or the
    /// previous oscillator should is desired by the user

    func setOscillator(_ next: Bool)
}

/**
 This extension provides default implementations for the KeyboardListener protocol,
 thereby relaxing the requirement for subclassers to implement each one.
*/

extension KeyboardListener {
    func pressNote(_ note: Int, shape: OscillatorShape) {}
    func eraseNote() {}
    func setOctave(_ octave: Int) {}
    func setOscillator(_ next: Bool) {}
    func didNavigate(by direction: Int) {}
}

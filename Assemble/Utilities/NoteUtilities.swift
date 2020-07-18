//  Assemble
//  ============================
//  Created by David Spry on 30/3/20.
//  Copyright © 2020 David Spry. All rights reserved.

import Foundation

/// A collection of utilities for representing, decoding, and describing notes.

struct NoteUtilities
{
    typealias Note = (xy: CGPoint, note: Int, shape: OscillatorShape)

    /// Decode Note attributes from an encoded string and return an array of note attributes.
    ///
    /// - Parameter encoded: A substring containing encoded Notes.
    ///
    /// - Note:
    /// Swift treats the string \r\n (scalars 10, 13) as a single character. This can be avoided by
    /// using the `unicodeScalars` property of the `Substring`, which allows the scalars
    /// to be read individualy.
    ///
    /// The value of each note attribute is added with one prior
    /// to encoding in order to preclude the inclusion of zeroes, which are
    /// encoded as a null terminator character. Therefore, one should be
    /// subtracted from the decoded ASCII value.
    ///
    /// - SeeAlso:
    /// `./Core/DSP Components/Sequencer/Note.hpp`
    
    public static func decode(from encoded: Substring) -> [Note] {
        var notes = [Note]()

        let range = encoded.split(separator: "~", maxSplits: .max, omittingEmptySubsequences: true)
        if !range.isEmpty {
            for substring in range {
                let note = substring.unicodeScalars
                if (note.count < 5) || (note.first?.value) ?? 0 < 4 {
                    let warning = "[NoteUtilities] Note encoded with fewer than 4 attributes:"
                    print(warning, note.map { $0.value })
                    continue
                }

                let data = note.map { Int($0.value) - 1 }
                let xy = CGPoint(x: data[1], y: data[2])
                let pitch = data[3]
                let shape = OscillatorShape.init(rawValue: data[4]) ?? OscillatorShape.sine
                notes.append((xy, pitch, shape))
            }
        }

        return notes
    }

    /// Represent the given note information as a string
    /// - Parameter note: The note number of the note to describe
    /// - Parameter oscillator: The oscillator used by the note to describe

    public static func describe(_ note: Int, oscillator: OscillatorShape) -> String {
        return "\(notename(of: note))\(octave(of: note)) \(oscillator.code)"
    }

    /// Compute the octave number of the given note number
    /// - Parameter note: The note number of the note whose octave number should be computed

    public static func octave(of note: Int) -> Int {
        return note / 12 - 1
    }
    
    /// Modify the given note such that it belongs to the given octave, then return its note number.
    /// - Parameter note: The note number of the note to be modified
    /// - Parameter octave: The desired octave
    /// - Returns: The note number of the note whose note name matches the given note and whose octave matches the given number

    public static func modify(note: Int, withOctave octave: Int) -> Int {
        return (note % 12) + 12 * (octave + 1)
    }

    /// Find the note name of the given note
    /// - Parameter note: The note number of the note whose note name is desired

    public static func notename(of note: Int) -> String {
        return notenames[note % 12]
    }

    /// The name of each musical note

    private static let notenames: [String] = ["C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"];
}

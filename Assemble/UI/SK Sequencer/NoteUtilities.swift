//  Assemble
//  ============================
//  Created by David Spry on 30/3/20.
//  Copyright © 2020 David Spry. All rights reserved.

import Foundation

struct NoteUtilities
{
    typealias Note = (xy: CGPoint, note: Int, shape: OscillatorShape)

    /// Decode Note attributes from an encoded string and return an array of note attributes.
    ///
    /// - Parameter encoded: A substring containing encoded Notes.
    ///
    /// - Note:
    /// The value of each note attribute is added with one prior
    /// to encoding in order to preclude the inclusion of zeroes, which are
    /// encoded as a null terminator character. Therefore, one should be
    /// subtracted from the decoded ASCII value.
    ///
    /// - SeeAlso:
    /// `./Core/Components/Sequencer/Note.hpp`
    
    public static func decode(from encoded: Substring) -> [Note] {
        var notes = [Note]()

        let range = encoded.split(separator: "#", maxSplits: .max, omittingEmptySubsequences: true)
        if !range.isEmpty {
            for note in range {
                if (note.count < 5) || (note.first?.asciiValue ?? 0) < 4 {
                    print("[NoteUtilities] Note encoded with fewer than 4 attributes: \(note.map{ $0.asciiValue })")
                    continue
                }

                let data = note.map { Int($0.asciiValue ?? 1) - 1 }
                let xy = CGPoint(x: data[1], y: data[2])
                let note = data[3]
                let shape = OscillatorShape.init(rawValue: data[4]) ?? OscillatorShape.sine
                notes.append((xy, note, shape))
            }
        }

        return notes
    }

    public static func describe(_ note: Int, oscillator: OscillatorShape) -> String {
        return "\(notename(of: note))\(octave(of: note)) \(oscillator.code)"
    }

    public static func octave(of note: Int) -> Int {
        return note / 12 - 1
    }
    
    public static func modify(note: Int, withOctave octave: Int) -> Int {
        return (note % 12) + 12 * (octave + 1)
    }

    public static func notename(of note: Int) -> String {
        return notenames[note % 12]
    }

    private static let notenames: [String] = ["C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"];
}

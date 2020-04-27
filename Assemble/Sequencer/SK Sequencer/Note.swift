//  Assemble
//  ============================
//  Created by David Spry on 30/3/20.
//  Copyright © 2020 David Spry. All rights reserved.

import UIKit

class Note : Equatable
{
    static let notenames: [String] = ["C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"];
    
    let xy         : CGPoint
    var note       : Int = 0
    var octave     : Int = 0
    var oscillator : OscillatorShape
    var notename   : String {
        get { return Note.notenames[note % 12]; }
    }

    init(_ note: Int, octave: Int, oscillator osc: OscillatorShape, at point: CGPoint) {
        self.xy = point;
        oscillator = osc;
        setOctave(to: octave);
        setPitch(to: note);
    }
    
    init(_ note: Int, oscillator osc: OscillatorShape, at point: CGPoint) {
        self.xy = point;
        oscillator = osc;
        inferOctave(from: note);
        setPitch(to: note);
    }

    func modify(note: Int) {
        inferOctave(from: note);
        setPitch(to: note);
    }
    
    func modify(octave: Int) {
        setOctave(to: octave);
    }
    
    static func == (lhs: Note, rhs: Note) -> Bool
    {
        return lhs.note == rhs.note &&
               lhs.octave == rhs.octave &&
               lhs.oscillator == rhs.oscillator &&
               lhs.xy == rhs.xy
    }
    
    func cycle(oscillator next: Bool)
    {
        if next { oscillator = oscillator.next(); }
        else    { oscillator = oscillator.previous(); }
    }
    
    internal func set(pitch: Int, octave: Int)
    {
        assert(!(pitch < 0 || pitch > 127))
        assert(!(octave < -1 || octave > 9));
        self.note = pitch
        self.octave = octave
        self.update()
    }
    
    internal func setPitch(to pitch: Int)
    {
        assert(!(pitch < 0 || pitch > 127))
        self.note = pitch
        self.update()
    }
    
    internal func inferOctave(from pitch: Int)
    {
        octave = Int(pitch / 12)
        self.update()
    }
    
    internal func setOctave(to octave: Int)
    {
        assert(!(octave < -1 || octave > 9))
        self.octave = octave
    }
    
    internal func update()
    {
        note = 12 * (octave + 1) + (note % 12)
    }
    
    class func describe(_ note: Int, oscillator: OscillatorShape) -> String {
        return "\(notename(of: note))\(octave(of: note)) \(oscillator.code)"
    }
    
    class func octave(of note: Int) -> Int {
        return note / 12
    }
    
    class func notename(of note: Int) -> String {
        return notenames[note % 12]
    }

}

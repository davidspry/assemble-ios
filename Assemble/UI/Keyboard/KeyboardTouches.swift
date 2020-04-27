//  Assemble
//  ============================
//  Created by David Spry on 3/4/20.
//  Copyright © 2020 David Spry. All rights reserved.

import UIKit

extension Keyboard
{
    open override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        guard let touch = touches.first else { return }
        guard let note = noteFromTouchLocation(touch.location(in: self)) else { return }

        pressNote(note);
        self.layer.setNeedsDisplay();
    }
    
    open override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        guard let touch = touches.first else { return }
        if let note = noteFromTouchLocation(touch.location(in: self)) {
            if      note == pressedKey { return }
            else if note != pressedKey { pressNote(note) }
            else                       { releaseNote(note) }
            
        }

        self.layer.setNeedsDisplay();
    }

    open override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        for touch in touches {
            if let note = noteFromTouchLocation(touch.location(in: self)) {
                releaseNote(note);
            }
        }
        
        if pressedKey != nil { releaseNote(pressedKey!) }
        self.layer.setNeedsDisplay();
    }
    
    internal func noteFromTouchLocation(_ location: CGPoint) -> Int?
    {
        let padding = margins.left + margins.right
        guard bounds.contains(location) else { return nil }
        guard location.x > padding      else { return nil }
        guard location.x < padding + octaveSize.width * CGFloat(self.octaves)
        else { return nil }

        var key  : Int = 0
        var index: Int = 0
        
        let y = location.y
        let x = location.x - keyRadius - keyRadius - padding + 0.5 * keyStep
        
        let octaveRange = octave + octaves
        let localOctave = min(octaveRange, octave + Int(x / octaveSize.width));

        let B = bounds.midY + 0.5 * octaveSize.height + keyRadius + keyStroke
        let T = B - octaveSize.height - keySize.height - keyStroke
        let M = 0.5 * (T + B)

        if y > B || y < T { return nil }

        if y > M {
            let whiteKeyRange = octaves * 7 - 1
            index = min(whiteKeyRange, Int(x / keyStep))
            key = whiteKeyIndices[index % 7]
        }
        
        else if y > T {
            index = Int((x + 0.5 * keyStep) / keyStep)
            key = blackKeyIndices[index % 7]
            if key == 0 { return nil }
        }

        return max(0, localOctave * 12 + key)
    }
}

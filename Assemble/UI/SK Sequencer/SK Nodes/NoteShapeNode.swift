//  Assemble
//  Created by David Spry on 31/3/20.
//  Copyright © 2020 David Spry. All rights reserved.

import UIKit
import SpriteKit

/// An `SKShapeNode` to represent a note on the `SequencerScene`

class NoteShapeNode : SKShapeNode
{
    private var colour : SKColor!

    convenience init?(type: OscillatorShape)
    {
        self.init(circleOfRadius: 7)
        recolour(type: type)
    }
    
    /// Infer the colour of the note node from its oscillator.
    /// - Parameter type: The underlying note's `OscillatorShape`.

    public func recolour(type: OscillatorShape)
    {
        self.colour = UIColor.from(type)
        strokeColor = colour
        fillColor   = colour
        isAntialiased = true
    }
}

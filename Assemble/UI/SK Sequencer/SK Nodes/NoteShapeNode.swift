//  Assemble
//  Created by David Spry on 31/3/20.
//  Copyright © 2020 David Spry. All rights reserved.

import UIKit
import SpriteKit

class NoteShapeNode : SKShapeNode
{
    var colour : SKColor!
    
    convenience init?(type: OscillatorShape)
    {
        self.init(circleOfRadius: 7)
        recolour(type: type)
    }
    
    func recolour(type: OscillatorShape)
    {
        self.colour = UIColor.from(type);
        strokeColor = colour;
        fillColor   = colour;
        isAntialiased = true;
    }
}

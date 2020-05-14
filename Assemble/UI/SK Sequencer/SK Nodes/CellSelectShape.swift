//  Assemble
//  Created by David Spry on 1/4/20.
//  Copyright © 2020 David Spry. All rights reserved.

import UIKit
import SpriteKit

class CellSelectShape : SKShapeNode
{
    convenience init(size: Int)
    {
        self.init(rectOf: CGSize.square(size));
        lineWidth = 2.0
        lineJoin  = .round
        lineCap   = .round
    }
}

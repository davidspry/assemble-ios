//  Assemble
//  Created by David Spry on 1/4/20.
//  Copyright © 2020 David Spry. All rights reserved.

import UIKit
import SpriteKit

/// An `SKShapeNode` to represent the user's cursor on the `SequencerScene`

class CellSelectShape : SKShapeNode
{
    convenience init(size: Int)
    {
        self.init(rectOf: CGSize.square(size));
        lineWidth = 2.0
        lineJoin  = .round
        lineCap   = .round
        strokeColor = UIColor.init(named: "Foreground")!
    }
    
    /// Update the node's stroke colour.
    /// This should be called when a change is made to the user interface style.

    public func redraw() {
        strokeColor = UIColor.init(named: "Foreground")!
    }
}

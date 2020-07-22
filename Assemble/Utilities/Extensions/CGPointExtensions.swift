//  Assemble
//  Created by David Spry on 9/4/20.
//  Copyright © 2020 David Spry. All rights reserved.

import UIKit

extension CGPoint
{
    var nx: Int { return Int(x) }
    var ny: Int { return Int(y) }
    
    static func midpoint(of x: CGPoint, and y: CGPoint) -> CGPoint {
        return CGPoint(x: (x.x + y.x) / 2.0, y: (x.y + y.y) / 2.0)
    }
}

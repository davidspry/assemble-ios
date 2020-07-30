//  Assemble
//  Created by David Spry on 9/4/20.
//  Copyright © 2020 David Spry. All rights reserved.

import UIKit

extension CGPoint
{
    var nx: Int {
        set { x = CGFloat(x) }
        get { return  Int(x) }
    }

    var ny: Int {
        set { y = CGFloat(y) }
        get { return  Int(y) }
    }

    /// Compute the middle point between the two given points, `x` and `y`.
    /// - Parameter x: The first of the two points.
    /// - Parameter y: The second of the two points.

    static func midpoint(of x: CGPoint, and y: CGPoint) -> CGPoint {
        return CGPoint(x: (x.x + y.x) / 2.0, y: (x.y + y.y) / 2.0)
    }
    
    /// Translate the point by the given distances in the x and y directions.
    /// - Parameter x: The distance to translate by in the x-direction.
    /// - Parameter y: The distance to translate by in the y-direction.

    mutating func translate(x: CGFloat, y: CGFloat) {
        let translation = CGAffineTransform(translationX: x, y: y)
        self = self.applying(translation)
    }
}

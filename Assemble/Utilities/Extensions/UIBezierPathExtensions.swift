//  Assemble
//  Created by David Spry on 25/4/20.
//  Copyright © 2020 David Spry. All rights reserved.

import UIKit

extension  UIBezierPath {
    
    /// Generate a circle with the given radius at the given centre point.
    /// - Parameter centre: The centre point of the desired circle
    /// - Parameter radius: The radius of the desired circle

    convenience init(arcCentre centre: CGPoint, radius: CGFloat) {
        self.init(arcCenter: centre, radius: radius, startAngle: 0, endAngle: 360, clockwise: true);
    }
    
    /// Add a circle with the given radius at the given centre point to the path.
    /// - Parameter centre: The centre point of the desired circle
    /// - Parameter radius: The radius of the desired circle

    func addArc(withCentre centre: CGPoint, radius: CGFloat) {
        addArc(withCenter: centre, radius: radius, startAngle: 0, endAngle: 360, clockwise: true);
    }
    
    /// Add a square with the given centre point and given length to the path.
    /// - Parameter centre: The centre point of the desired square
    /// - Parameter length: The length of the desired square's sides

    func addSquare(withCentre centre: CGPoint, length: CGFloat) {
        var origin = CGPoint()
        origin.x = centre.x - length * 0.5
        origin.y = centre.y - length * 0.5
        
        move(to: origin)
        
        origin.x = origin.x + length
        addLine(to: origin)
        
        origin.y = origin.y + length
        addLine(to: origin)
        
        origin.x = origin.x - length
        addLine(to: origin)

        close()
    }
    
}

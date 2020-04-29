//  Assemble
//  Created by David Spry on 25/4/20.
//  Copyright © 2020 David Spry. All rights reserved.

import UIKit

extension  UIBezierPath {
    
    convenience init(arcCentre centre: CGPoint, radius: CGFloat) {
        self.init(arcCenter: centre, radius: radius, startAngle: 0, endAngle: 360, clockwise: true);
    }
    
    func addArc(withCentre centre: CGPoint, radius: CGFloat) {
        addArc(withCenter: centre, radius: radius, startAngle: 0, endAngle: 360, clockwise: true);
    }
    
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
        
//        origin.y = origin.y - length
//        addLine(to: origin)
        
        close()
    }
    
}

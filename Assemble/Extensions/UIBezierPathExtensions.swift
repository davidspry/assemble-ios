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
    
}

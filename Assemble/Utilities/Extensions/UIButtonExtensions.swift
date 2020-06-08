//  Assemble
//  Created by David Spry on 1/6/20.
//  Copyright © 2020 David Spry. All rights reserved.

import UIKit

extension UIButton {
    
    /// Begin a pulsating animation
    
    func pulsate() {
        let animation = CABasicAnimation()
            animation.fromValue = 1.00
            animation.toValue   = 1.15
            animation.duration  = 0.45
            animation.autoreverses = true
            animation.repeatCount  = .greatestFiniteMagnitude

        layer.add(animation, forKey: "transform.scale")
    }
    
    /// End any pulsating animations
    
    func pulsateEnd() {
        layer.removeAnimation(forKey: "transform.scale")
    }

    /// Begin a clockwise rotation animation
    
    func rotateClockwise() {
        let animation = CABasicAnimation()
            animation.duration     = 1
            animation.fromValue    = 0
            animation.toValue      = Float.pi * 2.0
            animation.repeatCount  = .greatestFiniteMagnitude
            animation.isCumulative = true
//            animation.timingFunction = .init(name: .easeInEaseOut)

        layer.add(animation, forKey: "transform.rotation.z")
    }
    
    /// End any clockwise rotation animations
    
    func rotateClockwiseEnd() {
        layer.removeAnimation(forKey: "transform.rotation.z")
    }
}

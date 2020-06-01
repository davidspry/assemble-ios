//  Assemble
//  Created by David Spry on 1/6/20.
//  Copyright © 2020 David Spry. All rights reserved.

import UIKit

extension UIButton {
    
    func pulsate() {
        let animation = CABasicAnimation(keyPath: "transform.scale")
            animation.fromValue = 1.00
            animation.toValue   = 1.15
            animation.duration  = 0.45
            animation.autoreverses = true
            animation.repeatCount  = .greatestFiniteMagnitude

        layer.add(animation, forKey: nil)
    }

}

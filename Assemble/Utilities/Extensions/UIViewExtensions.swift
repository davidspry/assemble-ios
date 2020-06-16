//  Assemble
//  Created by David Spry on 14/5/20.
//  Copyright © 2020 David Spry. All rights reserved.

import UIKit

extension UIView {
    
    /// The corner radus of the view

    @IBInspectable
    var cornerRadius: CGFloat {
        get { return layer.cornerRadius }
        set { layer.cornerRadius = newValue }
    }
    
    /// Whether or not the view should be masked to its bounds

    @IBInspectable
    var masksToBounds: Bool {
        get { return layer.masksToBounds }
        set { layer.masksToBounds = newValue }
    }
    
    /// Whether the view should use "continuous" corners or circular corners.
    
    @IBInspectable
    var continuousCorners: Bool {
        get { return layer.cornerCurve == .continuous }
        set {
            if newValue { layer.cornerCurve = .continuous }
            else        { layer.cornerCurve = .circular   }
        }
    }

}

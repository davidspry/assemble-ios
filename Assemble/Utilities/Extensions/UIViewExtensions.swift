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
    
    /// Add the given `UIView` as a subview, then bring it to the front of the subview stack.
    /// - Parameter view: The `UIView` to be added as a subview.

    func addSubviewToFront(_ view: UIView) {
        addSubview(view)
        bringSubviewToFront(view)
    }
    
    /// Scale the view's transform.
    /// - Parameter x: The x-axis scale factor.
    /// - Parameter y: The y-axis scale factor.

    func scaleBy(x: CGFloat, y: CGFloat) {
        let  transform = CGAffineTransform(scaleX: x, y: y)
        self.layer.setAffineTransform(transform)
    }

}

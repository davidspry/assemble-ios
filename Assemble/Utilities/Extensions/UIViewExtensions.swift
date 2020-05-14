//  Assemble
//  Created by David Spry on 14/5/20.
//  Copyright © 2020 David Spry. All rights reserved.

import UIKit

extension UIView {
    
    @IBInspectable
    var cornerRadius: CGFloat {
        get { return layer.cornerRadius }
        set { layer.cornerRadius = newValue }
    }
    
    @IBInspectable
    var masksToBounds: Bool {
        get { return layer.masksToBounds }
        set { layer.masksToBounds = newValue }
    }
    
    @IBInspectable
    var continuousCorners: Bool {
        get { return layer.cornerCurve == .continuous }
        set {
            if newValue { layer.cornerCurve = .continuous }
            else        { layer.cornerCurve = .circular   }
        }
    }

}

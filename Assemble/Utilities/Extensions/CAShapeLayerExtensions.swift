//  CAShapeLayerExtensions.swift
//  Assemble
//  Created by David Spry on 24/8/20.
//  Copyright © 2020 David Spry. All rights reserved.

import UIKit

extension CAShapeLayer {
    
    /// Perform an action with CA actions suppressed, which prevents animations from occuring.
    /// - Parameter action: The action to perform.

    func performWithoutActions(_ action: @escaping () -> ()) {
        CATransaction.begin()
        CATransaction.setDisableActions(true)
            action()
        CATransaction.commit()
    }

}

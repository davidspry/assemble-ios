//  Assemble
//  Created by David Spry on 25/4/20.
//  Copyright © 2020 David Spry. All rights reserved.

import UIKit

extension UIViewController {
    /**
     Add a `UIViewController` as a child, then add its `UIView` to the bottom of the subview hierarchy.
     
     - Author: John Sundell
     - Note: Source: https://www.swiftbysundell.com/articles/using-child-view-controllers-as-plugins-in-swift/
     */
    func addInBackground(_ child: UIViewController) {
        addChild(child)
        view.addSubview(child.view)
        view.sendSubviewToBack(child.view)
        child.didMove(toParent: self)
    }
}

//  Assemble
//  Created by David Spry on 3/5/20.
//  Copyright © 2020 David Spry. All rights reserved.

import UIKit

extension UIImage {
    
    /// Author: rmaddy
    /// Source: <https://stackoverflow.com/a/57454731/9611538>

    public convenience init(color: UIColor, size: CGSize) {
        UIGraphicsBeginImageContextWithOptions(size, false, 1)
        color.set()
        let ctx = UIGraphicsGetCurrentContext()!
        ctx.fill(CGRect(origin: .zero, size: size))
        let image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()

        self.init(data: image.pngData()!)!
    }
}

//  Assemble
//  Created by David Spry on 3/5/20.
//  Copyright © 2020 David Spry. All rights reserved.

import UIKit

extension UIImage {

    /// Author: 'rmaddy'
    /// Source: <https://stackoverflow.com/a/57454731/9611538>

    public convenience init(color: UIColor, size: CGSize) {
        UIGraphicsBeginImageContextWithOptions(size, false, 1)
        
        guard let ctx = UIGraphicsGetCurrentContext() else {
            self.init()
            return
        }
        
        color.set()
        ctx.fill(CGRect(origin: .zero, size: size))
        
        guard let image = UIGraphicsGetImageFromCurrentImageContext() else {
            self.init()
            return
        }
        
        UIGraphicsEndImageContext()

        guard let data = image.pngData() else {
            self.init()
            return
        }

        self.init(data: data)!
    }
}

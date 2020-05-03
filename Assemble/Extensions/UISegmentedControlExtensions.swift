//  Assemble
//  Created by David Spry on 3/5/20.
//  Copyright © 2020 David Spry. All rights reserved.

import UIKit

extension UISegmentedControl {
    func setDividerImage(_ image: UIImage) {
        setDividerImage(image,
                        forLeftSegmentState: .normal, rightSegmentState: .normal,
                        barMetrics: .default)
    }
}

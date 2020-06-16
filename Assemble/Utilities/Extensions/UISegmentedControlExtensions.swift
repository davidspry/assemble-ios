//  Assemble
//  Created by David Spry on 3/5/20.
//  Copyright © 2020 David Spry. All rights reserved.

import UIKit

extension UISegmentedControl {

    /// Set the divider image for the normal left and right segment states and default bar metrics.
    /// - Parameter image: The image that should be used to set the divider image.

    func setDividerImage(_ image: UIImage) {
        setDividerImage(image,
                        forLeftSegmentState: .normal, rightSegmentState: .normal,
                        barMetrics: .default)
    }

}

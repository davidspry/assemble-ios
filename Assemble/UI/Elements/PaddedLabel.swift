//  Assemble
//  Created by David Spry on 24/4/20.
//  Copyright © 2020 David Spry. All rights reserved.

import UIKit

/// A UILabel with padding that can be set from the interface builder.
///
/// - Author: Tai Le
/// - Note: Source: <https://stackoverflow.com/a/32368958/9611538>

@IBDesignable
class PaddedLabel: UILabel {
    @IBInspectable var topInset    : CGFloat = 5.0
    @IBInspectable var bottomInset : CGFloat = 5.0
    @IBInspectable var leftInset   : CGFloat = 7.0
    @IBInspectable var rightInset  : CGFloat = 7.0

    override func drawText(in rect: CGRect) {
        let insets = UIEdgeInsets(top: topInset, left: leftInset, bottom: bottomInset, right: rightInset)
        super.drawText(in: rect.inset(by: insets))
    }

    override var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize
        return CGSize(width: size.width + leftInset + rightInset,
                      height: size.height + topInset + bottomInset)
    }
}

//  Assemble
//  Created by David Spry on 30/7/20.
//  Copyright © 2020 David Spry. All rights reserved.

import UIKit

class ColouredButton: UIButton {
    
    convenience init(title: String, _ backgroundColour: UIColor, _ textColour: UIColor) {
        self.init(backgroundColour: backgroundColour, textColour: textColour)
        self.setTitle(title, for: .normal)
    }
    
    convenience init(backgroundColour: UIColor, textColour: UIColor) {
        let frame = CGRect(origin: .zero, size: .square(30))
        self.init(frame: frame, backgroundColour: backgroundColour, textColour: textColour)
    }

    convenience init(frame: CGRect, backgroundColour: UIColor, textColour: UIColor) {
        self.init(type: .system)
        initialise(frame: frame, radius: 10)
        setTitleColour(to: textColour)
        backgroundColor = backgroundColour
    }
    
    internal func initialise(frame: CGRect, radius: CGFloat) {
        self.frame = frame
        self.layer.cornerCurve   = .circular
        self.layer.cornerRadius  = radius
        self.layer.masksToBounds = true

        self.setTitle("?", for: .normal)
        self.titleLabel?.font = UIFont(name: "JetBrainsMono-Medium", size: 13)
    }

    public func setCornerRadius(to radius: CGFloat) {
        self.layer.cornerRadius = radius
    }
    
    public func setTitleColour(to colour: UIColor) {
        setTitleColor(colour, for: .normal)
    }

}

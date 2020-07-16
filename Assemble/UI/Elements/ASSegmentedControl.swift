//  Assemble
//  Created by David Spry on 16/7/20.
//  Copyright © 2020 David Spry. All rights reserved.

import UIKit

class ASSegmentedControl: UISegmentedControl {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        stylise()
    }
    
    override init(items: [Any]?) {
        super.init(items: items)
        stylise()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        stylise()
    }
    
    private func stylise() {
        setCustomFont()
        setCustomAppearance()
    }
    
    private func setCustomFont() {
        let font = UIFont.init(name: "JetBrainsMono-Regular", size: 13)
        let secondaryColour = UIColor.init(named: "Secondary") ?? UIColor.lightText
        setTitleTextAttributes([.foregroundColor : UIColor.white],   for: .selected)
        setTitleTextAttributes([.foregroundColor : secondaryColour], for: .normal)
        setTitleTextAttributes([.foregroundColor : secondaryColour], for: .highlighted)
        setTitleTextAttributes([.font : font as Any], for: .normal)
        layoutIfNeeded()
    }
    
    private func setCustomAppearance() {
        masksToBounds = false
        backgroundColor = UIColor.clear
        selectedSegmentTintColor = UIColor.mutedOrange
        selectedSegmentIndex = 0
    }

}

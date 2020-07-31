//  OptionsScrollView.swift
//  Assemble
//  Created by David Spry on 28/7/20.
//  Copyright © 2020 David Spry. All rights reserved.

import UIKit

class OptionsScrollView: UIScrollView {

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        isScrollEnabled = true
    }

}

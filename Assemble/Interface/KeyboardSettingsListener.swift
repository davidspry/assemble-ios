//  Assemble
//  Created by David Spry on 25/4/20.
//  Copyright © 2020 David Spry. All rights reserved.

import Foundation

protocol KeyboardSettingsListener: AnyObject {
    func didChangeOctave(to octave: Int)
}

//  Assemble
//  Created by David Spry on 14/7/20.
//  Copyright © 2020 David Spry. All rights reserved.

import Foundation

extension Collection {

    /// Indicaet whether the `Collection` contains any elements or not.

    var isNotEmpty: Bool {
        get { return !(self.isEmpty) }
    }

}

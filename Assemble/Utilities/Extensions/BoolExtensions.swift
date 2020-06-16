//  Assemble
//  Created by David Spry on 2/5/20.
//  Copyright © 2020 David Spry. All rights reserved.

import Foundation

extension Bool {

    /// Infer a boolean value from an integer.

    init(_ from: Int) {
        let value = NSNumber(integerLiteral: from)
        self = Bool(truncating: value)
    }

}

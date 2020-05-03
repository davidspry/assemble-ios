//  Assemble
//  Created by David Spry on 2/5/20.
//  Copyright © 2020 David Spry. All rights reserved.

import Foundation

extension Bool {

    init(_ from: Int) {
        let value = NSNumber(integerLiteral: from)
        self = Bool(truncating: value)
    }

}

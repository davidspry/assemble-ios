//  Assemble
//  Created by David Spry on 5/12/20.
//  Copyright © 2020 David Spry. All rights reserved.

import Foundation

extension Array {
    
    /// Move an element to a new index.
    /// - Parameter from: The location of the element to be moved.
    /// - Parameter to:   The new location for the selected element.

    mutating func move(from a: Index, to b: Index) {
        insert(remove(at: a), at: b)
    }

}

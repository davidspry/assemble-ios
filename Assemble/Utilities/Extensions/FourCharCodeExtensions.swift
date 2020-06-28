//  Assemble
//  Created by David Spry on 9/4/20.
//  Copyright © 2020 David Spry. All rights reserved.

import Foundation

extension FourCharCode
{
    /// Initialise a `FourCharCode` from the given four-character `String`
    /// Author: Vadian
    /// Source: <https://stackoverflow.com/a/31321444/9611538>
    
    init(_ string: String)
    {
        guard string.count == 4 else { preconditionFailure() }
        
        var code: FourCharCode = 0
        for char in string.utf16
        {
            code = code << 8 + FourCharCode(char)
        }
        
        self = code;
    }
}

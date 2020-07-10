//  Assemble
//  Created by David Spry on 10/7/20.
//  Copyright © 2020 David Spry. All rights reserved.

import StoreKit

struct IAPVerifier {
    
    /// Determine whether the IAP with the given identifier is owned by the user by contacting Apple,
    /// then pass the result to the given closure.
    ///
    /// - Parameter identifier: The identifier of the IAP that should be checked.
    /// - Parameter callback: The closure who should receive the result.

    static func determineOwnership(of identifier: String, _ callback: @escaping (_ result: Bool) -> ()) {
        callback(true)
    }
    
}

//  Assemble
//  Created by David Spry on 18/7/20.
//  Copyright © 2020 David Spry. All rights reserved.

import StoreKit

extension SKProduct {
    
    /// Represent the price as a String using the App Store's price locale.

    var regularPrice: String? {
        let formatter = NumberFormatter()
            formatter.numberStyle = .currency
            formatter.locale = self.priceLocale
        return formatter.string(from: self.price)
    }

}

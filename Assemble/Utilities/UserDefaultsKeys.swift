//  Assemble
//  Created by David Spry on 10/7/20.
//  Copyright © 2020 David Spry. All rights reserved.

import Foundation

struct UserDefaultsKeys {
    
    /// A Bool value indicating whether Assemble's IAP (to disable periodic white noise) has been purchased or not.
    /// - Note: This key contains the Product ID of Assemble's IAP, 'Assemble Unlocked'.

    static let iap = "io.davidspry.assemble.iap.001"
    
    /// A Bool value indicating whether Assemble is being launched for the first time

    static let isFirstLaunch = "assemble.first.launch"
    
    /// A Bool value indicating whether the theme is dark (`true`) or light (`false`).

    static let isDarkTheme = "assemble.theme"
}

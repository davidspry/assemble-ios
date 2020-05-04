//  ClosedRangeExtensions.swift
//  Assemble
//  Created by David Spry on 25/4/20.
//  Copyright © 2020 David Spry. All rights reserved.

import Foundation

extension ClosedRange {

    static func normal<T: FloatingPoint>() -> ClosedRange<T>
    {
        return T(0)...T(1)
    }

}

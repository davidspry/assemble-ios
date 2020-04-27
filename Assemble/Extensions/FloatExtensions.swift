//  FloatExtensions.swift
//  Assemble
//
//  Created by David Spry on 9/4/20.
//  Copyright © 2020 David Spry. All rights reserved.

extension Float
{
    /// Author: Zev Eisenberg
    /// Source: <https://gist.github.com/ZevEisenberg/7ababb61eeab2e93a6d9#file-map-float-range-swift>

    func map(from: ClosedRange<Float>, to: ClosedRange<Float>) -> Float
    {
        var value: Float = 0.0
        value = ((self - from.lowerBound) / (from.upperBound - from.lowerBound))
        value = value * (to.upperBound - to.lowerBound) + to.lowerBound;
        return max(to.lowerBound, min(value, to.upperBound));
    }
}

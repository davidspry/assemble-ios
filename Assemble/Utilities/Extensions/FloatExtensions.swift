//  Assemble
//  Created by David Spry on 9/4/20.
//  Copyright © 2020 David Spry. All rights reserved.

extension Float
{
    /// Map a value from one range to another range.
    /// - SeeAlso: <https://gist.github.com/ZevEisenberg/7ababb61eeab2e93a6d9#file-map-float-range-swift>
    /// - Author: Zev Eisenberg

    func map(from: ClosedRange<Float>, to: ClosedRange<Float>) -> Float
    {
        var value: Float = 0.0
        value = ((self - from.lowerBound) / (from.upperBound - from.lowerBound))
        value = value * (to.upperBound - to.lowerBound) + to.lowerBound;
        return max(to.lowerBound, min(value, to.upperBound));
    }
    
    /// Map a value from the range [0, 1] to some other range, then round it to the nearest `steps` increment.
    /// - Parameter range: The range to map the input value to
    /// - Parameter steps: The value that defines the interval, of which some integer multiple will be returned.

    func mapNormal(to range: ClosedRange<Float>, of steps: Float) -> Float
    {
        let map = range.lowerBound + (range.upperBound - range.lowerBound) * pow(self, 1)
        if  map == 0 { return 0 }
        return (self / steps).rounded(.towardZero) * steps
    }
    
    /// Ensure that a Float, `x`, is `A <= x <= B` for any Floats `A`, `B`, where `A <= B`.

    mutating func bound(by range: ClosedRange<Float>)
    {
        self = max(range.lowerBound, min(range.upperBound, self))
    }
}

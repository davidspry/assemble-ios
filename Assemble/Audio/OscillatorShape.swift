//  Assemble
//  Created by David Spry on 12/4/20.
//  Copyright © 2020 David Spry. All rights reserved.

import Foundation

/// Constants and methods to define the oscillators available in Assemble

enum OscillatorShape : Int, CustomStringConvertible
{
    case sine
    case triangle
    case square
    case sawtooth
    case oscillators

    /// The description property is required in order to conform to `CustomStringConvertible`

    var description: String { return name }

    /// The name of the `OscillatorShape`
    
    var name: String {
        switch self {
        case .sine:     return "Sine"
        case .triangle: return "Triangle"
        case .square:   return "Square"
        case .sawtooth: return "Sawtooth"
        case .oscillators: return ""
        }
    }

    /// An abbreviated code-name for the `OscillatorShape`
    
    var code: String {
        switch self {
        case .sine:     return "SIN"
        case .triangle: return "TRI"
        case .square:   return "SQR"
        case .sawtooth: return "SAW"
        case .oscillators: return ""
        }
    }
    
    /// Return the next `OscillatorShape` from the available constants

    func next() -> OscillatorShape {
        let newRawValue = (self.rawValue + 1) % OscillatorShape.oscillators.rawValue;
        return OscillatorShape(rawValue: newRawValue) ?? .sine;
    }
    
    /// Return the previous `OscillatorShape` from the available constants
    
    func previous() -> OscillatorShape {
        let newRawValue = (self.rawValue - 1 + OscillatorShape.oscillators.rawValue) % OscillatorShape.oscillators.rawValue
        return OscillatorShape(rawValue: newRawValue) ?? .sine;
    }
}

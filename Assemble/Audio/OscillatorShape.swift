//  Assemble
//  Created by David Spry on 12/4/20.
//  Copyright © 2020 David Spry. All rights reserved.

import Foundation

enum OscillatorShape : Int
{
    case sine
    case triangle
    case square
    case sawtooth
    case oscillators
    
    var name: String {
        switch self {
        case .sine:     return "Sine"
        case .triangle: return "Triangle"
        case .square:   return "Square"
        case .sawtooth: return "Sawtooth"
        case .oscillators: return ""
        }
    }

    var code: String {
        switch self {
        case .sine:     return "SIN"
        case .triangle: return "TRI"
        case .square:   return "SQR"
        case .sawtooth: return "SAW"
        case .oscillators: return ""
        }
    }
    
    func next() -> OscillatorShape {
        let newRawValue = (self.rawValue + 1) % OscillatorShape.oscillators.rawValue;
        return OscillatorShape(rawValue: newRawValue) ?? .sine;
    }
    
    func previous() -> OscillatorShape {
        let newRawValue = (self.rawValue - 1 + OscillatorShape.oscillators.rawValue) % OscillatorShape.oscillators.rawValue
        return OscillatorShape(rawValue: newRawValue) ?? .sine;
    }
}

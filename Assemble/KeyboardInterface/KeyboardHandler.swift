//  Assemble
//  ============================
//  Created by David Spry on 24/4/20.
//  Copyright © 2020 David Spry. All rights reserved.

import UIKit

/// Constants representing commands within Assemble

enum KeyCommand : Int
{
    case none
    case mode
    case place
    case erase
    case navigate
    case transport

    case uoctave
    case noctave
    case uoscillator
    case noscillator
}

/// A mapping of computer keyboard keys to commands in Assemble

@available(iOS 13.4, *)
struct KeyboardHandler
{
    /// A Dictionary of keyboard keys and their corresponding commands in Assemble.

    private static let keys : [UIKeyboardHIDUsage : (action: KeyCommand, value: Int)] =
    [
        .keyboardSpacebar   : (.transport,0),
        .keyboardUpArrow    : (.navigate, 0),
        .keyboardDownArrow  : (.navigate, 1),
        .keyboardLeftArrow  : (.navigate, 2),
        .keyboardRightArrow : (.navigate, 3),
        .keyboard1 : (.noctave, 1),
        .keyboard2 : (.noctave, 2),
        .keyboard3 : (.noctave, 3),
        .keyboard4 : (.noctave, 4),
        .keyboard5 : (.noctave, 5),
        .keyboard6 : (.noctave, 6),
        .keyboard7 : (.noctave, 7),
        .keyboardA : (.place, 0x09),
        .keyboardB : (.place, 0x0B),
        .keyboardC : (.place, 0x00),
        .keyboardD : (.place, 0x02),
        .keyboardE : (.place, 0x04),
        .keyboardF : (.place, 0x05),
        .keyboardG : (.place, 0x07),
        .keyboardDeleteOrBackspace : (.erase, 0),
        .keyboardOpenBracket  : (.noscillator, 0),
        .keyboardCloseBracket : (.noscillator, 1),
        .keyboardTab : (.mode, 0)
    ]

    /// Parse input from an external computer keyboard and return a key, value pair denoting the appropriate response.
    /// - Parameter press: A keyboard press registered in `pressesBegan(presses:withEvent:)`
    /// - Parameter process: A callback where the key, value pair will be handled.

    static func parse(_ press: UIPress, _ process: @escaping (KeyCommand, Int) -> ())
    {
        guard let key = press.key,
              let kvp = keys[key.keyCode] else {
                return process(.none, 0)
        }

        if key.modifierFlags == .shift {
            switch (kvp.action)
            {
            case .place:       return process(.place, kvp.value + 1)
            case .noctave:     return process(.uoctave, kvp.value)
            case .noscillator: return process(.uoscillator, kvp.value)
            default:           break
            }
        }

        process(kvp.action, kvp.value)
    }
}

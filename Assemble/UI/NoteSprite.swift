//
//  NoteSprite.swift
//  SimpleSynthesiser
//
//  Created by David Spry on 31/3/20.
//  Copyright © 2020 David Spry. All rights reserved.
//

import UIKit
import SpriteKit

class NoteShapeNode : SKShapeNode
{
    static public let sineNoteColour     = #colorLiteral(red: 0.8941176471, green: 0.3647058824, blue: 0.3137254902, alpha: 1)
    static public let squareNoteColour   = #colorLiteral(red: 0.2235294118, green: 0.4941176471, blue: 0.3450980392, alpha: 1)
    static public let triangleNoteColour = #colorLiteral(red: 0.2862745098, green: 0.5098039216, blue: 0.8117647059, alpha: 1)
    static public let sawtoothNoteColour = #colorLiteral(red: 0.9647058824, green: 0.6274509804, blue: 0.3019607843, alpha: 1)

    var colour : SKColor!

    convenience init?(type: OscillatorShape)
    {
        self.init(circleOfRadius: 8)
        self.colour = NoteShapeNode.colour(oscillator: type);
        strokeColor = colour;
        fillColor   = colour;
        isAntialiased = true;
    }

    internal class func colour(oscillator: OscillatorShape) -> SKColor
    {
        switch oscillator
        {
        case .sine:     return sineNoteColour
        case .square:   return squareNoteColour
        case .triangle: return triangleNoteColour
        case .sawtooth: return sawtoothNoteColour
        default:        return .white;
        }
    }
}

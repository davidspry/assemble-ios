//  Assemble
//  ============================
//  Created by David Spry on 28/3/20.
//  Copyright © 2020 David Spry. All rights reserved.

import UIKit

extension Keyboard
{
    open override func draw(_ layer: CALayer, in ctx: CGContext)
    {
        for octave in 0 ..< octaves
        {
            drawOctave(octave);
        }
    }
    
    internal func initialisePaths()
    {
        setNeedsLayout()
        updateConstraintsIfNeeded()
        for octave in 0 ..< octaves
        {
            makeOctave(CGFloat(octave))
        }
    }
    
    internal func drawOctave(_ octave: Int)
    {
        let previousKeys = octave * 12
        let stroke: CGFloat = keyStroke

        for whiteKey in 0...6
        {
            let pressed = whiteKeyPressed(whiteKey, octave: octave)
            let colour = pressed ? keyOnColour : keyOffColour
            shapeLayers[previousKeys + whiteKey].lineWidth = pressed ? 1.0 : stroke;
            shapeLayers[previousKeys + whiteKey].strokeColor = colour.cgColor;
            shapeLayers[previousKeys + whiteKey].fillColor = colour.cgColor;
        }

        for (i, blackKey) in [1, 2, 4, 5, 6].enumerated()
        {
            let pressed = blackKeyPressed(blackKey, octave: octave)
            let colour = pressed ? keyOnColour : keyOffColour
            shapeLayers[previousKeys + 7 + i].lineWidth = pressed ? 1.0 : stroke;
            shapeLayers[previousKeys + 7 + i].strokeColor = colour.cgColor;
            shapeLayers[previousKeys + 7 + i].fillColor = colour.cgColor;
        }
    }

    internal func makeOctave(_ octave: CGFloat)
    {
        let stroke: CGFloat = keyStroke
        let y = bounds.midY + 0.5 * octaveSize.height
        let r = keySize.width / 2.0

        for whiteKey in 0...6
        {
            let x = computeKeyX(whiteKey, octave: octave);
            let c = CGPoint(x: x + r * 2, y: y);
            let path = UIBezierPath(arcCentre: c, radius: r);
            
            let shapeLayer = CAShapeLayer()
            shapeLayer.shouldRasterize = true
            shapeLayer.allowsEdgeAntialiasing = true
            shapeLayer.rasterizationScale = 2.0 * UIScreen.main.scale
            shapeLayer.speed = 2.0
            shapeLayers.append(shapeLayer)
            
            shapeLayer.path = path.cgPath
            shapeLayer.fillColor = keyOffColour.cgColor;
            shapeLayer.strokeColor = keyOffColour.cgColor
            shapeLayer.lineWidth = stroke;
            layer.addSublayer(shapeLayer)
        }

        for blackKey in [1, 2, 4, 5, 6]
        {
            let x = computeKeyX(blackKey, octave: octave);
            let c = CGPoint(x: x, y: y - octaveSize.height);
            let path = UIBezierPath(arcCentre: c, radius: r);
            
            let shapeLayer = CAShapeLayer()
            shapeLayer.shouldRasterize = true
            shapeLayer.allowsEdgeAntialiasing = true
            shapeLayer.rasterizationScale = 2.0 * UIScreen.main.scale
            shapeLayer.speed = 2.0
            shapeLayers.append(shapeLayer)
            
            shapeLayer.path = path.cgPath
            shapeLayer.fillColor = keyOffColour.cgColor;
            shapeLayer.strokeColor = keyOffColour.cgColor
            shapeLayer.lineWidth = stroke;
            layer.addSublayer(shapeLayer)
        }
    }

    internal func computeKeyX(_ k: Int, octave: CGFloat) -> CGFloat
    {
        return margins.left + margins.right + CGFloat(k) * keyStep + octave * octaveSize.width;
    }
    
    internal func whiteKeyPressed(_ k: Int, octave: Int) -> Bool
    {
        let note = (self.octave + octave) * 12 + whiteKeyIndices[k];
        return pressedKey == note
    }
    
    internal func blackKeyPressed(_ k: Int, octave: Int) -> Bool
    {
        let note = (self.octave + octave) * 12 + blackKeyIndices[k];
        return pressedKey == note
    }
}

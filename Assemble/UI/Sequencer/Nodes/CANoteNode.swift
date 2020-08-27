//  Assemble
//  Created by David Spry on 26/8/20.
//  Copyright © 2020 David Spry. All rights reserved.

import UIKit

class CANoteNode : CAShapeLayer
{
    private let radius : CGFloat = 8
    private var colour : UIColor!

    convenience init(type: OscillatorShape) {
        self.init()
        initialise()
        recolour(type: type)
    }
    
    internal func initialise() {
        lineWidth = 2.0
        path      = UIBezierPath(arcCentre: .zero, radius: radius).cgPath
        edgeAntialiasingMask = .init(arrayLiteral: [.layerTopEdge, .layerBottomEdge, .layerLeftEdge, .layerRightEdge])
        allowsEdgeAntialiasing = true
        rasterizationScale = 2.0 * UIScreen.main.scale
        shouldRasterize = true
    }

    /// Infer the colour of the note node from its oscillator.
    /// - Parameter type: The underlying note's `OscillatorShape`.

    public func recolour(type: OscillatorShape) {
        self.colour = UIColor.from(type)
        fillColor   = colour.cgColor
        strokeColor = colour.cgColor
    }
}

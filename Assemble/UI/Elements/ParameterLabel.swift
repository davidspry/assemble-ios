//  Assemble
//  Created by David Spry on 14/5/20.
//  Copyright © 2020 David Spry. All rights reserved.

import UIKit

public enum ParameterLabelScale: Float {
    case continuousFast = 5
    case continuousRegular = 1E-1
    case continuousSlow = 2E-3
    case discreteFast   = 3E-1
    case discreteSlow   = 3E-2
}

class ParameterLabel: UILabel {
    
    internal var touch: CGPoint = .zero
    internal var lastTouch: CGPoint = .zero
    
    internal var value: Float = 0.0
    internal var format: String = "%.2f"
    internal var valueStrings: [String]?
    
    internal var parameterRange: ClosedRange<AUValue> = .normal()
    internal var parameterScale: Float = ParameterLabelScale.continuousFast.rawValue

    internal var parameter: Int32? {
        didSet {
            guard let parameter = parameter else { return }
            guard let tree = Assemble.core.commander?.parameterTree else { return }
            guard let node = tree.parameter(withAddress: AUParameterAddress(parameter)) else { return }

            parameterRange = node.minValue...node.maxValue
            value = Assemble.core.getParameter(parameter)
            valueStrings = node.valueStrings

            switch (node.unit)
            {
            case .BPM:     format = "%.0fBPM"
            case .ratio:   format = "%.0f%"
            default:       format = "%.2f"
            }

            update()
        }
    }

    public func initialise(with parameter: Int32, and type: ParameterLabelScale) {
        self.parameterScale = type.rawValue
        self.parameter = parameter
        update()
    }
    
    public func reinitialise() {
        guard let parameter = parameter else { return }
        value = Assemble.core.getParameter(parameter)
        update()
    }
    
    internal func update() {
        guard let parameter = parameter else { return }
        if valueStrings == nil || value < 0 || Int(value) > valueStrings!.count {
            text = String(format: format, Assemble.core.getParameter(parameter))
        }   else { text = valueStrings?[Int(value)] ?? "Error" }

        sizeToFit()
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        guard let touch = touches.first else { return }
        self.lastTouch = touch.location(in: self)
        self.touch = touch.location(in: self)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        guard let touch = touches.first else { return }
        self.lastTouch = self.touch
        self.touch = touch.location(in: self)
        
        let delta = parameterScale * Float(self.lastTouch.y - self.touch.y)
        value = max(parameterRange.lowerBound, min(value + Float(delta), parameterRange.upperBound))
        
        guard let parameter = parameter else { return }
        Assemble.core.setParameter(parameter, to: value)
        
        update()
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        self.lastTouch = .zero
        self.touch = .zero
    }

}

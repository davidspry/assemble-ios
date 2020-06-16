//  Assemble
//  Created by David Spry on 14/5/20.
//  Copyright © 2020 David Spry. All rights reserved.

import UIKit

/// A set of constants that define appropriate scrolling speeds for a ParameterLabel.

public enum ParameterLabelScale: Float {
    case continuousFast    = 5
    case continuousRegular = 1E-2
    case continuousSlow    = 2E-3
    case discreteFast      = 3E-1
    case discreteSlow      = 3E-2
}

/// A UILabel that is linked with an Assemble core parameter.
/// Dragging on a ParameterLabel sets the value of the underlying
/// parameter's value with some speed defined by a `ParameterLabelScale`.

class ParameterLabel: PaddedLabel {
    
    internal var touch: CGPoint = .zero
    internal var lastTouch: CGPoint = .zero
    
    internal var value: Float = 0.0
    internal var format: String = "%.2f"
    internal var rawValue: Float = 0.0
    internal var valueStrings: [String]?
    
    internal var node: AUParameter?
    
    internal var parameterRange: ClosedRange<AUValue> = .normal()
    internal var parameterScale: Float = ParameterLabelScale.continuousFast.rawValue
    internal var parameterStep: Float = 0.1

    /// The hexadecimal address of the Assemble core parameter.

    internal var parameter: Int32? {
        didSet {
            guard let parameter = parameter else { return }
            guard let tree = Assemble.core.commander?.parameterTree else { return }
            guard let node = tree.parameter(withAddress: AUParameterAddress(parameter)) else { return }

            rawValue = Assemble.core.getParameter(parameter)
            parameterRange = node.minValue...node.maxValue
            valueStrings = node.valueStrings
            value = rawValue

            switch (node.unit)
            {
            case .BPM:          format = "%.0fBPM"
            case .milliseconds: format = "%.0fms"
            default:            format = "%.2f"
            }

            update()
        }
    }

    /// Initialise the label with a parameter
    /// - Parameter parameter: The address of the parameter that should be linked with the label
    /// - Parameter increment: The increment by which the parameter's value should be increased and decreased
    /// - Parameter type: The type of parameter, which defines how quickly its value changes.

    public func initialise(with parameter: Int32, increment: Float, and type: ParameterLabelScale) {
        self.parameterScale = type.rawValue
        self.parameterStep  = increment
        self.parameter = parameter
        update()
    }
    
    /// Re-initialise the label from its existing parameter address

    public func reinitialise() {
        guard let parameter = parameter else { return }
        rawValue = Assemble.core.getParameter(parameter)
        value    = rawValue
        update()
    }
    
    /// Update the textual contents of the label from the label's `value` property

    internal func update() {
        if valueStrings == nil || value < 0 || Int(value) > valueStrings!.count {
            text = String(format: format, value)
        }   else { text = valueStrings?[Int(value)] ?? "Error" }
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
        guard let parameter = parameter else { return }
        self.lastTouch = self.touch
        self.touch = touch.location(in: self)

        let delta = parameterScale * Float(self.lastTouch.y - self.touch.y)
        rawValue = rawValue + delta
        rawValue.bound(by: parameterRange)
        value = rawValue.mapNormal(to: parameterRange, of: parameterStep)
        Assemble.core.setParameter(parameter, to: value)

        update()
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        self.lastTouch = .zero
        self.touch = .zero
    }

}

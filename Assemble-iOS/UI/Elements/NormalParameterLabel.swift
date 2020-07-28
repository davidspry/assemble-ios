//  Assemble
//  Created by David Spry on 27/7/20.
//  Copyright © 2020 David Spry. All rights reserved.

import UIKit

/// A label displaying a normal numeric value in [0, 1] that can be adjusted by dragging.
/// This value can be used to control other components by initialising the class's `setter` and `getter` properties.

class NormalParameterLabel: PaddedLabel {

    internal var touch:     CGPoint = .zero
    internal var lastTouch: CGPoint = .zero
    
    internal var rawValue: Float = 0.0
    internal var value:    Float = 0.0
    internal var format:   String = "%.2f"
    
    internal var parameterRange: ClosedRange<AUValue> = .normal()
    internal var parameterScale: Float = ParameterLabelScale.continuousSlow.rawValue
    internal var parameterStep:  Float = 0.01

    public var setter: ((Float) -> ())?
    
    public var getter: (() -> (Float))? {
        didSet {
            if  let getter = getter {
                self.value = getter()
                self.rawValue = value
                self.update()
            }
        }
    }

    internal func setParameter(to value: Float) {
        setter?(value)
    }
    
    internal func getParameter() -> Float {
        return getter?() ?? 0.0
    }
    
    internal func update() {
        text = String(format: format, value)
    }
    
    public func initialise(increment: Float, speed: ParameterLabelScale) {
        parameterStep = increment
        parameterScale = speed.rawValue
    }
    
    // MARK: - Touch callbacks

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        guard let touch = touches.first else { return }
        self.lastTouch  = touch.location(in: self)
        self.touch      = touch.location(in: self)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        guard let touch = touches.first else { return }
        self.lastTouch = self.touch
        self.touch     = touch.location(in: self)

        let delta = parameterScale * Float(self.lastTouch.y - self.touch.y)
        rawValue = rawValue + delta
        rawValue.bound(by: parameterRange)
        value = rawValue.mapNormal(to: parameterRange, of: parameterStep)
        setParameter(to: value)

        update()
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        self.lastTouch = .zero
        self.touch = .zero
    }
    
}

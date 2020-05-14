//  Assemble
//  Created by David Spry on 30/4/20.
//  Copyright © 2020 David Spry. All rights reserved.

import UIKit

class PatternOverview: UIView, UIGestureRecognizerDelegate {

    let activeColour    : UIColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
    let patternOnColour : UIColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
    let patternOffColour: UIColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)

    private var lastTappedNode: Int?
    private var lastTappedTime: TimeInterval?
    private var tapSpeedThreshold: TimeInterval = 0.5
    private var nodeDestination: Int?

    private let patterns: Int = Int(PATTERNS)
    private var states = [Bool]()
    private var shapes = [CAShapeLayer]()
    
    private var pattern : Int = 0 {
        willSet (newPattern) {
            shapes[pattern].strokeColor = nil
            shapes[newPattern].strokeColor = activeColour.cgColor
            shapes[newPattern].removeAllAnimations()
        }
    }

    private var nextPattern : Int = 0 {
        willSet (newPattern) {
            if newPattern == pattern {
                dequeue(&shapes[nextPattern])
                pattern = newPattern
                return
            }
            if nextPattern != pattern { dequeue(&shapes[nextPattern]) }
            enqueue(&shapes[newPattern])
        }
    }

    private let scalar = CGFloat(0.55)
    lazy private var rows = CGFloat(patterns / 4)
    lazy private var cols = CGFloat(patterns / Int(rows))
    lazy private var radius = min(0.5 * bounds.height / rows, 0.5 * bounds.width / cols)
    lazy private var diameter = radius * 2
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        isMultipleTouchEnabled = false
        shapes.reserveCapacity(patterns)
        states.reserveCapacity(patterns)
        
        for r in stride(from: 0, to: rows, by: 1) {
            for c in stride(from: 0, to: cols, by: 1) {
                let path = UIBezierPath()
                let layer = CAShapeLayer()
                
                let x = c * diameter + radius
                let y = r * diameter + radius
                path.addArc(withCentre: CGPoint(x: x, y: y), radius: radius * scalar)

                layer.path = path.cgPath
                layer.lineWidth = 3.0
                layer.strokeColor = nil
                layer.shouldRasterize = true
                layer.allowsEdgeAntialiasing = true
                layer.rasterizationScale = 2.0 * UIScreen.main.scale
                layer.fillColor = patternOffColour.cgColor
                self.layer.addSublayer(layer)
                shapes.append(layer)
                states.append(false)
            }
        }

        loadStates()
    }
    
    /// Poll the core for the state of each pattern. This should be called whenever a song is loaded.

    public func loadStates() {
        DispatchQueue.main.async {
            for pattern in 0 ..< self.patterns {
                Assemble.core.setParameter(kSequencerCurrentPattern, to: Float(pattern))
                let state = Bool(Int(Assemble.core.getParameter(kSequencerPatternState)))
                self.set(pattern: pattern, to: state)
            }

            self.reset()
        }
    }
    
    public func reset() {
        Assemble.core.setParameter(kSequencerCurrentPattern, to: Float(0))
        self.pattern = 0
    }

    /// Toggle the state of a `Pattern` and update its icon.
    /// - Parameter pattern: The index of the `Pattern` whose state should be toggled, starting from `0`.

    public func toggle(pattern: Int) {
        guard pattern > -1 && pattern < patterns else { return }
        let state = !states[pattern]
        set(pattern: pattern, to: state)
        Assemble.core.setParameter(kSequencerPatternState, to: Float(pattern))
    }

    /**
     Set the state of a `Pattern` icon.

     Setting the state of a `Pattern` in the Swift context obviates the need to regularly poll the C++ context
     for the state of each `Pattern`.

     - Parameter pattern: The index of the `Pattern` whose state should be set, starting from `0`.
     - Parameter state: The desired state to set.
     */

    private func set(pattern: Int, to state: Bool) {
        guard pattern > -1 && pattern < patterns else { return }
        states[pattern] = state
        shapes[pattern].fillColor = state ? patternOnColour.cgColor :
                                            patternOffColour.cgColor
    }
    
    private func enqueue(_ layer: inout CAShapeLayer) {
        let animation = CABasicAnimation()
        animation.fromValue = 0.0
        animation.toValue = 3.0
        animation.duration = 0.35
        animation.autoreverses = true
        animation.repeatCount = .greatestFiniteMagnitude
        layer.add(animation, forKey: "lineWidth")
        layer.strokeColor = activeColour.cgColor
    }
    
    private func dequeue(_ layer: inout CAShapeLayer) {
        layer.removeAllAnimations()
        layer.strokeColor = nil
    }
    
    internal func nodeFromTouchLocation(_ touch: CGPoint) -> Int? {
        if touch.x > diameter * (cols + 1) { return nil }
        if touch.y > diameter * (rows + 1) { return nil }
        
        let y = Int(touch.y / diameter)
        let x = Int(touch.x / diameter)
        
        return y * Int(cols) + x
    }

    private func handleDoubleTap(for node: Int) {
        if node == lastTappedNode, let time = lastTappedTime,
            (ProcessInfo.processInfo.systemUptime - time) < tapSpeedThreshold {
            toggle(pattern: node)
            lastTappedNode = nil
            nodeDestination = nil
        }
        
        else {
            lastTappedNode = node
            nodeDestination = node
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(175)) {
                guard let node = self.nodeDestination else { return }
                if Assemble.core.ticking {
                    self.nextPattern = node
                    Assemble.core.setParameter(kSequencerNextPattern, to: Float(node))
                }

                else {
                    Assemble.core.setParameter(kSequencerCurrentPattern, to: Float(node))
                }
            }
        }

        lastTappedTime = ProcessInfo.processInfo.systemUptime
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        guard let node = nodeFromTouchLocation(touch.location(in: self)) else { return }
        guard node > -1 && node < patterns else { return }
        handleDoubleTap(for: node)
    }

    override func draw(_ rect: CGRect) {}
    override func draw(_ layer: CALayer, in ctx: CGContext) {
        let currentPattern = Assemble.core.currentPattern
        if pattern != currentPattern {
            pattern = currentPattern
        }
    }
    
}

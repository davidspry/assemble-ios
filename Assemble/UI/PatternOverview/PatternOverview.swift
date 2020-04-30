//  PatternOverview.swift
//  Assemble
//  Created by David Spry on 30/4/20.
//  Copyright © 2020 David Spry. All rights reserved.

import UIKit

class PatternOverview: UIView {

    let activeColour    : UIColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
    let patternOnColour : UIColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
    let patternOffColour: UIColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)

    private let patterns: Int = Int(PATTERNS)
    private var states = [Bool]()
    private var shapes = [CAShapeLayer]()
    private var pattern : Int = 0 {
        willSet (newPattern) {
            shapes[pattern].strokeColor = nil
            shapes[newPattern].strokeColor = activeColour.cgColor
        }
    }
    

    private let scalar = CGFloat(0.55)
    lazy private var rows = CGFloat(patterns / 4)
    lazy private var cols = CGFloat(patterns / Int(rows))
    lazy private var radius = min(0.5 * bounds.height / rows, 0.5 * bounds.width / cols)

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        shapes.reserveCapacity(patterns)
        states.reserveCapacity(patterns)
        
        for r in stride(from: 0, to: rows, by: 1) {
            for c in stride(from: 0, to: cols, by: 1) {
                let path = UIBezierPath()
                let layer = CAShapeLayer()
                
                let x = c * (2 * radius) + radius
                let y = r * (2 * radius) + radius
                path.addArc(withCentre: CGPoint(x: x, y: y), radius: radius * scalar)

                layer.path = path.cgPath
                layer.lineWidth = 2.0
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

        states[0] = true
        shapes.first?.fillColor = patternOnColour.cgColor
        shapes.first?.strokeColor = activeColour.cgColor
    }

    /**
     Set the state of a `Pattern` icon. This should be called whenever the user toggles a `Pattern`'s state.
     Setting the state of a `Pattern` in the Swift context obviates the need to regularly poll the C++ context
     for the state of each `Pattern`.
     
     - Parameter pattern: The index of the `Pattern` whose state should be set, starting from `0`.
     - Parameter state: The Boolean state to set: `true` if the `Pattern` is enabled; `false` otherwise.
     */

    public func set(pattern: Int, to state: Bool) {
        if pattern > -1 && pattern < patterns {
            states[pattern] = state
            shapes[pattern].fillColor = state ? patternOnColour.cgColor :
                                                patternOffColour.cgColor
        }
    }
    
//        let square = UIBezierPath()
//        let x = CGFloat(Int(pattern % Int(cols))) * (2 * radius) + radius
//        let y = CGFloat(Int(pattern / Int(cols))) * (2 * radius) + radius
//        square.addSquare(withCentre: CGPoint(x: x, y: y), length: 2 * radius * 0.85)
    
    override func draw(_ rect: CGRect) {}
    override func draw(_ layer: CALayer, in ctx: CGContext) {
        let currentPattern = Assemble.core.currentPattern
        if pattern != currentPattern {
            pattern = currentPattern
        }
    }
    
}

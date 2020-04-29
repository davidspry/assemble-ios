//  PatternOverview.swift
//  Assemble
//  Created by David Spry on 30/4/20.
//  Copyright © 2020 David Spry. All rights reserved.

import UIKit

class PatternOverview: UIView {

    let patternOnColour : UIColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
    let patternOffColour: UIColor = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)

    var pattern : Int = 0
    let patterns: Int = Int(PATTERNS)
    
    var shapes = [CAShapeLayer]()
    var patternIndicator = CAShapeLayer()

    private let scalar = CGFloat(0.55)
    lazy private var rows = CGFloat(patterns / 4)
    lazy private var cols = CGFloat(patterns / Int(rows))
    lazy private var radius = min(0.5 * bounds.height / rows, 0.5 * bounds.width / cols)

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        shapes.reserveCapacity(patterns)

        patternIndicator.lineWidth = 2.0
        patternIndicator.path = highlight(pattern: 0).cgPath
        patternIndicator.strokeColor = UIColor.white.cgColor
        self.layer.addSublayer(patternIndicator)
        
        for r in stride(from: 0, to: rows, by: 1) {
            for c in stride(from: 0, to: cols, by: 1) {
                let path = UIBezierPath()
                let layer = CAShapeLayer()
                
                let x = c * (2 * radius) + radius
                let y = r * (2 * radius) + radius
                path.addArc(withCentre: CGPoint(x: x, y: y), radius: radius * scalar)

                layer.path = path.cgPath
                layer.fillColor = patternOffColour.cgColor
                self.layer.addSublayer(layer)
                shapes.append(CAShapeLayer())
            }
        }

        shapes.first!.fillColor = patternOnColour.cgColor
    }

    private func highlight(pattern: Int) -> UIBezierPath {
        let square = UIBezierPath()
        let x = CGFloat(Int(pattern % Int(cols))) * (2 * radius) + radius
        let y = CGFloat(Int(pattern / Int(cols))) * (2 * radius) + radius
        square.addSquare(withCentre: CGPoint(x: x, y: y), length: 2 * radius * 0.85)
        
        return square
    }
    
    override func draw(_ rect: CGRect) {}
    override func draw(_ layer: CALayer, in ctx: CGContext) {
        
        let currentPattern = Assemble.core.currentPattern

        if pattern != currentPattern {
            pattern = currentPattern
            patternIndicator.path = highlight(pattern: currentPattern).cgPath
        }
        
    }
    
}

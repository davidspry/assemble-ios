//
//  SequencerDrawing.swift
//  SimpleSynthesiser
//
//  Created by David Spry on 2/4/20.
//  Copyright © 2020 David Spry. All rights reserved.
//

import UIKit

extension Sequencer
{
    override func draw(_ rect: CGRect)
    {
        backgroundColor = .gray
        
        var paths = [UIBezierPath](repeating: UIBezierPath(), count: 4);
        
        for y in 1...Int(patterns[currentPattern].shape.height)
        {
            for x in 1...Int(patterns[currentPattern].shape.width)
            {
                let r: CGFloat = (y - 1) % 4 == 0 ? 4 : 2
                let c: CGPoint = .init(x: CGFloat(x) * gridSpacing.width, y: CGFloat(y) * gridSpacing.height)
                paths[0].move(to: c);
                paths[0].addArc(withCenter: c, radius: r, startAngle: 0, endAngle: 360, clockwise: true);
            }
        }
        
        UIColor.white.setFill();
        paths[0].close()
        paths[0].fill()
        
        
        UIColor.systemPink.setFill();
        paths[1].move(to: .init(x: 250, y: 250))
        paths[1].addArc(withCenter: .init(x: 250, y: 250), radius: 10, startAngle: 0, endAngle: 360, clockwise: true);
        paths[1].fill();
        
//        paths[0].apply(.init(translationX: -250, y: 0))
//        
//        paths[0].fill();
        
        
    }
}

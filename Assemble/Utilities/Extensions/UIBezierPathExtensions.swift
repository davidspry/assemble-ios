//  Assemble
//  Created by David Spry on 25/4/20.
//  Copyright © 2020 David Spry. All rights reserved.

import UIKit

extension  UIBezierPath {
    
    /// Generate a circle with the given radius at the given centre point.
    /// - Parameter centre: The centre point of the desired circle
    /// - Parameter radius: The radius of the desired circle

    convenience init(arcCentre centre: CGPoint, radius: CGFloat) {
        self.init(arcCenter: centre, radius: radius, startAngle: 0, endAngle: 360, clockwise: true);
    }
    
    /// Create a row of dots, as in a dot grid, at the top of the given frame.
    /// - Parameter frame:  The frame in which to draw the row.
    /// - Parameter dots:   The number of dots to draw.
    /// - Parameter radius: The radius of each dot.

    static func createDotRow(within frame: CGRect, dots: CGFloat, radius: CGFloat) -> UIBezierPath {
        let path = UIBezierPath()
        let spacing = min(frame.width, frame.height) / dots
        let margin  = 0.5 * spacing
        
        for x in stride(from: 0, to: dots, by: 1) {
            let xy = CGPoint(x: margin + x * spacing, y: margin)
            path.move(to: xy)
            path.addArc(withCentre: xy, radius: radius)
        }

        return path
    }

    /// Create a dot grid with the given number of rows and columns, and the given spacing, within the given frame.
    /// - Parameter frame: The frame in which to draw the grid.
    /// - Parameter rows: The number of rows to draw.
    /// - Parameter cols: The number of columns to draw.

    static func createDotGrid(within frame: CGRect, rows: CGFloat, cols: CGFloat) -> UIBezierPath {
        let path = UIBezierPath()
        let spacing = min(frame.width, frame.height) / min(rows, cols)
        let margin = 0.5 * spacing

        for y in stride(from: 0, to: rows, by: 1) {
            let shouldEmphasise = y.remainder(dividingBy: 4) == 0
            for x in stride(from: 0, to: cols, by: 1) {
                let radius: CGFloat = shouldEmphasise ? 4 : 2
                let xy = CGPoint(x: margin + x * spacing, y: margin + y * spacing)
                path.move(to: xy)
                path.addArc(withCentre: xy, radius: radius)
            }
        }

        return path
    }
    
    /// Add a circle with the given radius at the given centre point to the path.
    /// - Parameter centre: The centre point of the desired circle
    /// - Parameter radius: The radius of the desired circle

    func addArc(withCentre centre: CGPoint, radius: CGFloat) {
        move(to: CGPoint(x: centre.x + radius, y: centre.y))
        addArc(withCenter: centre, radius: radius, startAngle: 0, endAngle: 360, clockwise: true);
    }
    
    /// Add a square with the given centre point and given length to the path.
    /// - Parameter centre: The centre point of the desired square
    /// - Parameter length: The length of the desired square's sides

    func addSquare(withCentre centre: CGPoint, length: CGFloat) {
        var origin = CGPoint()
        origin.x = centre.x - length * 0.5
        origin.y = centre.y - length * 0.5
        
        move(to: origin)
        
        origin.x = origin.x + length
        addLine(to: origin)
        
        origin.y = origin.y + length
        addLine(to: origin)
        
        origin.x = origin.x - length
        addLine(to: origin)

        close()
    }
    
}

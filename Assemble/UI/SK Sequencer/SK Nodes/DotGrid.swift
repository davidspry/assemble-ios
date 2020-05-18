//  Assemble
//  =================================================
//  Created by David Spry on 31/3/20.
//  Copyright © 2020 David Spry. All rights reserved.
//  =================================================
//  Attribution:
//  This class was derived from a post by "0x141E":
//  <https://stackoverflow.com/a/33471755/9611538>

import UIKit
import SpriteKit

class DotGrid : SKSpriteNode
{
    var spacing      : CGSize!
    var currentShape : CGSize!

    func initialise(spacing: CGSize)
    {
        self.spacing = spacing
        self.currentShape = Assemble.shape

        guard let grid = DotGrid.drawDotGrid(shape: currentShape, spacing: spacing)
        else { return; }

        self.texture = grid;
        self.color = SKColor.clear;
        self.size = grid.size();
    }
    
    func redrawIfNeeded()
    {
        let shape = Assemble.shape
        if  shape != currentShape {
            self.texture = DotGrid.drawDotGrid(shape: shape, spacing: spacing);
            currentShape = shape
            print("[DotGrid] Redrawing")
        }
    }
    
    class func drawDotGrid(shape: CGSize, spacing: CGSize) -> SKTexture?
    {
        var contextSize = CGSize();
        contextSize.width = (shape.width + 1.0) * spacing.width;
        contextSize.height = (shape.height + 1.0) * spacing.height;
        UIGraphicsBeginImageContext(contextSize);

        guard let ctx = UIGraphicsGetCurrentContext() else { return nil; }
        ctx.setAllowsAntialiasing(true);
        ctx.setShouldAntialias(true);

        let n = Int(shape.width)
        let m = Int(shape.height)
        let grid: CGPath = drawGrid(rows: m, columns: n, spacing: spacing)
        ctx.addPath(grid);

        return SKTexture(image: UIGraphicsGetImageFromCurrentImageContext()!);
    }
    
    internal class func drawGrid(rows: Int, columns: Int, spacing: CGSize) -> CGPath
    {
        var path = UIBezierPath();
        SKColor.white.setFill();

        for y in 1...rows {
            drawRow(on: &path, at: CGFloat(y), columns: columns, spacing: spacing);
        }
        
        path.lineWidth = 2.0
        path.fill();
        
        return path.cgPath
    }
    
    internal class func drawRow(on path: inout UIBezierPath, at y: CGFloat, columns: Int, spacing: CGSize)
    {
        let t: CGFloat = CGFloat(Assemble.core.getParameter(kSequencerTicks))
        let r: CGFloat = (y - 1).remainder(dividingBy: t) == 0 ? 3 : 2;
        for x in 1...columns
        {
            let centre = CGPoint(x: CGFloat(x) * spacing.width, y: y * spacing.height);
            path.move(to: centre.applying(CGAffineTransform(translationX: r, y: 0.0)));
            path.addArc(withCenter: centre, radius: r, startAngle: 0, endAngle: 360, clockwise: true);
        }
    }
}

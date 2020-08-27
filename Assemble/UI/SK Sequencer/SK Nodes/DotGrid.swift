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

/// An `SKSpriteNode` illustrating a dot grid that visualises the shape of the underlying sequencer.
/// The grid is drawn once and drawn to the screen as a static texture, but it can be redrawn when its properties should change.

class DotGrid : SKSpriteNode
{
    /// The size of each cell on the grid
    
    private var spacing: CGSize!
    
    /// The shape, (rows, columns), of the dot grid

    private var currentShape: CGSize!

    /// Initialise the dot grid.
    /// - Parameter spacing: The size of each cell on the grid.

    public func initialise(spacing: CGSize)
    {
        self.spacing = spacing
        self.currentShape = Assemble.shape

        self.colorBlendFactor = 1.0
        self.color = UIColor.init(named: "Foreground")!
        
        guard let grid = DotGrid.drawDotGrid(shape: currentShape, spacing: spacing)
        else { return; }

        self.texture = grid;
        self.size  = grid.size();
    }
    
    /// Redraw the dot grid if the shape of the sequencer has changed.
    
    public func redrawIfNeeded() {
        let shape = Assemble.shape
        if  shape != currentShape {
            redraw()
        }
    }

    /// Redraw the dot grid.
    /// This method should called when changes are made to the shape of the underlying sequencer or the user interface style.

    public func redraw() {
        print("[DotGrid] Redrawing")
        let color  = UIColor.init(named: "Foreground")!
        let action = SKAction.colorize(with: color, colorBlendFactor: 1.0, duration: 0.5)
        run(action)
    }
    
    class func drawDotGrid(shape: CGSize, spacing: CGSize) -> SKTexture?
    {
        var contextSize = CGSize();
        contextSize.width = (shape.width + 1.0) * spacing.width;
        contextSize.height = (shape.height + 1.0) * spacing.height;
        UIGraphicsBeginImageContextWithOptions(contextSize, false, 0.0)

        guard let ctx = UIGraphicsGetCurrentContext() else { return nil; }
        ctx.interpolationQuality = .high
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
        UIColor.white.setFill()

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
        let r: CGFloat = (y - 1).remainder(dividingBy: t) == 0 ? 4 : 2;
        for x in 1...columns
        {
            let centre = CGPoint(x: CGFloat(x) * spacing.width, y: y * spacing.height);
            path.move(to: centre.applying(CGAffineTransform(translationX: r, y: 0.0)));
            path.addArc(withCenter: centre, radius: r, startAngle: 0, endAngle: 360, clockwise: true);
        }
    }
}

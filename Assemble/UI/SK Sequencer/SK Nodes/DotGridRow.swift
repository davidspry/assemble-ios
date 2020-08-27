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

/// An `SKSpriteNode` that represents the current position of the sequencer.
/// A `DotGridRow` should be bolder than any row on the `DotGrid`.

class DotGridRow: SKSpriteNode
{
    private var spacing: CGSize!

    /// Initialise the row.
    /// - Parameter spacing: The size of each cell on the grid
    
    public func initialise(spacing: CGSize) {
        self.spacing = spacing

        self.colorBlendFactor = 1.0
        self.color = UIColor.init(named: "Foreground")!
        
        guard let grid = DotGridRow.drawDotGridRow(spacing: spacing)
        else { return }

        self.texture = grid;
        self.size    = grid.size();
    }
    
    /// Redraw the row.
    /// This should be called when a change is made to the user interface style.

    public func redraw() {
        print("[DotGridRow] Redrawing")
        let color  = UIColor.init(named: "Foreground")!
        let action = SKAction.colorize(with: color, colorBlendFactor: 1.0, duration: 0.5)
        run(action)
    }

    class func drawDotGridRow(spacing: CGSize) -> SKTexture?
    {
        let shape = Assemble.shape

        var contextSize = CGSize();
        contextSize.width = (shape.width + 1.0) * spacing.width;
        contextSize.height = (shape.height + 1.0) * spacing.height;
        UIGraphicsBeginImageContextWithOptions(contextSize, false, 0.0)

        guard let ctx = UIGraphicsGetCurrentContext() else { return nil }
        ctx.interpolationQuality = .high
        ctx.setAllowsAntialiasing(true);
        ctx.setShouldAntialias(true);

        let columns = Int(shape.width);
        let row = drawRow(columns: columns, spacing: spacing);
        ctx.addPath(row);

        return SKTexture(image: UIGraphicsGetImageFromCurrentImageContext()!);
    }
    
    internal class func drawRow(columns: Int, spacing: CGSize) -> CGPath
    {
        let path = UIBezierPath()
        let r: CGFloat = 4
        
        for x in 1...columns
        {
            let dot = CGPoint(x: CGFloat(x) * spacing.width, y: spacing.height)
            path.move(to: dot)
            path.addArc(withCenter: dot, radius: r, startAngle: 0, endAngle: 360, clockwise: true)
        }

        UIColor.init(named: "Foreground")?.setFill()
        path.lineWidth = 2.0
        path.fill();

        return path.cgPath
    }

    func moveTo(row: Int)
    {
        position.y = -1.0 * CGFloat(row) * spacing.height
    }

}

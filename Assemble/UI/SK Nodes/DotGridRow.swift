//  Assemble
//  Created by David Spry on 31/3/20.
//  Copyright © 2020 David Spry. All rights reserved.
//
//  Attribution:
//  This class was derived from a post by "0x141E":
//  <https://stackoverflow.com/a/33471755/9611538>

import UIKit
import SpriteKit

class DotGridRow : SKSpriteNode
{
    var spacing   : CGSize!

    func initialise(spacing: CGSize) {
        self.spacing = spacing

        guard let grid = DotGridRow.drawDotGridRow(spacing: spacing)
        else { return }
        
        self.texture = grid;
        self.color = SKColor.clear;
        self.size = grid.size();
    }

    class func drawDotGridRow(spacing: CGSize) -> SKTexture?
    {
        let shape = Assemble.shape

        var contextSize = CGSize();
        contextSize.width = (shape.width + 1.0) * spacing.width;
        contextSize.height = (shape.height + 1.0) * spacing.height;
        UIGraphicsBeginImageContext(contextSize);

        guard let ctx = UIGraphicsGetCurrentContext() else { return nil }
        ctx.setShouldAntialias(true);
        ctx.setAllowsAntialiasing(true);

        let columns = Int(shape.width);
        let row = drawRow(columns: columns, spacing: spacing);
        ctx.addPath(row);

        return SKTexture(image: UIGraphicsGetImageFromCurrentImageContext()!);
    }
    
    internal class func drawRow(columns: Int, spacing: CGSize) -> CGPath
    {
        let path = UIBezierPath();
        let r: CGFloat = 5;
        
        for x in 1...columns
        {
            let dot = CGPoint(x: CGFloat(x) * spacing.width, y: spacing.height);
            path.move(to: dot)
            path.addArc(withCenter: dot, radius: r, startAngle: 0, endAngle: 360, clockwise: true);
        }

        SKColor.white.setFill();
        path.lineWidth = 2.0
        path.fill();

        return path.cgPath
    }

    func moveTo(row: Int)
    {
        position.y = -1.0 * CGFloat(row) * spacing.height
    }

}

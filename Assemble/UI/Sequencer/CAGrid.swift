//  Assemble
//  Created by David Spry on 24/8/20.
//  Copyright © 2020 David Spry. All rights reserved.

import UIKit

class CAGrid: UIView {

    internal var spacing   = CGFloat(0.0)
    internal let rowLayer  = CAShapeLayer()
    internal let gridLayer = CAShapeLayer()
    internal let cursorLayer = CAShapeLayer()
    internal var layersAreAttached = false

    public var selected: CGPoint = .zero {
        didSet {
            let position = pointFromIndices(selected)
            cursorLayer.position.x = position.x - 11
            cursorLayer.position.y = position.y - 11
        }
    }
    
    public var row: Int = 0 {
        didSet {
            let position = CGFloat(row) * spacing
            if  position != rowLayer.position.y {
                rowLayer.performWithoutActions {
                    self.rowLayer.position.y = max(0, position)
                }
            }
        }
    }
    
    // MARK: - Initialisation
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        initialise(frame: frame)
    }
    
    internal func initialise(frame: CGRect) {
        let rows = Assemble.patternHeight
        let cols = Assemble.patternWidth
        let size = min(frame.height, frame.width) / min(rows, cols)
        let grid = UIBezierPath.createDotGrid(within: frame, rows: rows, cols: cols)
        let cell = UIBezierPath(rect: CGRect(origin: .zero, size: CGSize.square(22)))
        let row  = UIBezierPath.createDotRow(within: frame, dots: cols, radius: 5)

        initialise(layer: rowLayer,    with: row,  fill: true)
        initialise(layer: gridLayer,   with: grid, fill: true)
        initialise(layer: cursorLayer, with: cell, fill: false)
        cursorLayer.speed = 5.0

        spacing  = size
        selected = CGPoint.zero
    }

    internal func initialise(layer: CAShapeLayer, with path: UIBezierPath, fill: Bool) {
        layer.path = path.cgPath
        layer.shouldRasterize        = true
        layer.allowsEdgeAntialiasing = true
        layer.rasterizationScale     = 2.0 * UIScreen.main.scale

        let clear = UIColor.clear.cgColor
        let color = UIColor.init(named: "Foreground")?.cgColor

        layer.lineCap     = .round
        layer.lineJoin    = .round
        layer.lineWidth   = fill ? 0.0 : 2.0
        layer.strokeColor = fill ? clear : color
        layer.fillColor   = fill ? color : clear
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        print("[CAGrid] Redrawing")
    }
    
    internal func add(note: CAShapeLayer) {
        layer.addSublayer(note)
    }
    
    // MARK: - Drawing
    
    /// Redraw the grid in the case where the dimensions or layer properties should change.

    internal func redrawIfNeeded() {
        return
    }
    
    override func draw(_ rect: CGRect) {}
    override func draw(_ layer: CALayer, in ctx: CGContext) {
        if !layersAreAttached {
            layersAreAttached = true
            layer.addSublayer(gridLayer)
            layer.addSublayer(rowLayer)
            layer.addSublayer(cursorLayer)
        }
    }
    
    // MARK: - Touch Control
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let location = touches.first?.location(in: self) else { return }
        selected = indicesFromPoint(x: location.x, y: location.y)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let location = touches.first?.location(in: self) else { return }
        selected = indicesFromPoint(x: location.x, y: location.y)
    }
    
    // MARK: - Coordinate Space Conversion

    /// Return a point in UIView space from a coordinate, (x, y).
    /// This function assumes the standard top-left orientation:
    /// ~~~
    /// (0,0)  (0,1)
    /// (1,0)  (1,1)
    /// ~~~
    /// - Parameter xy: A point containing column and row indices

    internal func pointFromIndices(_ xy: CGPoint) -> CGPoint {
        let x = xy.x * spacing + spacing * 0.5
        let y = xy.y * spacing + spacing * 0.5

        return CGPoint(x: x, y: y)
    }

    /// Given a point in UIView space, return the matching grid coordinate.
    /// - Parameter x: The x-coordinate of the point in UIView space
    /// - Parameter y: The y-coordinate of the point in UIView space
    
    internal func indicesFromPoint(x: CGFloat, y: CGFloat) -> CGPoint {
        let shape = Assemble.shape
        let xPadding = 0.5 * (frame.width  - shape.width  * spacing);
        let yPadding = 0.5 * (frame.height - shape.height * spacing);
        let x = max(0, min(Int((xPadding + x) / spacing), Int(shape.width)  - 1));
        let y = max(0, min(Int((yPadding + y) / spacing), Int(shape.height) - 1));
        
        return .init(x: x, y: y)
    }
    
    /// Compute the grid coordinate of the given gesture's location in UIView space.
    /// - Parameter gesture: The gesture whose location should be translated to a grid coordinate.

    internal func indicesFromGesture(_ gesture: UIGestureRecognizer) -> CGPoint {
        let location = gesture.location(in: self)

        return indicesFromPoint(x: location.x, y: location.y)
    }

}

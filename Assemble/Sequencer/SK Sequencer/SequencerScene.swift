//  Assemble
//  ============================
//  Created by David Spry on 3/4/20.
//  Copyright © 2020 David Spry. All rights reserved.

import UIKit
import SpriteKit

class SequencerScene : SKScene, UIGestureRecognizerDelegate
{
    var noteToErase   : CGPoint?
    let tapRecogniser = UITapGestureRecognizer()
    var eraseButtonView = UIView()

    let grid   = DotGrid()
    let row    = DotGridRow()
    let cursor = CellSelectShape(size: 20)
    var noteShapes = [[NoteShapeNode]]()
    var pattern: Int = 0
    
    var noteString: String?
    var noteStrings = [[[String?]]]()
    
    var spacing: CGSize = .zero
    var selected: CGPoint = .zero

    override init(size: CGSize)
    {
        super.init(size: size);
        
        tapRecogniser.delegate = self
        tapRecogniser.numberOfTapsRequired = 2
        tapRecogniser.cancelsTouchesInView = false

        spacing.width  = size.width  / Assemble.patternWidth
        spacing.height = size.height / Assemble.patternHeight
        
        backgroundColor = .clear;
        anchorPoint = CGPoint(x: 0.5, y: 0.5);
        scaleMode = .aspectFit;

        row.initialise(spacing: spacing)
        grid.initialise(spacing: spacing)

        DispatchQueue.main.async(execute: {
            let patterns = Int(PATTERNS)
            let width = Int(SEQUENCER_WIDTH)
            let length = Assemble.core.length
            let nilArray: [String?] = Array.init(repeating: nil, count: width)
            self.cursor.position = self.pointFromIndices(self.selected)
            self.noteShapes.reserveCapacity(patterns)
            self.noteStrings.reserveCapacity(patterns)
            self.noteShapes.append(contentsOf: Array.init(repeating: [], count: patterns))
            self.noteStrings.append(contentsOf: Array.init(repeating: [], count: patterns))
            for k in 0 ..< patterns {
                self.noteStrings[k].append(contentsOf: Array.init(repeating: nilArray,
                                                                  count: length))
            }
        })

        addChild(grid);
        addChild(row);
        addChild(cursor);
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
    }

    override func didMove(to view: SKView) {
        view.addGestureRecognizer(self.tapRecogniser)
        tapRecogniser.addTarget(self, action: #selector(SequencerScene.doubleTapped(_:)))
        
        let frame = CGRect(x: 0, y: 0, width: 35, height: 35)
        let button = UIButton(frame: frame)
        button.setImage(UIImage(systemName: "bin.xmark"), for: .normal)
        button.layer.cornerRadius = button.frame.height / 2
        button.adjustsImageWhenHighlighted = true
        button.layer.cornerCurve = .continuous
        button.backgroundColor = .white
        button.tintColor = .black
        button.addTarget(self, action: #selector(binPressed), for: .touchDown)

        eraseButtonView.backgroundColor = .clear
        eraseButtonView.frame = frame
        eraseButtonView.addSubview(button)
        eraseButtonView.isHidden = true
        view.addSubview(eraseButtonView)
    }
    
    // MARK: - Computer Keyboard
    
    func didNavigate(by direction: Int)
    {
        let w: CGFloat = Assemble.patternWidth
        let h: CGFloat = CGFloat(Assemble.core.length)

        if direction == 0 { selected.y -= 1 }
        if direction == 1 { selected.y += 1 }
        if direction == 2 { selected.x -= 1 }
        if direction == 3 { selected.x += 1 }

        if selected.y >= h { selected.y = selected.y - h }
        if selected.y <  0 { selected.y = selected.y + h }
        if selected.x >= w { selected.x = selected.x - w }
        if selected.x <  0 { selected.x = selected.x + w }

        noteString = noteStrings[Assemble.core.currentPattern][selected.ny][selected.nx]
        cursor.position = pointFromIndices(selected)
    }
    
    // MARK: - Erase Note View

    func showEraseNoteView() {
        DispatchQueue.main.async {
            self.eraseButtonView.isHidden = false
            self.eraseButtonView.layer.setAffineTransform(.init(scaleX: 0.1, y: 0.1))
            UIView.animate(withDuration: 0.1) {
                self.eraseButtonView.layer.setAffineTransform(.init(scaleX: 1.0, y: 1.0))
            }
        }
    }
    
    func hideEraseNoteView() {
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.1) {
                self.eraseButtonView.layer.setAffineTransform(.init(scaleX: 0.1, y: 0.1))
                self.eraseButtonView.isHidden = true
            }
        }
    }
    
    // MARK: - User Interaction

    func addOrModifyNote(xy: CGPoint, note: Int, oscillator: OscillatorShape) {
        let p = Assemble.core.currentPattern
        let existingNote: String? = noteStrings[p][selected.ny][selected.nx]
        noteStrings[p][selected.ny][selected.nx] = Note.describe(note, oscillator: oscillator)
        noteString = noteStrings[p][selected.ny][selected.nx]

        guard existingNote == nil else {
            modifyNote(xy: xy, oscillator: oscillator)
            return
        }

        let node = NoteShapeNode(type: oscillator)!;
        node.position = pointFromIndices(xy);
        node.name = xy.debugDescription
        noteShapes[p].append(node)
        addChild(node);
    }

    internal func modifyNote(xy: CGPoint, oscillator: OscillatorShape) {
        DispatchQueue.main.async {
            self.noteShapes[Assemble.core.currentPattern].forEach { node in
                if node.name == xy.debugDescription { node.recolour(type: oscillator) }
            }
        }
    }

    func eraseNote() {
        let xy = selected
        let p = Assemble.core.currentPattern
        DispatchQueue.main.async {
            self.noteShapes[p].forEach { node in
                if node.name == xy.debugDescription {
                    node.removeFromParent()
                    self.noteStrings[p][xy.ny][xy.nx] = nil
                    self.noteString = nil
                }
            }
        }
    }

    func patternDidChange(to pattern: Int) {
        guard pattern != self.pattern else { return }
        grid.redrawIfNeeded()
        noteString = noteStrings[Assemble.core.currentPattern][selected.ny][selected.nx]
        DispatchQueue.main.async {
            self.noteShapes[self.pattern].forEach { node in
                node.isHidden = true
            }
            
            self.noteShapes[pattern].forEach { node in
                node.isHidden = false
            }
            
            self.pattern = pattern
        }
    }

    // MARK: - Coordinate Space Conversion
    
    internal func pointFromIndices(_ xy: CGPoint) -> CGPoint
    {
        let x = (xy.x + 1) * spacing.width - spacing.width * 0.5;
        let y = (xy.y + 1) * spacing.height - spacing.height * 0.5;

        return convertPoint(fromView: .init(x: x, y: y));
    }
    
    internal func pointFromIndices(x: Int, y: Int) -> CGPoint
    {
        let x = CGFloat(x + 1) * spacing.width - spacing.width * 0.5;
        let y = CGFloat(y + 1) * spacing.height - spacing.height * 0.5;

        return convertPoint(fromView: .init(x: x, y: y));
    }
    
    internal func viewPointFromIndices(_ xy: CGPoint) -> CGPoint
    {
        let x = CGFloat(xy.x + 1) * spacing.width - spacing.width * 0.5;
        let y = CGFloat(xy.y + 1) * spacing.height - spacing.height * 0.5;

        return .init(x: x, y: y);
    }
    
    internal func indicesFromPoint(x: CGFloat, y: CGFloat) -> CGPoint
    {
        let shape = Assemble.shape
        let xPadding = 0.5 * (size.width  - shape.width  * spacing.width);
        let yPadding = 0.5 * (size.height - shape.height * spacing.height);
        let x = max(0, min(Int((xPadding + x) / spacing.width), Int(shape.width) - 1));
        let y = max(0, min(Int((yPadding + y) / spacing.height), Int(shape.height) - 1));
        
        return .init(x: x, y: y)
    }

}

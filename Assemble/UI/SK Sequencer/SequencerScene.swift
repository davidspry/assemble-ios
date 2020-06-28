//  Assemble
//  ============================
//  Created by David Spry on 3/4/20.
//  Copyright © 2020 David Spry. All rights reserved.

import UIKit
import SpriteKit

/// The on-screen sequencer, which reflects Assemble's core sequencer

class SequencerScene : SKScene, UIGestureRecognizerDelegate
{
    /// The sequencer's dot grid
    
    let grid = DotGrid()
    
    /// The sequencer's current position
    
    let row  = DotGridRow()
    
    /// The user's cursor
    
    let cursor = CellSelectShape(size: 20)
    
    /// Nodes representing notes on each pattern of the current sequence

    internal var noteShapes = [[NoteShapeNode]]()
    
    /// The index of the `SequencerScene`'s current pattern

    internal var pattern: Int = 0
    
    /// A string describing the note underlying the user's cursor

    var noteString: String?

    /// Strings describing each note of the sequence

    internal var noteStrings = [[[String?]]]()
    
    /// The cell-to-cell grid spacing of the sequencer

    internal var spacing: CGSize = .zero

    /// The location of the currently selected sequencer position

    internal var selected: CGPoint = .zero
    
    /// The location of the note that the user has elected to erase

    internal var noteToErase: CGPoint?
    
    /// A button used by the user to erase notes from the sequencer
    
    internal var eraseButtonView = UIView()
    
    /// The gesture used to move and display the `eraseButtonView`

    internal let longPressRecogniser = UILongPressGestureRecognizer()

    override init(size: CGSize) {
        super.init(size: size);
        
        longPressRecogniser.delegate = self
        longPressRecogniser.minimumPressDuration = 0.8
        longPressRecogniser.numberOfTouchesRequired = 1
        longPressRecogniser.cancelsTouchesInView = false

        spacing.width  = size.width  / Assemble.patternWidth
        spacing.height = size.height / Assemble.patternHeight
        
        backgroundColor = UIColor.init(named: "Background")!
        anchorPoint = CGPoint(x: 0.5, y: 0.5);
        scaleMode = .aspectFit;

        row.initialise(spacing: spacing)
        grid.initialise(spacing: spacing)

        DispatchQueue.main.async(execute: {
            let patterns = Int(PATTERNS)
            let W = Int(SEQUENCER_WIDTH)
            let H = Assemble.core.length
            let empty: [String?] = Array.init(repeating: nil, count: W)
            self.cursor.position = self.pointFromIndices(self.selected)
            self.noteShapes.reserveCapacity(patterns)
            self.noteStrings.reserveCapacity(patterns)
            self.noteShapes.append(contentsOf: Array.init(repeating: [], count: patterns))
            self.noteStrings.append(contentsOf: Array.init(repeating: [], count: patterns))
            for k in 0 ..< patterns {
                self.noteStrings[k].append(contentsOf: Array.init(repeating: empty, count: H))
            }
        })

        addChild(grid);
        addChild(row);
        addChild(cursor);
        
        /// Register to receive notifications when the user elects to clear a pattern's contents

        let selector = #selector(clearCurrentPattern(_:))
        NotificationCenter.default.addObserver(self, selector: selector, name: .clearCurrentPattern, object: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        print("[SequencerScene] Required init is unimplemented.")
    }

    /// Initialise the long press gesture recogniser and the note erase button when the `SequencerScene` attaches to the `Sequencer` `SKView`.

    override func didMove(to view: SKView) {
        view.addGestureRecognizer(self.longPressRecogniser)
        longPressRecogniser.addTarget(self, action: #selector(SequencerScene.longPressed(_:)))
        
        let w: CGFloat = 30
        let h: CGFloat = 25
        let size = UIImage.SymbolConfiguration(pointSize: w)
        let frame = CGRect(x: 0, y: 0, width: w, height: h)
        let button = UIButton(frame: frame)
            button.frame = frame
            button.tintColor = .white
            button.addTarget(self, action: #selector(binPressed), for: .touchDown)
            button.setImage(UIImage(systemName: "xmark.rectangle.fill", withConfiguration: size), for: .normal)

        eraseButtonView.frame = frame
        eraseButtonView.addSubview(button)
        eraseButtonView.isHidden = true
        view.addSubview(eraseButtonView)
    }

    /// Redraw the sequencer scene's background colour.
    /// This function should be called when changes are made to the user interface style.

    public func redraw() {
        backgroundColor = UIColor.init(named: "Background")!
    }

    /// Reset the sequencer scene by removing every note node and setting every note description to nil.

    private func reset()
    {
        self.noteShapes = self.noteShapes.map { pattern in
            pattern.forEach { $0.removeFromParent() }
            return []
        }

        self.noteString = nil
        self.noteStrings = self.noteStrings.map { pattern in pattern.map { row in row.map { _ in nil } } }
    }
    
    /// Update the current note description to reflect the selected sequencer position

    private func updateNoteString()
    {
        guard pattern < noteStrings.count,
              selected.ny < noteStrings[pattern].count,
              selected.nx < noteStrings[pattern][selected.ny].count
              else { noteString = nil; return }
        noteString = noteStrings[pattern][selected.ny][selected.nx]
    }

    // MARK: - Computer Keyboard
    
    /// Move the user's cursor in the specified direction on the sequencer
    /// - Parameter direction: The direction, an integer in [0, 3], in which the cursor should move.

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

    /// Display the erase button above the selected note
    
    func showEraseNoteView() {
        DispatchQueue.main.async {
            self.eraseButtonView.isHidden = false
            self.eraseButtonView.layer.setAffineTransform(.init(scaleX: 0.1, y: 0.1))
            UIView.animate(withDuration: 0.1) {
                self.eraseButtonView.layer.setAffineTransform(.init(scaleX: 1.0, y: 1.0))
            }
        }
    }
    
    /// Hide the erase button from view
    
    func hideEraseNoteView() {
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.1) {
                self.eraseButtonView.layer.setAffineTransform(.init(scaleX: 0.1, y: 0.1))
                self.eraseButtonView.isHidden = true
            }
        }
    }
    
    // MARK: - User Interaction

    /// Add a new note to the sequencer or modify an existing note with new properties.
    /// - Parameter xy: The location in grid coordinates of the new note
    /// - Parameter note: The note number of the new note
    /// - Parameter oscillator: The oscillator to be used for the new note
    /// - Parameter pattern: The pattern that the note should belong to. By default, the current pattern will be used.
    
    func addOrModifyNote(xy: CGPoint, note: Int, oscillator: OscillatorShape, pattern: Int? = nil) {
        let pattern = pattern ?? Assemble.core.currentPattern
        let existingNote: String? = noteStrings[pattern][xy.ny][xy.nx]
        noteStrings[pattern][xy.ny][xy.nx] = NoteUtilities.describe(note, oscillator: oscillator)
        noteString = noteStrings[pattern][xy.ny][xy.nx]

        guard existingNote == nil else {
            modifyNote(xy: xy, oscillator: oscillator)
            return
        }

        let node = NoteShapeNode(type: oscillator)!;
        node.isHidden = pattern != self.pattern
        node.position = pointFromIndices(xy);
        node.name = xy.debugDescription
        noteShapes[pattern].append(node)
        addChild(node);
    }

    /// Modify the oscillator of an existing note, located at the given position.
    /// - Parameter xy: The location of the note to be modified
    /// - Parameter oscillator: The desired oscillator

    internal func modifyNote(xy: CGPoint, oscillator: OscillatorShape) {
        DispatchQueue.main.async {
            self.noteShapes[Assemble.core.currentPattern].forEach { node in
                if node.name == xy.debugDescription { node.recolour(type: oscillator) }
            }
        }
    }

    /// Remove and destroy every `NoteShapeNode` who is situated at the location `xy`.
    /// - Parameter xy: The location of the note to be erased in grid coordinates.

    func eraseNote(_ xy: CGPoint) {
        let p = Assemble.core.currentPattern
        DispatchQueue.main.async {
            self.noteShapes[p].removeAll(where: { node in
                let matches = node.name == xy.debugDescription
                if  matches {
                    node.removeFromParent()
                    self.noteStrings[p][xy.ny][xy.nx] = nil
                    self.noteString = nil
                }
                return matches
            })
        }
    }
    
    /// Clear the sequencer scene's current pattern.
    ///
    /// Each `NoteShapeNode` is removed from the scene and destroyed,
    /// and each cell in the current pattern's `noteStrings` array is set to nil.
    /// This should be called at the same time as the current pattern of the core
    /// sequencer is reset.
    ///
    /// - Parameter notification: The `NSNotification` requesting that
    /// the current pattern should be cleared.

    @objc func clearCurrentPattern(_ notification: NSNotification) {
        let p = Assemble.core.currentPattern
        DispatchQueue.main.async {
            self.noteShapes[p].forEach { $0.removeFromParent() }
            self.noteShapes[p].removeAll()
        }

        DispatchQueue.main.async {
            self.noteString = nil
            for y in 0 ..< Int(Assemble.patternHeight) {
                for x in 0 ..< Int(Assemble.patternWidth) {
                    self.noteStrings[p][y][x] = nil
                }
            }
        }
    }
    
    /// Poll the Assemble core for its state and initialise the scene from its contents.
    ///
    /// - Note: Each state string begins with a character that denotes whether the underlying Pattern
    /// is active or not. This character should be dropped from the data before passing it to the NoteUtilities
    /// class for decoding.

    public func initialiseFromUnderlyingState() {
        guard let state = Assemble.core.commander?.collateCoreState() else { return }
        reset()

        for (key, data) in state {
            let data = (data as? String)?.dropFirst() ?? ""
            let pattern = Int(key.suffix(1))
            let notes: [NoteUtilities.Note?] = NoteUtilities.decode(from: data)
            
            for case let note? in notes {
                addOrModifyNote(xy: note.xy, note: note.note, oscillator: note.shape, pattern: pattern)
            }
        }

        updateNoteString()
    }

    /// Update the scene to reflect the next pattern, `pattern`.
    ///
    /// `SequencerScene` stores each `NoteShapeNode` for each pattern in order that they can be
    /// quickly shown or hidden. At any time, only the notes that belong to the pattern that's currently playing are visible.
    ///
    /// This method shows the new pattern and hides the previous pattern.
    ///
    /// - Complexity: O(nm), where `n` and `m` are the dimensions of a pattern.

    func patternDidChange(to pattern: Int) {
        guard pattern != self.pattern else { return }
        
        hideEraseNoteView()
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
    
    /// Return a point in scene space from a coordinate, (x, y).
    /// SceneKit maps (0, 0) to the screen centre, but this function assumes
    /// the standard top-left orientation:
    /// ~~~
    /// (0,0)  (0,1)
    /// (1,0)  (1,1)
    /// ~~~
    /// - Parameter xy: A point containing column and row indices

    internal func pointFromIndices(_ xy: CGPoint) -> CGPoint
    {
        let x = (xy.x + 1) * spacing.width - spacing.width * 0.5;
        let y = (xy.y + 1) * spacing.height - spacing.height * 0.5;

        return convertPoint(fromView: .init(x: x, y: y));
    }
    
    /// Convert a point from the scene (such as the location of a tap) to a point on the grid.
    /// - Parameter xy: A point in scene space
    
    internal func viewPointFromIndices(_ xy: CGPoint) -> CGPoint
    {
        let x = CGFloat(xy.x + 1) * spacing.width - spacing.width * 0.5;
        let y = CGFloat(xy.y + 1) * spacing.height - spacing.height * 0.5;

        return .init(x: x, y: y);
    }
    
    /// Given a point in scene space, return the matching grid coordinate.
    /// - Parameter x: The x-coordinate of the point in scene space
    /// - Parameter y: The y-coordinate of the point in scene space
    
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

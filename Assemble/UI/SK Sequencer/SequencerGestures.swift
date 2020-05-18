//  Assemble
//  ============================
//  Created by David Spry on 3/4/20.
//  Copyright © 2020 David Spry. All rights reserved.

import UIKit
import SpriteKit

extension SequencerScene
{
    
    /// Destroy the note at the selected point.
    ///
    /// After the user selects a note by double-tapping and presses the delete button that appears,
    /// the Note needs to be removed from the SequencerScene, where it is drawn, and the
    /// Matrix data structure in Assemble's core C++ context. This method performs initiates
    /// both of these tasks.
    ///
    /// - Parameter sender: The `UIButton` that was pressed
    
    @objc func binPressed(sender: UIButton) {
        guard let xy = noteToErase else { return }
        eraseNote(xy)
        hideEraseNoteView()
        Assemble.core.eraseNote(xy: xy)
    }
    
    /// Handle a long press on the Sequencer.
    ///
    /// The `UILongPressGestureRecogniser` is used to select notes for deletion. When a note is
    /// selected by long pressing, a button appears above the note to allow the user to delete the note.
    ///
    /// - Parameter gesture: The gesture recogniser used to detect the press

    @objc func longPressed(_ gesture: UILongPressGestureRecognizer)
    {
        if gesture.state != .began { return }
        selected = pointFromGesture(gesture)
        guard noteStrings[Assemble.core.currentPattern][selected.ny][selected.nx] != nil else {
            return
        }
        eraseButtonView.center = viewPointFromIndices(selected)
        eraseButtonView.center = eraseButtonView.center.applying(.init(translationX: 0, y: -45))
        noteToErase = selected
        
        showEraseNoteView()
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        selected = pointFromTouch(touch);
        cursor.position = pointFromIndices(selected)
        noteString = noteStrings[Assemble.core.currentPattern][selected.ny][selected.nx]
        hideEraseNoteView()
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        selected = pointFromTouch(touch);
        noteString = noteStrings[Assemble.core.currentPattern][selected.ny][selected.nx]
        let position = pointFromIndices(selected)
        let move = SKAction.move(to: position, duration: 0.05);
        cursor.run(move);
    }

    /// Compute the grid coordinate that matches the location of a `UITouch`

    internal func pointFromTouch(_ touch: UITouch) -> CGPoint {
        let location = convertPoint(toView: touch.location(in: self));

        return indicesFromPoint(x: location.x, y: location.y)
    }
    
    /// Compute the grid coordinate the matches the location of a `UILongPressGestureRecognizer` touch

    internal func pointFromGesture(_ gesture: UILongPressGestureRecognizer) -> CGPoint {
        let location = gesture.location(in: view);
        
        return indicesFromPoint(x: location.x, y: location.y)
    }
}

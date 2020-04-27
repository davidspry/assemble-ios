//  Assemble
//  ============================
//  Created by David Spry on 3/4/20.
//  Copyright © 2020 David Spry. All rights reserved.

import UIKit
import SpriteKit

extension SequencerScene
{
    /**
     Destroy the Note at the selected point.
     
     After the user selects a Note by double-tapping and presses the delete button that appears,
     the Note needs to be removed from the SequencerScene, where it is drawn, and the
     Matrix data structure in Assemble's core C++ context. This method performs initiates
     both of these tasks.
     */
    
    @objc func binPressed(sender: UIButton) {
        eraseNote()
        hideEraseNoteView()
        Assemble.core.eraseNote(xy: selected)
    }
    
    @objc func doubleTapped(_ gesture: UITapGestureRecognizer) {
        selected = pointFromGesture(gesture)
        guard noteStrings[selected.ny][selected.nx] != nil else { return }
        eraseButtonView.center = viewPointFromIndices(selected)
        eraseButtonView.center = eraseButtonView.center.applying(.init(translationX: 0, y: -45))
        showEraseNoteView()
        
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        selected = pointFromTouch(touch);
        cursor.position = pointFromIndices(selected)
        noteString = noteStrings[selected.ny][selected.nx]
        hideEraseNoteView()
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        selected = pointFromTouch(touch);
        noteString = noteStrings[selected.ny][selected.nx]
        let position = pointFromIndices(selected)
        let move = SKAction.move(to: position, duration: 0.05);
        cursor.run(move);
    }

    internal func pointFromTouch(_ touch: UITouch) -> CGPoint {
        let location = convertPoint(toView: touch.location(in: self));

        return indicesFromPoint(x: location.x, y: location.y)
    }
    
    internal func pointFromGesture(_ gesture: UITapGestureRecognizer) -> CGPoint {
        let location = gesture.location(in: view);
        
        return indicesFromPoint(x: location.x, y: location.y)
    }
}

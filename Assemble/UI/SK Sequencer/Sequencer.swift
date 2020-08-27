//  Assemble
//  ============================
//  Created by David Spry on 3/4/20.
//  Copyright © 2020 David Spry. All rights reserved.

import UIKit
import SpriteKit

/// A SpriteKit view/scene for visualising Assemble's underlying sequencer

class Sequencer : SKView, KeyboardListener
{
    /// The sequencer scene

    private(set) var skScene : SequencerScene!

    required init?(coder: NSCoder)
    {
        super.init(coder: coder)
        
        allowsTransparency = true
        backgroundColor = SKColor.clear
        determineSizeForDevice()

        if needsUpdateConstraints() {
            updateConstraints()
            layoutIfNeeded()
        }
        
        
        skScene = SequencerScene(size: bounds.size)
        presentScene(skScene)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    // MARK: - Keyboard Listener callbacks
    
    func pressNote(_ note: Int, shape: OscillatorShape) {
        skScene.addOrModifyNote(xy: skScene.selected, note: note, oscillator: shape)
        Assemble.core.addOrModifyNote(xy: skScene.selected, note: note, shape: shape)
    }
    
    func eraseNote() {
        skScene.eraseNote(skScene.selected)
        Assemble.core.eraseNote(xy: skScene.selected)
    }
    
    func setOctave(_ octave: Int) {
        guard let note = Assemble.core.note(at: skScene.selected) else { return }
        let pitch = NoteUtilities.modify(note: note.note, withOctave: octave)
        skScene.addOrModifyNote(xy: skScene.selected, note: pitch, oscillator: note.shape)
        Assemble.core.addOrModifyNote(xy: skScene.selected, note: pitch, shape: note.shape)
        Assemble.core.pressNote(pitch, shape: note.shape)
    }
    
    func setOscillator(_ next: Bool) {
        guard let note = Assemble.core.note(at: skScene.selected) else { return }
        let oscillator = next ? note.shape.next() : note.shape.previous()
        skScene.addOrModifyNote(xy: skScene.selected, note: note.note, oscillator: oscillator)
        Assemble.core.addOrModifyNote(xy: skScene.selected, note: note.note, shape: oscillator)
        Assemble.core.pressNote(note.note, shape: oscillator)
    }
    
    func didNavigate(by direction: Int) {
        skScene.didNavigate(by: direction)
    }
    
    // MARK: Keyboard Listener end -

    /// After loading state from a preset, the Sequencer
    /// needs to poll the Assemble core. This method should be called
    /// in order to synchronise the SK Sequencer scene with the underlying
    /// Sequencer.

    func initialiseFromUnderlyingState() {
        skScene.initialiseFromUnderlyingState()
    }
    
    /// Determine the appropriate size of the `SequencerScene` from the device's screen size.

    internal func determineSizeForDevice()
    {
        var scalar: CGFloat = 0.0
        let screenSize = UIScreen.main.bounds
        let screenLength = max(screenSize.height, screenSize.width)
        let landscapeHeight = min(screenSize.height, screenSize.width)
//        let scalar: CGFloat =

        switch Assemble.device {
        case .pad:
            scalar = floor(landscapeHeight / Assemble.patternHeight * 0.6)
            print(scalar)
//            if screenLength > 1300 { scalar = 37; break }
//            if screenLength > 1100 { scalar = 31; break }
//            if screenLength > 1000 { scalar = 28; break }
//            else                   { scalar = 28; break }
        case .phone:
            if screenLength > 850  { scalar = 30; break }
            if screenLength > 650  { scalar = 26; break }
            if screenLength > 550  { scalar = 22; break }
            else                   { scalar = 20; break }
        default: fatalError("[Sequencer] Unsupported device.")
        }

        let width  = Assemble.patternWidth  * scalar
        let height = Assemble.patternHeight * scalar
        self.widthAnchor .constraint(equalToConstant: width) .isActive = true;
        self.heightAnchor.constraint(equalToConstant: height).isActive = true;
        self.bounds.size = .init(width: width, height: height)
    }
    
    /// Include subviews who fall outside the bounds of the view in the hit test. In Assemble,
    /// this allows the delete icon to be pressed if it happens to appear outside the bounds of the
    /// `SKScene`.
    ///
    /// - Author: Noam
    /// - Note: Source: <https://stackoverflow.com/a/14875673/9611538>

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView?
    {
        guard !clipsToBounds && !isHidden && alpha > 0 else { return nil }

        for member in subviews.reversed() {
            let subPoint = member.convert(point, from: self)
            guard let result = member.hitTest(subPoint, with: event) else { continue }
            return result
        }

        return super.hitTest(point, with: event)
    }
    
    /// Redraw the scene's visual components to reflect a change in the user interface style

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        skScene.cursor.redraw()
        skScene.grid.redraw()
        skScene.row.redraw()
        skScene.redraw()
    }
}

//  Assemble
//  ============================
//  Created by David Spry on 3/4/20.
//  Copyright © 2020 David Spry. All rights reserved.

import UIKit
import SpriteKit

class Sequencer : SKView, KeyboardListener
{
    var SK : SequencerScene!

    required init?(coder: NSCoder)
    {
        super.init(coder: coder)
        
        determineSizeForDevice()
        
        if needsUpdateConstraints() {
            updateConstraints();
            layoutIfNeeded();
        }

        SK = SequencerScene(size: self.bounds.size)

        presentScene(SK);
    }
    
    // MARK: - Keyboard Listener
    
    func pressNote(_ note: Int, shape: OscillatorShape) {
        SK.addOrModifyNote(xy: SK.selected, note: note, oscillator: shape)
        Assemble.core.addOrModifyNote(xy: SK.selected, note: note, shape: shape)
    }
    
    func eraseNote() {
        SK.eraseNote()
        Assemble.core.eraseNote(xy: SK.selected)
    }
    
    func setOctave(_ octave: Int) {}
    
    func didNavigate(by direction: Int) {
        SK.didNavigate(by: direction)
    }

    /**
     Determine the size of the `SequencerScene` from the device's screen size.
     */
    internal func determineSizeForDevice()
    {
        var scalar: CGFloat = 0.0
        let screenSize = UIScreen.main.bounds
        let screenLength = max(screenSize.height, screenSize.width)

        switch Assemble.device {
        case .pad:
            if screenLength > 1300 { scalar = 34; break }
            if screenLength > 1100 { scalar = 32; break }
            if screenLength > 1000 { scalar = 30; break }
            else                   { scalar = 30; break }
        case .phone:
            if screenLength > 850  { scalar = 25; break }
            if screenLength > 650  { scalar = 24; break }
            if screenLength > 550  { scalar = 22; break }
            else                   { scalar = 20; break }
        default:        fatalError("Unsupported device!");
        }

        let width  = Assemble.patternWidth  * scalar
        let height = Assemble.patternHeight * scalar
        self.widthAnchor.constraint(equalToConstant: width).isActive = true;
        self.heightAnchor.constraint(equalToConstant: height).isActive = true;
        self.bounds.size = .init(width: width, height: height)
    }
    
    /**
     Include subviews who fall outside the bounds of the view in the hit test. In Assemble,
     this allows the delete icon to be pressed if it happens to appear outside the bounds of the
     `SKScene`.

     - Author: Noam
     - Note: Source: <https://stackoverflow.com/a/14875673/9611538>
     */
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
}

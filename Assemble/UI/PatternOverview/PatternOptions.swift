//  PatternOptions.swift
//  Assemble
//  Created by David Spry on 28/7/20.
//  Copyright © 2020 David Spry. All rights reserved.

import UIKit

/// A small panel of options intended to be displayed over a pattern in Assemble's `PatternOverview`.

class PatternOptions: UIView {

    private var componentsAreAttached = false
    
    private let buttonWidth = 30
    private let buttonMargin = 5
    
    private let copier = ColouredButton(title: "C", .offWhite, .lightBlack)
    private let paster = ColouredButton(title: "P", .offWhite, .lightBlack)
    private let eraser = ColouredButton(title: "X", .sineNoteColour, .offWhite)

    public weak var delegate: PatternOverview?

    public func initialise() {
        if componentsAreAttached { return }
        componentsAreAttached = true
        assignButtonsWithActions()
        styliseButtons()
        update()

        #if LIGHT
            let size = CGSize.square(buttonWidth)
        #else
            let size = CGSize(width: buttonWidth, height: 3 * buttonWidth + 2 * buttonMargin)
        #endif

        self.frame = CGRect(origin: .zero, size: size)
        self.setNeedsDisplay()
    }
    
    public func reset() {
        update()
    }
    
    private func assignButtonsWithActions() {
        copier.addTarget(self, action: #selector(didPressCopy(_:)),  for: .touchUpInside)
        paster.addTarget(self, action: #selector(didPressPaste(_:)), for: .touchUpInside)
        eraser.addTarget(self, action: #selector(didPressErase(_:)), for: .touchUpInside)
    }
    
    private func styliseButtons() {
        #if LIGHT
            let buttons = [eraser]
        #else
            let buttons = [copier, paster, eraser]
        #endif

        for (i, button) in buttons.enumerated() {
            let origin   = CGPoint(x: .zero, y: i * (buttonWidth + buttonMargin))
            button.frame = CGRect(origin: origin, size: .square(buttonWidth))
            addSubviewToFront(button)
        }
    }
    
    internal func update() {
        guard let commander = Assemble.core.commander else { return }
        let canCopy = commander.copiedPatternStateExists()
        
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.15) {
                self.paster.alpha = canCopy ? 1.0 : 0.30

                if #available(iOS 13.4, *) {
                    self.paster.isPointerInteractionEnabled = canCopy
                }
            }
        }
    }

    @objc internal func didPressCopy(_ sender: UIButton) {
        guard let delegate = delegate else {
            return print("[PatternOptions] Delegate is nil.")
        }
        
        delegate.initiateCopy()
        update()
    }
    
    @objc internal func didPressPaste(_ sender: UIButton) {
        guard let delegate = delegate,
              let commander = Assemble.core.commander else {
            return print("[PatternOptions] Delegate is nil.")
        }

        if commander.copiedPatternStateExists() {
            delegate.initiatePaste()
        }
    }
    
    @objc internal func didPressErase(_ sender: UIButton) {
        guard let delegate = delegate else {
            return print("[PatternOptions] Delegate is nil.")
        }
        
        delegate.didClearPattern(sender)
    }

}

//  PatternOptions.swift
//  Assemble
//  Created by David Spry on 28/7/20.
//  Copyright © 2020 David Spry. All rights reserved.

import UIKit

/// A small panel of options intended to be displayed over a pattern in Assemble's `PatternOverview`.

class PatternOptions: UIView {

    private var componentsAreAttached = false
    
    private let buttonWidth = 30
    
    private let copier = UIButton(type: .system)

    private let paster = UIButton(type: .system)
    
    private let eraser = UIButton(type: .system)
    
    private var patternForCopying: Int?
    
    private var patternForPasting: Int?

//    private let repeatParameter = ParameterLabel()
    
    public weak var delegate: PatternOverview?

    public func initialise(in frame: CGRect) {
        if componentsAreAttached { return }
        componentsAreAttached = true
        assignButtonsWithActions()
        updatePasteButton()
        styliseButtons()

        self.setNeedsDisplay()
        self.frame = frame
    }
    
    public func reset() {
        updatePasteButton()
    }
    
    private func assignButtonsWithActions() {
        copier.addTarget(self, action: #selector(didPressCopy(_:)),  for: .touchUpInside)
        paster.addTarget(self, action: #selector(didPressPaste(_:)), for: .touchUpInside)
        eraser.addTarget(self, action: #selector(didPressErase(_:)), for: .touchUpInside)
    }
    
    private func styliseButtons() {
        let font  = UIFont(name: "JetBrainsMono-Medium", size: 13)
        let trait = UITraitCollection(userInterfaceStyle: .light)
        let light = UIColor.systemGray6.resolvedColor(with: trait)
        let dark  = UIColor.init(named: "Secondary")?.resolvedColor(with: trait)
        let buttons = [(copier, "C", light, dark),
                       (paster, "P", light, dark),
                       (eraser, "X", UIColor.sineNoteColour, light)]

        for (i, (button, title, backgroundColour, textColour)) in buttons.enumerated()
        {
            button.frame = CGRect(x: i * (buttonWidth + 5), y: 0, width: buttonWidth, height: buttonWidth)
            button.layer.cornerCurve  = .continuous
            button.layer.cornerRadius = 10

            button.titleLabel?.font = font
            button.setTitle(title, for: .normal)
            button.backgroundColor = backgroundColour
            button.setTitleColor(textColour, for: .normal)
            button.titleLabel?.textAlignment = .left

            addSubview(button)
            bringSubviewToFront(button)
        }
    }
    
    internal func updatePasteButton() {
        let canCopy = Assemble.core.commander?.copiedPatternStateExists()
        paster.alpha = (canCopy ?? false) ? 1.0 : 0.35
        
        if #available(iOS 13.4, *) {
            paster.isPointerInteractionEnabled = canCopy ?? false
        }
    }

    @objc internal func didPressCopy(_ sender: UIButton) {
        guard let delegate = delegate else {
            return print("[PatternOptions] Delegate is nil.")
        }
        
        delegate.initiateCopy()
        updatePasteButton()
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

//  PatternOptions.swift
//  Assemble
//  Created by David Spry on 28/7/20.
//  Copyright © 2020 David Spry. All rights reserved.

import UIKit

/// A small panel of options intended to be displayed over a pattern in Assemble's `PatternOverview`.

class PatternOptions: UIView {

    private var drawLayerIsAttached = false

    private var componentsAreAttached = false
    
    private var drawLayer = CAShapeLayer()
    
    private let buttonWidth = 30
    
    private let copier = UIButton()

    private let paster = UIButton()
    
    private let eraser = UIButton()
    
    private var patternForCopying: Int?
    
    private var patternForPasting: Int?

//    private let repeatParameter = ParameterLabel()
    
    public weak var delegate: PatternOverview?

    public func initialise(in frame: CGRect) {
        if componentsAreAttached { return }
        componentsAreAttached = true
        initialiseButtons()
        paster.alpha = 0.35
        self.setNeedsDisplay()
        self.frame = frame
    }
    
    private func initialiseButtons() {
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
            
            button.titleLabel?.font = font
            button.setTitle(title, for: .normal)
            button.backgroundColor = backgroundColour
            button.setTitleColor(textColour, for: .normal)
            button.titleLabel?.textAlignment = .left
            
            button.layer.cornerCurve  = .continuous
            button.layer.cornerRadius = 10

            addSubview(button)
            bringSubviewToFront(button)
        }
    }

    @objc internal func didPressCopy() {
//        patternForCopying
    }
    
    @objc internal func didPressPaste() {
//        patternForCopying -> patternForPasting
    }

}

//  TransportViews.swift
//  Assemble
//  Created by David Spry on 12/4/20.
//  Copyright © 2020 David Spry. All rights reserved.

import UIKit

extension Transport {

    func initialisePlayButton() {
        play.backgroundColor = UIColor.init(white: 0.1, alpha: 1)
        play.translatesAutoresizingMaskIntoConstraints = false
        play.addTarget(self, action: #selector(didPressPlay), for: .touchUpInside)
        play.layer.cornerCurve = .continuous
        play.layer.cornerRadius = 15
        play.setImage(UIImage(systemName: "play"), for: .normal)
        play.tintColor = .triangleNoteColour
        addSubview(play)
        
        NSLayoutConstraint.activate([
            play.widthAnchor.constraint(equalToConstant: 55),
            play.heightAnchor.constraint(equalTo: heightAnchor),
            play.topAnchor.constraint(equalTo: topAnchor),
            play.bottomAnchor.constraint(equalTo: bottomAnchor),
            play.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
        
        play.layoutIfNeeded()
    }
    
    func initialiseSegmentedControl() {
        oscillators = UISegmentedControl(items: ["SIN", "TRI", "SQR", "SAW"])
        oscillators.backgroundColor = .clear
        oscillators.selectedSegmentTintColor = .clear
        oscillators.translatesAutoresizingMaskIntoConstraints = false
        oscillators.addTarget(self, action: #selector(didChangeOscillator), for: .valueChanged)
        
        selected.translatesAutoresizingMaskIntoConstraints = false
        selected.backgroundColor = .sineNoteColour
        selected.layer.cornerCurve = .continuous
        selected.layer.cornerRadius = 10
        
        addSubview(selected)
        addSubview(oscillators)

        NSLayoutConstraint.activate([
            oscillators.widthAnchor.constraint(equalTo: widthAnchor, constant: -play.bounds.width),
            oscillators.heightAnchor.constraint(equalTo: heightAnchor),
            oscillators.topAnchor.constraint(equalTo: topAnchor),
            oscillators.bottomAnchor.constraint(equalTo: bottomAnchor),
            oscillators.leadingAnchor.constraint(equalTo: leadingAnchor),
            oscillators.trailingAnchor.constraint(equalTo: play.leadingAnchor)
        ])
        
        oscillators.selectedSegmentIndex = 0
        oscillators.setTitleTextAttributes([NSAttributedString.Key.foregroundColor : UIColor.lightText], for: .normal)
        oscillators.setTitleTextAttributes([NSAttributedString.Key.foregroundColor : UIColor.white], for: .selected)
        oscillators.setTitleTextAttributes([NSAttributedString.Key.foregroundColor : UIColor.lightText], for: .highlighted)
        oscillators.layoutIfNeeded()

        let width = oscillators.bounds.width / CGFloat(oscillators.numberOfSegments) * 0.8
        selectedX = selected.centerXAnchor.constraint(equalTo: oscillators.leadingAnchor)
        
        NSLayoutConstraint.activate([
            selectedX,
            selected.widthAnchor.constraint(equalToConstant: width),
            selected.centerYAnchor.constraint(equalTo: centerYAnchor),
            selected.heightAnchor.constraint(equalTo: oscillators.heightAnchor, multiplier: 0.8),
        ])
        
        selected.layoutIfNeeded()
        oscillators.sendActions(for: .valueChanged)
    }
    
}

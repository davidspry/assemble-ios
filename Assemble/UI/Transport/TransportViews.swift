//  TransportViews.swift
//  Assemble
//  Created by David Spry on 12/4/20.
//  Copyright © 2020 David Spry. All rights reserved.

import UIKit

extension Transport {

    func initialisePlayButton() {
        play.backgroundColor = UIColor.init(white: 0.15, alpha: 1)
        play.translatesAutoresizingMaskIntoConstraints = false
        play.addTarget(self, action: #selector(didPressPlay), for: .touchUpInside)
        play.setImage(UIImage(systemName: "play"), for: .normal)
        play.layer.cornerCurve = .continuous
        play.layer.cornerRadius = 15
        play.tintColor = .white
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
        oscillators.addTarget(self, action: #selector(didSelectOscillator), for: .valueChanged)
        
        let clearImage = UIImage(color: .clear, size: .init(width: 1, height: 32))
        oscillators.setBackgroundImage(clearImage, for: .normal, barMetrics: .default)
        oscillators.setDividerImage(clearImage)

        selected.translatesAutoresizingMaskIntoConstraints = false
        selected.backgroundColor = .sineNoteColour
        selected.layer.cornerCurve = .continuous
        selected.layer.cornerRadius = 15

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
        let font = UIFont.init(name: "JetBrainsMono-Regular", size: 14)
        oscillators.setTitleTextAttributes([.foregroundColor : UIColor.lightText], for: .normal)
        oscillators.setTitleTextAttributes([.foregroundColor : UIColor.white], for: .selected)
        oscillators.setTitleTextAttributes([.foregroundColor : UIColor.lightText], for: .highlighted)
        oscillators.setTitleTextAttributes([.font : font as Any], for: .normal)
        oscillators.layoutIfNeeded()

        let width = oscillators.bounds.width / CGFloat(oscillators.numberOfSegments) * 0.8
        selectedX = selected.centerXAnchor.constraint(equalTo: oscillators.leadingAnchor)
        
        NSLayoutConstraint.activate([
            selectedX,
            selected.widthAnchor.constraint(equalToConstant: 55),
            selected.centerYAnchor.constraint(equalTo: centerYAnchor),
            selected.heightAnchor.constraint(equalTo: heightAnchor),
            selected.topAnchor.constraint(equalTo: topAnchor),
            selected.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        
        selected.layoutIfNeeded()
        oscillators.sendActions(for: .valueChanged)
    }
    
}

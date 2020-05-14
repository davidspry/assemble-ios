//  Assemble
//  Created by David Spry on 12/4/20.
//  Copyright © 2020 David Spry. All rights reserved.

import UIKit

extension Transport {

    func initialisePlayButton() {
        play.backgroundColor = .clear
        play.translatesAutoresizingMaskIntoConstraints = false
        play.addTarget(self, action: #selector(didPressPlay), for: .touchUpInside)
        play.setImage(Icons.play, for: .normal)
        play.layer.cornerCurve = .continuous
        play.layer.cornerRadius = 15
        play.tintColor = .label
        addSubview(play)
        
        NSLayoutConstraint.activate([
            play.widthAnchor.constraint(equalToConstant: buttonWidth),
            play.heightAnchor.constraint(equalTo: heightAnchor),
            play.topAnchor.constraint(equalTo: topAnchor),
            play.bottomAnchor.constraint(equalTo: bottomAnchor),
            play.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
        
        play.layoutIfNeeded()
    }
    
    func initialiseKeyboardButton() {
        keyboard.backgroundColor = .clear
        keyboard.translatesAutoresizingMaskIntoConstraints = false
        keyboard.addTarget(self, action: #selector(didToggleKeyboard), for: .touchUpInside)
        keyboard.setImage(Icons.hide, for: .normal)
        keyboard.layer.cornerCurve = .continuous
        keyboard.layer.cornerRadius = 15
        keyboard.tintColor = .label
        addSubview(keyboard)
        
        NSLayoutConstraint.activate([
            keyboard.widthAnchor.constraint(equalToConstant: buttonWidth),
            keyboard.heightAnchor.constraint(equalTo: heightAnchor),
            keyboard.topAnchor.constraint(equalTo: topAnchor),
            keyboard.bottomAnchor.constraint(equalTo: bottomAnchor),
            keyboard.trailingAnchor.constraint(equalTo: oscillators.leadingAnchor,
                                               constant: -buttonMargin)
        ])
        
        keyboard.layoutIfNeeded()
    }
    
    func initialiseModeButton() {
        mode.backgroundColor = .clear
        mode.translatesAutoresizingMaskIntoConstraints = false
        mode.addTarget(self, action: #selector(didPressModeButton), for: .touchUpInside)
        mode.setImage(modeState ? Icons.song : Icons.pattern, for: .normal)
        mode.layer.cornerCurve = .continuous
        mode.layer.cornerRadius = 15
        mode.tintColor = .label
        addSubview(mode)
        
        NSLayoutConstraint.activate([
            mode.widthAnchor.constraint(equalToConstant: buttonWidth),
            mode.heightAnchor.constraint(equalTo: heightAnchor),
            mode.topAnchor.constraint(equalTo: topAnchor),
            mode.bottomAnchor.constraint(equalTo: bottomAnchor),
            mode.trailingAnchor.constraint(equalTo: keyboard.leadingAnchor)
        ])
        
        mode.layoutIfNeeded()
    }
    
    func initialiseSegmentedControl() {
        oscillators = OscillatorSelector(itemWidth: buttonWidth)
        oscillators.addTarget(self, action: #selector(didSelectOscillator), for: .valueChanged)
        addSubview(oscillators)

        let complement: CGFloat = -(buttonWidth * 3 + buttonMargin * 2)

        NSLayoutConstraint.activate([
            oscillators.widthAnchor.constraint(equalTo: widthAnchor, constant: complement),
            oscillators.heightAnchor.constraint(equalTo: heightAnchor),
            oscillators.topAnchor.constraint(equalTo: topAnchor),
            oscillators.bottomAnchor.constraint(equalTo: bottomAnchor),
            oscillators.trailingAnchor.constraint(equalTo: play.leadingAnchor, constant: -buttonMargin)
        ])
        
        oscillators.selectedSegmentIndex = 0
        let font = UIFont.init(name: "JetBrainsMono-Regular", size: 14)
        oscillators.setTitleTextAttributes([.foregroundColor : UIColor.lightText], for: .normal)
        oscillators.setTitleTextAttributes([.foregroundColor : UIColor.white], for: .selected)
        oscillators.setTitleTextAttributes([.foregroundColor : UIColor.lightText], for: .highlighted)
        oscillators.setTitleTextAttributes([.font : font as Any], for: .normal)
        oscillators.layoutIfNeeded()

        oscillators.sendActions(for: .valueChanged)
    }
    
}

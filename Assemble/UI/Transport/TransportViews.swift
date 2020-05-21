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
        play.tintColor = UIColor.init(named: "Foreground") ?? .label
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
        keyboard.tintColor = UIColor.init(named: "Foreground") ?? .label
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
    
    func initialiseSegmentedControl() {
        oscillators = OscillatorSelector(itemWidth: buttonWidth)
        oscillators.addTarget(self, action: #selector(didSelectOscillator), for: .valueChanged)
        addSubview(oscillators)

        let complement: CGFloat = -(buttonWidth * 2 + buttonMargin * 2)

        NSLayoutConstraint.activate([
            oscillators.widthAnchor.constraint(equalTo: widthAnchor, constant: complement),
            oscillators.heightAnchor.constraint(equalTo: heightAnchor),
            oscillators.topAnchor.constraint(equalTo: topAnchor),
            oscillators.bottomAnchor.constraint(equalTo: bottomAnchor),
            oscillators.trailingAnchor.constraint(equalTo: play.leadingAnchor, constant: -buttonMargin)
        ])
        
        oscillators.selectedSegmentIndex = 0
        oscillators.sendActions(for: .valueChanged)
    }
    
}

//  Assemble
//  Created by David Spry on 12/4/20.
//  Copyright © 2020 David Spry. All rights reserved.

import UIKit

fileprivate struct Icons {
    static let play  = UIImage(systemName: "play")
    static let pause = UIImage(systemName: "pause")
}

class Transport : UIView, KeyboardListener, KeyboardSettingsListener {

    let play = UIButton()
    let selected = UIView()
    var selectedX: NSLayoutConstraint!
    var oscillators: UISegmentedControl!
    let listeners = MulticastDelegate<KeyboardSettingsListener>()
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        translatesAutoresizingMaskIntoConstraints = false
        initialisePlayButton()
        initialiseSegmentedControl()
    }

    @objc func didPressPlay(sender: UIButton)
    {
        let playing = Assemble.core.playOrPause()
        let image = playing ? Icons.pause : Icons.play
        
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.15, delay: 0.0, options: .curveEaseInOut, animations: {
                self.play.imageView?.layer.setAffineTransform(.init(scaleX: 0.85, y: 0.85))
            }) { success in
                self.play.setImage(image, for: .normal)
                UIView.animate(withDuration: 0.1, animations: {
                    self.play.imageView?.layer.setAffineTransform(.init(scaleX: 1, y: 1))
                })
            }
        }
    }
    
    @objc func didSelectOscillator(sender: UISegmentedControl)
    {
        let index = oscillators.selectedSegmentIndex
        let oscillator = OscillatorShape(rawValue: index) ?? .sine
        let color = UIColor.from(oscillator)
        let width = oscillators.bounds.width / CGFloat(oscillators.numberOfSegments)
        listeners.invoke({$0.didChangeOscillator(to: oscillator)})

        DispatchQueue.main.async
        {
            UIView.animate(withDuration: 0.075, delay: .zero, options: [.curveEaseOut], animations: {
                self.selectedX.constant = CGFloat(index) * width + width * 0.5
                self.selected.backgroundColor = color
                self.layoutIfNeeded()
            }, completion: nil)
        }
    }
    
    // MARK: - Keyboard Listener

    func pressPlayOrPause() {
        didPressPlay(sender: play)
    }
    
    // MARK: - Keyboard Settings Listener

    func didChangeOscillator(to oscillator: OscillatorShape) {
        oscillators.selectedSegmentIndex = oscillator.rawValue
        oscillators.sendActions(for: .valueChanged)
    }
}

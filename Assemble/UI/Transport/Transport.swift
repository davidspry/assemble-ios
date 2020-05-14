//  Assemble
//  Created by David Spry on 12/4/20.
//  Copyright © 2020 David Spry. All rights reserved.

import UIKit

public struct Icons {
    static let play  = UIImage(systemName: "play.fill", withConfiguration: size)
    static let pause = UIImage(systemName: "pause", withConfiguration: size)
    static let show  = UIImage(systemName: "circle.fill", withConfiguration: size)
    static let hide  = UIImage(systemName: "circle", withConfiguration: size)
    static let song  = UIImage(systemName: "s.circle.fill", withConfiguration: size)
    static let pattern = UIImage(systemName: "p.circle.fill", withConfiguration: size)
    private static let size = UIImage.SymbolConfiguration.init(pointSize: 20, weight: .semibold)
}

class Transport : UIView, TransportListener, KeyboardSettingsListener {

    let play = UIButton()
    let mode = UIButton()
    let keyboard = UIButton()
    var oscillators: OscillatorSelector!
    
    let buttonWidth: CGFloat = 55
    let buttonMargin: CGFloat = 25

    var modeState: Bool = false
    var keyboardState: Bool = false

    let listeners = MulticastDelegate<KeyboardSettingsListener>()
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        translatesAutoresizingMaskIntoConstraints = false
        modeState = Int(Assemble.core.getParameter(kSequencerMode)) == 1
        initialisePlayButton()
        initialiseSegmentedControl()
        initialiseKeyboardButton()
        initialiseModeButton()
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
    
    @objc func didToggleKeyboard(sender: UIButton)
    {
        keyboardState = !keyboardState
        let image = keyboardState ? Icons.show : Icons.hide
        listeners.invoke({ $0.didToggleKeyboardDisplay(keyboardState) })

        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.15, delay: 0.0, options: .curveEaseInOut, animations: {
                self.keyboard.imageView?.layer.setAffineTransform(.init(scaleX: 0.85, y: 0.85))
            }) { success in
                self.keyboard.setImage(image, for: .normal)
                UIView.animate(withDuration: 0.1, animations: {
                    self.keyboard.imageView?.layer.setAffineTransform(.init(scaleX: 1, y: 1))
                })
            }
        }
    }
    
    @objc func didPressModeButton(sender: UIButton) {
        Assemble.core.didToggleMode()
        modeState = Int(Assemble.core.getParameter(kSequencerMode)) == 1
        let image = modeState ? Icons.song : Icons.pattern

        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.15, delay: 0.0, options: .curveEaseInOut, animations: {
                self.mode.imageView?.layer.setAffineTransform(.init(scaleX: 0.85, y: 0.85))
            }) { success in
                self.mode.setImage(image, for: .normal)
                UIView.animate(withDuration: 0.1, animations: {
                    self.mode.imageView?.layer.setAffineTransform(.init(scaleX: 1, y: 1))
                })
            }
        }
    }
    
    @objc func didSelectOscillator(sender: UISegmentedControl)
    {
        let index = oscillators.selectedSegmentIndex
        let oscillator = OscillatorShape(rawValue: index) ?? .sine
        listeners.invoke({$0.didChangeOscillator(to: oscillator)})
    }
    
    // MARK: - Transport Listener

    func pressPlayOrPause() {
        didPressPlay(sender: play)
    }
    
    func didToggleMode() {
        didPressModeButton(sender: mode)
    }
    
    // MARK: - Keyboard Settings Listener

    func didChangeOscillator(to oscillator: OscillatorShape) {
        oscillators.selectedSegmentIndex = oscillator.rawValue
        oscillators.sendActions(for: .valueChanged)
    }

}

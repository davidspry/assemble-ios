//  Assemble
//  Created by David Spry on 26/7/20.
//  Copyright © 2020 David Spry. All rights reserved.

import UIKit

/// The transport bar, which contains the oscillator selector, the play-pause control, recording controls, and a toggle for the on-screen keyboard.

class TransportiOS : UIView, TransportListener, KeyboardSettingsListener {

    internal let play = UIButton()
    
    internal let keyboard = UIButton()
    
    lazy internal var oscillators = OscillatorSelector(itemWidth: buttonWidth)
    
    /// The width of each button on the transport bar
    
    internal let buttonWidth: CGFloat = 50
    
    /// The space between each button on the transport bar

    internal let buttonMargin: CGFloat = 8
    
    /// The visibility state of the keyboard. This should be `false` initially.

    internal var keyboardState: Bool = false

    /// The transport's listeners, who are notified when an oscillator is selected and when the keyboard's visibility is toggled.'
    
    let listeners = MulticastDelegate<KeyboardSettingsListener>()
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        translatesAutoresizingMaskIntoConstraints = false
        initialisePlayButton()
        initialiseSegmentedControl()
        initialiseKeyboardButton()
    }

    /// Respond to presses on the play-pause button by updating its visual state and broadcasting the play-pause notification.
    /// - Parameter sender: A reference to the play-pause button.

    @objc internal func didPressPlay(sender: UIButton)
    {
        let playing = Assemble.core.playOrPause()
        let image = playing ? Icons.pause : Icons.play
        NotificationCenter.default.post(name: .playOrPause, object: nil)
        
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
    
    /// Respond to presses on the keyboard button by updating the visual state of the keyboard button and notifying the transport's listeners.
    /// - Parameter sender: A reference to the keyboard button.

    @objc internal func didToggleKeyboard(sender: UIButton)
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

    /// Respond to selections detected by the `OscillatorSelector` by notifying the transport's listeners.
    /// - Parameter sender: A reference to the `OscillatorSelector`.

    @objc internal func didSelectOscillator(sender: UISegmentedControl)
    {
        let index = oscillators.selectedSegmentIndex
        let oscillator = OscillatorShape(rawValue: index) ?? .sine
        listeners.invoke({$0.didChangeOscillator(to: oscillator)})
    }
    
    // MARK: - Transport Listener

    func pressPlayOrPause() {
        didPressPlay(sender: play)
    }
    
    // MARK: - Keyboard Settings Listener

    func didChangeOscillator(to oscillator: OscillatorShape) {
        oscillators.selectedSegmentIndex = oscillator.rawValue
        oscillators.sendActions(for: .valueChanged)
    }

}

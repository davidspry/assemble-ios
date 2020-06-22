//  Assemble
//  Created by David Spry on 12/4/20.
//  Copyright © 2020 David Spry. All rights reserved.

import UIKit

struct Icons {
    static let play   = UIImage(systemName: "play.fill", withConfiguration: size)
    static let pause  = UIImage(systemName: "pause", withConfiguration: size)
    static let show   = UIImage(systemName: "circle.fill", withConfiguration: size)
    static let hide   = UIImage(systemName: "circle", withConfiguration: size)
    static let record = UIImage(systemName: "circle.fill", withConfiguration: size)
    static let bypass = UIImage(systemName: "circle", withConfiguration: size)
    static let saving = UIImage(systemName: "slowmo", withConfiguration: size)
    private static let size = UIImage.SymbolConfiguration.init(pointSize: 25, weight: .semibold)
}

class Transport : UIView, TransportListener, KeyboardSettingsListener {

    let play = UIButton()
    let record = UIButton()
    let keyboard = UIButton()
    var recording: Bool = false
    var oscillators: OscillatorSelector!
    
    let buttonWidth: CGFloat = 55
    let buttonMargin: CGFloat = 25
    var keyboardState: Bool = false

    let listeners = MulticastDelegate<KeyboardSettingsListener>()
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        translatesAutoresizingMaskIntoConstraints = false
        initialiseRecordButton()
        initialisePlayButton()
        initialiseSegmentedControl()
        initialiseKeyboardButton()
        
        /// Register to be notified when a media recording session begins

        let selector = #selector(didBeginRecording(_:))
        let notification = NSNotification.Name.beginRecording
        NotificationCenter.default.addObserver(self, selector: selector, name: notification, object: nil)
    }

    @objc func didPressPlay(sender: UIButton)
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
    
    /// Begin a new media recording session or end an existing media recording session
    ///
    /// - Parameter sender: A reference to the record button

    @objc func didPressRecord(sender: UIButton)
    {
        if !recording {
            NotificationCenter.default.post(name: .defineRecording, object: nil)
        }

        else {
            recording = false
            DispatchQueue.main.async {
                self.record.pulsateEnd()
                self.record.setImage(Icons.bypass, for: .normal)
                NotificationCenter.default.post(name: .stopRecording, object: nil)
            }
        }
    }
    
    /// Respond to a newly initiated media recording session by setting the visual state of the record button
    ///
    /// - Parameter notification: The `NSNotification` who triggered the callback

    @objc private func didBeginRecording(_ notification: NSNotification) {
        recording = true
        NotificationCenter.default.post(name: .beginRecording, object: nil)
        DispatchQueue.main.async {
            self.record.pulsate()
            self.record.setImage(Icons.record, for: .normal)
        }
    }

    /// Set the usable state of the record button.
    ///
    /// The record button should be disabled during the video encoding stage.
    /// - Parameter state: The desired state of the record button. `true` if the button should be active; `false` otherwise.

    public func setRecordButtonUsable(_ usable: Bool) {
        let image = usable ? Icons.bypass : Icons.saving

        DispatchQueue.main.async {
            self.record.isUserInteractionEnabled = usable
            if  usable { self.record.rotateClockwiseEnd() }
            if !usable { self.record.rotateClockwise() }
            
            UIView.animate(withDuration: 0.25) {
                self.record.alpha = usable ? 1.0 : 0.50
                self.record.setImage(image, for: .normal)
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
    
    // MARK: - Keyboard Settings Listener

    func didChangeOscillator(to oscillator: OscillatorShape) {
        oscillators.selectedSegmentIndex = oscillator.rawValue
        oscillators.sendActions(for: .valueChanged)
    }

}

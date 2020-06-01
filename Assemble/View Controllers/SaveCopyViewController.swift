//  Assemble
//  Created by David Spry on 26/5/20.
//  Copyright © 2020 David Spry. All rights reserved.

import UIKit

class SaveCopyViewController: UIViewController, UITextFieldDelegate {

    weak var delegate: MainViewController?

    var panelPosition: CGFloat!
    @IBOutlet weak var windowPanel: UIView!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var copyButton: UIButton!
    @IBOutlet weak var songName: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()

        songName.delegate = self
        songName.text = Assemble.core.commander?.currentPreset?.name
        panelPosition = windowPanel.frame.origin.y
        
        let notifyShow = UIResponder.keyboardWillShowNotification
        let notifyHide = UIResponder.keyboardWillHideNotification
        let callbackShow = #selector(keyboardWillShow(notification:))
        let callbackHide = #selector(keyboardWillHide(notification:))
        let callbackText = #selector(textFieldDidChange(_:))
        songName.addTarget(self, action: callbackText, for: .editingChanged)
        
        NotificationCenter.default.addObserver(self, selector: callbackShow, name: notifyShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: callbackHide, name: notifyHide, object: nil)
        
        verifyTextField()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        guard let touch = touches.first else { return }
        let location = touch.location(in: windowPanel)
        let shouldDismiss = !(windowPanel.point(inside: location, with: nil))
        if  shouldDismiss {
            dismiss(animated: true, completion: nil)
        }
    }

    /// Adjust the position of the view to accommodate the software keyboard when it appears.
    /// - Author: 'Boris' on StackOverflow: <https://stackoverflow.com/a/31124676/9611538>

    @objc func keyboardWillShow(notification: NSNotification) {
        DispatchQueue.main.async {
            guard let keyboard = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue,
                self.view.frame.origin.y == 0

            else { return }
            
            UIView.animate(withDuration: 0.5) {
                self.view.frame.origin.y -= keyboard.height / 2.0
            }
        }
    }

    /// Restore the original position of the view after the software keyboard has been dismissed from view.
    /// - Author: 'Boris' on StackOverflow: <https://stackoverflow.com/a/31124676/9611538>

    @objc func keyboardWillHide(notification: NSNotification) {
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.5) {
                self.view.frame.origin.y = 0
            }
        }
    }
    
    private func verifyTextField() {
        guard let text = songName.text else { return }
        let empty = (text.filter { !$0.isWhitespace }).isEmpty

        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.5) {
                self.saveButton.alpha = empty ? 0.25 : 1.0
                self.copyButton.alpha = empty ? 0.25 : 1.0
                self.saveButton.isEnabled = !empty
                self.copyButton.isEnabled = !empty
            }
        }
    }

    /// Save the current preset with the given name

    @IBAction func didPressSave(_ sender: Any) {
        guard let name = songName.text
        else { return print("[SaveCopyViewController] Song name is nil") }
        delegate?.saveState(named: name)
        dismiss(animated: true, completion: nil)
    }
    
    /// Copy the current state to a new preset with the given name

    @IBAction func didPressCopy(_ sender: Any) {
        guard let name = songName.text
        else { return print("[SaveCopyViewController] Song name is nil") }
        delegate?.copyState(named: name)
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func didPressClose(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - UITextField Delegate
    
    @objc func textFieldDidChange(_ field: UITextField) {
        verifyTextField()
    }
}

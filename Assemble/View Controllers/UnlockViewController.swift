//  Assemble
//  Created by David Spry on 14/7/20.
//  Copyright © 2020 David Spry. All rights reserved.

import UIKit
import StoreKit

class UnlockViewController: UIViewController {
    
    weak var delegate: MainViewController?
    
    @IBOutlet weak var alertPanel: UIView!
    @IBOutlet weak var windowPanel: UIView!
    @IBOutlet weak var restoreButton: UIButton!
    @IBOutlet weak var purchaseButton: UIButton!
    @IBOutlet weak var errorLabel: UILabel!
    
    private lazy var labelTranslateZero = CGAffineTransform(translationX: 0, y: 0)
    private lazy var labelTranslateHide = CGAffineTransform(translationX: 0, y: alertPanel.bounds.height)

    override func viewDidLoad() {
        super.viewDidLoad()
        alertPanel.isHidden = true
        alertPanel.layer.setAffineTransform(labelTranslateHide)

        if !IAPVerifier.shared.isAuthorisedForPayment {
            purchaseButton.disable(duration: 0.25, alpha: 0.35)
        }

        IAPVerifier.shared.requestProducts { yield, error, price in
            DispatchQueue.main.async {
                if yield == true, let price = price {
                    self.purchaseButton.setTitle("PURCHASE: \(price)", for: .normal)
                }
            }
        }
    }
    
    internal func displayAlert(message: String, colour: UIColor) {
        if message.isEmpty { return }
        DispatchQueue.main.async {
            self.alertPanel.isHidden = false
            self.alertPanel.backgroundColor = colour
            UIView.animate(withDuration: 0.25) {
                self.errorLabel.text = message
                self.alertPanel.layer.setAffineTransform(self.labelTranslateZero)
            }
        }
    }
    
    internal func hideAlert() {
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.1, animations: {
                self.alertPanel.layer.setAffineTransform(self.labelTranslateHide)
            }) { complete in self.alertPanel.isHidden = true }
        }
    }
    
    internal func productWasPurchasedOrRestored() {
        DispatchQueue.main.async {
            self.delegate?.userDidPurchaseIAP()
            self.dismiss(animated: true, completion: {
                SKStoreReviewController.requestReview()
            })
        }
    }
    
    @IBAction func didPressPurchase(_ sender: UIButton) {
        self.restoreButton.disable (duration: 0.25, alpha: 0.65)
        self.purchaseButton.disable(duration: 0.25, alpha: 0.35)

        IAPVerifier.shared.initiatePurchase { result, error, message in
            self.restoreButton.enable (duration: 0.25)
            self.purchaseButton.enable(duration: 0.25)
            if result == true { return self.productWasPurchasedOrRestored() }
            if  error == true, let message = message {
                self.displayAlert(message: message, colour: .systemRed)
            }   else if let message = message, message.isNotEmpty {
                self.displayAlert(message: message, colour: .systemBlue)
            }
        }
    }

    @IBAction func didPressRestore(_ sender: UIButton) {
        self.restoreButton.disable (duration: 0.25, alpha: 0.35)
        self.purchaseButton.disable(duration: 0.25, alpha: 0.65)

        IAPVerifier.shared.restorePurchase { result, error, message in
            if result { return self.productWasPurchasedOrRestored() }
            
            let colour: UIColor = error ? .systemRed : .systemGreen
            DispatchQueue.main.async {
                self.restoreButton.enable (duration: 0.25)
                self.purchaseButton.enable(duration: 0.25)
                if let message = message {
                    UIView.animate(withDuration: 0.25) {
                        self.displayAlert(message: message, colour: colour)
                    }
                }
            }
        }
    }

    @IBAction func didCloseAlert(_ sender: UIButton) {
        hideAlert()
    }

    @IBAction func didPressClose(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        guard let touch = touches.first else { return }
        let location = touch.location(in: windowPanel)
        let alertLocation = touch.location(in: alertPanel)
        let shouldDismiss = !(windowPanel.point(inside: location, with: nil))
        let usingAlert = !alertPanel.isHidden && alertPanel.point(inside: alertLocation, with: nil)
        if  shouldDismiss && !usingAlert {
            dismiss(animated: true, completion: nil)
        }
    }

}

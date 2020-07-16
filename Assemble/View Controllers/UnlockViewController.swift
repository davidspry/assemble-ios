//  Assemble
//  Created by David Spry on 14/7/20.
//  Copyright © 2020 David Spry. All rights reserved.

import UIKit

class UnlockViewController: UIViewController {
    
    @IBOutlet weak var windowPanel: UIView!
    
    @IBOutlet weak var purchaseButton: UIButton!

    private let purchaseLabel: String = "PURCHASE"

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func didPressPurchase(_ sender: UIButton) {
        
    }

    @IBAction func didPressRestore(_ sender: UIButton) {
        
    }
    
    @IBAction func didPressClose(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
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

}

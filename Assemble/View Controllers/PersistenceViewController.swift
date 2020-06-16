//  Assemble
//  Created by David Spry on 21/5/20.
//  Copyright © 2020 David Spry. All rights reserved.

import UIKit

/// An interface to preset saving and preset loading

class PersistenceViewController: UIViewController {

    /// A weak reference to the MainViewController, which facilitates preset loading and preset saving,
    /// including updating the UI to reflect changes in the underlying state

    weak var delegate: MainViewController?
    
    @IBOutlet weak var windowPanel: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()
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

    @IBAction func didPressClose(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }

}

//  Assemble
//  Created by David Spry on 26/5/20.
//  Copyright © 2020 David Spry. All rights reserved.

import UIKit

class NewSongViewController: UIViewController {

    weak var delegate: MainViewController?

    @IBOutlet weak var windowPanel: UIView!
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        guard let touch = touches.first else { return }
        let location = touch.location(in: windowPanel)
        let shouldDismiss = !(windowPanel.point(inside: location, with: nil))
        if  shouldDismiss {
            dismiss(animated: true, completion: nil)
        }
    }

    @IBAction func didPressOK(_ sender: UIButton) {
        delegate?.beginNewSong()
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func didPressCancel(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func didPressClose(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }

}

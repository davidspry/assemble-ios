//  Assemble
//  Created by David Spry on 25/6/20.
//  Copyright © 2020 David Spry. All rights reserved.

import UIKit

class ShareCardViewController: UIViewController {

    @IBOutlet weak var windowPanel: UIView!

    @IBOutlet weak var fileLabel: UILabel!

    @IBOutlet weak var share: UIButton!
    
    var file: URL?

    override func viewDidLoad() {
        super.viewDidLoad()

        share.isHidden = !(MediaUtilities.canAccessInstagram())
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let url = file {
            fileLabel.text = url.lastPathComponent
        }
    }
    
    /// Attempt to share the media file to Instagram, then dismiss the view controller

    @IBAction func didPressShare(_ sender: UIButton) {
        if let url = file { MediaUtilities.shareToInstagram(url) }
        dismiss(animated: true, completion: nil)
    }
    
    
    /// Dismiss the view controller if the user presses the close button

    @IBAction func didPressClose(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }

    /// Dismiss the view controller if the user presses the dismiss button

    @IBAction func didPressDismiss(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }

    /// Dismiss the view controller if the user taps outside of the main window panel

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

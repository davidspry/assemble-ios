//  Assemble
//  Created by David Spry on 16/7/20.
//  Copyright © 2020 David Spry. All rights reserved.

import UIKit

class UnlockedFeaturesViewController: UIViewController {

    private let voices: [Float] = [2, 4, 8]

    @IBOutlet weak var windowPanel: UIView!
    @IBOutlet weak var sinPolyphonyControl: ASSegmentedControl!
    @IBOutlet weak var triPolyphonyControl: ASSegmentedControl!
    @IBOutlet weak var sqrPolyphonyControl: ASSegmentedControl!
    @IBOutlet weak var sawPolyphonyControl: ASSegmentedControl!

    override func viewDidLoad() {
        super.viewDidLoad()

        sinPolyphonyControl.selectedSegmentIndex = index(from: Assemble.core.getParameter(kSinBankPolyphony))
        triPolyphonyControl.selectedSegmentIndex = index(from: Assemble.core.getParameter(kTriBankPolyphony))
        sqrPolyphonyControl.selectedSegmentIndex = index(from: Assemble.core.getParameter(kSqrBankPolyphony))
        sawPolyphonyControl.selectedSegmentIndex = index(from: Assemble.core.getParameter(kSawBankPolyphony))
    }
    
    /// Return an index for the `voices` array that matches the given polyphony value
    /// or the last index of the `voices` of the array if the polyphony value cannot be found.
    /// - Parameter polyphony: The polyphony value whose index should be returned if possible.

    private func index(from polyphony: Float) -> Int {
        return voices.firstIndex(of: polyphony) ??
               voices.count - 1
    }
    
    /// Return the polyphony value at the proposed index if the index is safe to use with the `voices` array, or nil otherwise.
    /// - Parameter index: The proposed index for the `voices` array.

    private func polyphony(_ index: Int) -> Float? {
        let limit = voices.count - 1
        if let index = voices.index(0, offsetBy: index, limitedBy: limit) {
            return voices[index]
        };  return nil
    }

    @IBAction func didSetSinePolyphony(_ sender: UISegmentedControl) {
        if let polyphony = polyphony(sender.selectedSegmentIndex) {
            Assemble.core.setParameter(kSinBankPolyphony, to: polyphony)
        }
    }
    
    @IBAction func didSetTrianglePolyphony(_ sender: UISegmentedControl) {
        if let polyphony = polyphony(sender.selectedSegmentIndex) {
            Assemble.core.setParameter(kTriBankPolyphony, to: polyphony)
        }
    }
    
    @IBAction func didSetSquarePolyphony(_ sender: UISegmentedControl) {
        if let polyphony = polyphony(sender.selectedSegmentIndex) {
            Assemble.core.setParameter(kSqrBankPolyphony, to: polyphony)
        }
    }
    
    @IBAction func didSetSawtoothPolyphony(_ sender: UISegmentedControl) {
        if let polyphony = polyphony(sender.selectedSegmentIndex) {
            Assemble.core.setParameter(kSawBankPolyphony, to: polyphony)
        }
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

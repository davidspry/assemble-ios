//  Assemble
//  Created by David Spry on 14/5/20.
//  Copyright © 2020 David Spry. All rights reserved.

import UIKit

/// The header cell for an effect's parameters in a `ParametersViewController` table

class MenuHeaderCell: UITableViewCell {
    
    /// The state of the toggleable parameter

    private var state: Bool = false
    
    /// The address of the toggleable parameter

    private var parameter: Int32 = kStereoDelayToggle
    
    /// The icon displayed on the `UIButton`

    private var icon : UIImage {
        get {
            return state ? UIImage(systemName: "circle.fill")! :
                           UIImage(systemName: "circle")!
        }
    }

    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var toggle: UIButton!

    private func updateButtonImage() {
        toggle.setImage(icon, for: .normal)
    }
    
    /// Initialise the cell with the address of a toggleable, boolean parameter
    /// - Parameter parameter: The address of a parameter that can has boolean values

    func initialise(with parameter: Int32) {
        if #available(iOS 13.4, *) {
            toggle.isPointerInteractionEnabled = true
            toggle.pointerStyleProvider = pointerInteractionStyle(_:_:_:)
        }

        let state = Assemble.core.getParameter(parameter)
        self.state = Int(state) == 0 ? false : true
        self.parameter = parameter
        updateButtonImage()
    }

    @IBAction func didPressToggle(_ sender: UIButton) {
        state = !state
        let state: Float = self.state == false ? 0 : 1
        Assemble.core.setParameter(parameter, to: state)
        updateButtonImage()
    }

    /// Define a pointer interaction style for the cell

    @available(iOS 13.4, *)
    private func pointerInteractionStyle(_ button: UIButton, _ effect: UIPointerEffect, _ shape: UIPointerShape) -> UIPointerStyle? {
        let view = UITargetedPreview(view: button)
        let effect = UIPointerEffect.hover(view)
        return UIPointerStyle(effect: effect)
    }

}

//  Assemble
//  Created by David Spry on 14/5/20.
//  Copyright © 2020 David Spry. All rights reserved.

import UIKit

class MenuHeaderCell: UITableViewCell {
    
    var state: Bool = false
    
    var parameter: Int32 = kStereoDelayToggle
    
    var icon : UIImage {
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
    
    func initialise(with parameter: Int32) {
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

}

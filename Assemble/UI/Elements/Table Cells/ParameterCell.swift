//  Assemble
//  Created by David Spry on 15/5/20.
//  Copyright © 2020 David Spry. All rights reserved.

import UIKit

/// A cell containing a `ParameterLabel` that represents a controllable parameter in a `ParametersViewController` table

class ParameterCell: UITableViewCell {

    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var parameter: ParameterLabel!

}

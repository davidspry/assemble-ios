//  Assemble
//  Created by David Spry on 14/5/20.
//  Copyright © 2020 David Spry. All rights reserved.

import UIKit

struct VibratoParameters : ParameterMenu {
    
    var name: String = "Vibrato"
    
    var toggle: Int32? = kVibratoToggle
    
    var sections: Int = 2
    
    func itemsInSection(_ section: Int) -> Int {
        return section == 0 ? 1 : 2
    }
    
    var labels: [String] =
    [
        "Speed",
        "Depth"
    ]
    
    var parameters: [(address: Int32, increment: Float, type: ParameterLabelScale)] =
    [
        (address: kVibratoSpeed, increment: 0.1, type: .continuousRegular),
        (address: kVibratoDepth, increment: 0.01, type: .continuousSlow)
    ]
    
    func labelFor(_ path: IndexPath) -> String {
        guard path.section == 1 else { fatalError("[VibratoParameters] Unknown parameter section") }
        return labels[path.row]
    }
    
    func parameterFor(_ path: IndexPath) -> (address: Int32, increment: Float, type: ParameterLabelScale) {
        guard path.section == 1 else { fatalError("[VibratoParameters] Unknown parameter section") }
        return parameters[path.row]
    }
    
    func headerFor(table: UITableView, path: IndexPath) -> UITableViewCell {
        let reuseIdentifier = "menuHeader"
        let cell = table.dequeueReusableCell(withIdentifier: reuseIdentifier, for: path)
        return cell
    }

}

//  Assemble
//  Created by David Spry on 14/5/20.
//  Copyright © 2020 David Spry. All rights reserved.

import UIKit

struct StereoDelayParameters : ParameterMenu {
    
    var name: String = "Stereo Delay"
    
    var toggle: Int32? = kStereoDelayToggle
    
    var sections: Int = 3
    
    func itemsInSection(_ section: Int) -> Int {
        switch (section)
        {
        case 0: return 1
        case 1: return 4
        case 2: return 2
        default: fatalError("[StereoDelayParameters] Unknown section")
        }
    }
    
    var labels: [String] =
    [
        "Time L",
        "Time R",
        "Feedback",
        "Mix",
        "Modulation speed",
        "Modulation depth"
    ]
    
    var parameters: [(address: Int32, type: ParameterLabelScale)]
    {
        return [
            (address: kStereoDelayLTime, type: .discreteSlow),
            (address: kStereoDelayRTime, type: .discreteSlow),
            (address: kDelayFeedback, type: .continuousSlow),
            (address: kDelayMix, type: .continuousSlow),
            (address: kDelayModulationSpeed, type: .continuousSlow),
            (address: kDelayModulationDepth, type: .continuousSlow)
        ]
    }
    
    func labelFor(_ path: IndexPath) -> String {
        switch (path.section)
        {
        case 1: return labels[path.row]
        case 2: return labels[path.row + 4]
        default: fatalError("[StereoDelayParameters] Unknown parameter section")
        }
    }
    
    func parameterFor(_ path: IndexPath) -> (address: Int32, type: ParameterLabelScale) {
        switch (path.section)
        {
        case 1: return parameters[path.row]
        case 2: return parameters[path.row + 4]
        default: fatalError("[StereoDelayParameters] Unknown parameter section")
        }
    }
    
    func headerFor(table: UITableView, path: IndexPath) -> UITableViewCell {
        let reuseIdentifier = "menuHeader"
        let cell = table.dequeueReusableCell(withIdentifier: reuseIdentifier, for: path)
        return cell
    }
}

//  Assemble
//  Created by David Spry on 14/5/20.
//  Copyright © 2020 David Spry. All rights reserved.

import UIKit

struct StereoDelayParameters : ParameterMenu {
    
    var name: String = "Stereo Delay"
    
    var toggle: Int32? = kStereoDelayToggle
    
    var sections: Int = 2
    
    func itemsInSection(_ section: Int) -> Int {
        switch (section)
        {
        case 0: return 1
        case 1: return 5
        default: fatalError("[StereoDelayParameters] Unknown section")
        }
    }
    
    var labels: [String] =
    [
        "Time L",
        "Time R",
        "Feedback",
        "Offset",
        "Mix",
    ]
    
    var parameters: [(address: Int32, increment: Float, type: ParameterLabelScale)]
    {
        return [
            (address: kStereoDelayLTime, increment: 1.0, type: .discreteSlow),
            (address: kStereoDelayRTime, increment: 1.0, type: .discreteSlow),
            (address: kDelayFeedback, increment: 0.01, type: .continuousSlow),
            (address: kStereoDelayOffset, increment: 1.0, type: .continuousRegular),
            (address: kDelayMix, increment: 0.01, type: .continuousSlow)
        ]
    }
    
    func labelFor(_ path: IndexPath) -> String {
        switch (path.section)
        {
        case 1: return labels[path.row]
        default: fatalError("[StereoDelayParameters] Unknown parameter section")
        }
    }
    
    func parameterFor(_ path: IndexPath) -> (address: Int32, increment: Float, type: ParameterLabelScale) {
        switch (path.section)
        {
        case 1: return parameters[path.row]
        default: fatalError("[StereoDelayParameters] Unknown parameter section")
        }
    }
    
    func headerFor(table: UITableView, path: IndexPath) -> UITableViewCell {
        let reuseIdentifier = "menuHeader"
        let cell = table.dequeueReusableCell(withIdentifier: reuseIdentifier, for: path)
        return cell
    }
}

//  Assemble
//  Created by David Spry on 14/5/20.
//  Copyright © 2020 David Spry. All rights reserved.

import UIKit

struct OscillatorParameters : ParameterMenu {

    var name: String = "Oscillators"
    
    var toggle: Int32? = nil
    
    var oscillator: OscillatorShape = .sine
    
    var sections: Int = 4
    
    var labels: [String] =
    [
        "LPF Frequency",
        "LPF Resonance",
        "VCA Attack",
        "VCA Hold",
        "VCA Release",
        "VCF Attack",
        "VCF Hold",
        "VCF Release"
    ]
    
    var parameters: [(address: Int32, increment: Float, type: ParameterLabelScale)]
    {
        switch (oscillator)
        {
        case .sine:
            return [
                (address: kSinFilterFrequency, increment: 0.01, type: .continuousSlow),
                (address: kSinFilterResonance, increment: 0.01, type: .continuousSlow),
                (address: kSinAmpAttack, increment: 5.0, type: .discreteFast),
                (address: kSinAmpHold, increment: 5.0, type: .discreteFast),
                (address: kSinAmpRelease, increment: 5.0, type: .continuousFast),
                (address: kSinFilterAttack, increment: 5.0, type: .discreteFast),
                (address: kSinFilterHold, increment: 5.0, type: .discreteFast),
                (address: kSinFilterRelease, increment: 5.0, type: .continuousFast)
            ]
        
        case .triangle:
            return [
                (address: kTriFilterFrequency, increment: 0.01, type: .continuousSlow),
                (address: kTriFilterResonance, increment: 0.01, type: .continuousSlow),
                (address: kTriAmpAttack, increment: 5.0, type: .discreteFast),
                (address: kTriAmpHold, increment: 5.0, type: .discreteFast),
                (address: kTriAmpRelease, increment: 5.0, type: .continuousFast),
                (address: kTriFilterAttack, increment: 5.0, type: .discreteFast),
                (address: kTriFilterHold, increment: 5.0, type: .discreteFast),
                (address: kTriFilterRelease, increment: 5.0, type: .continuousFast)
            ]
            
        case .square:
            return [
                (address: kSqrFilterFrequency, increment: 0.01, type: .continuousSlow),
                (address: kSqrFilterResonance, increment: 0.01, type: .continuousSlow),
                (address: kSqrAmpAttack, increment: 5.0, type: .discreteFast),
                (address: kSqrAmpHold, increment: 5.0, type: .discreteFast),
                (address: kSqrAmpRelease, increment: 5.0, type: .continuousFast),
                (address: kSqrFilterAttack, increment: 5.0, type: .discreteFast),
                (address: kSqrFilterHold, increment: 5.0, type: .discreteFast),
                (address: kSqrFilterRelease, increment: 5.0, type: .continuousFast)
            ]
            
        case .sawtooth:
            return [
                (address: kSawFilterFrequency, increment: 0.01, type: .continuousSlow),
                (address: kSawFilterResonance, increment: 0.01, type: .continuousSlow),
                (address: kSawAmpAttack, increment: 5.0, type: .discreteFast),
                (address: kSawAmpHold, increment: 5.0, type: .discreteFast),
                (address: kSawAmpRelease, increment: 5.0, type: .continuousFast),
                (address: kSawFilterAttack, increment: 5.0, type: .discreteFast),
                (address: kSawFilterHold, increment: 5.0, type: .discreteFast),
                (address: kSawFilterRelease, increment: 5.0, type: .continuousFast)
            ]
            
        default: fatalError("[OscillatorParameters] Unknown oscillator")
        }
    }
    
    func itemsInSection(_ section: Int) -> Int {
        switch (section)
        {
        case 0: return 1
        case 1: return 2
        case 2: fallthrough
        case 3: return 3
        default: fatalError("[OscillatorParameters] Unknown section")
        }
    }

    func labelFor(_ path: IndexPath) -> String {
        switch (path.section)
        {
        case 1: return labels[path.row]
        case 2: return labels[path.row + 2]
        case 3: return labels[path.row + 3 + 2]
        default: fatalError("[OscillatorParameters] Unknown section")
        }
    }
    
    func parameterFor(_ path: IndexPath) -> (address: Int32, increment: Float, type: ParameterLabelScale) {
        switch (path.section)
        {
        case 1: return parameters[path.row]
        case 2: return parameters[path.row + 2]
        case 3: return parameters[path.row + 3 + 2]
        default: fatalError("[OscillatorParameters] Unknown section")
        }
    }

    func headerFor(table: UITableView, path: IndexPath) -> UITableViewCell {
        let reuseIdentifier = "oscillatorsHeader"
        let cell = table.dequeueReusableCell(withIdentifier: reuseIdentifier, for: path)
        return cell
    }
}

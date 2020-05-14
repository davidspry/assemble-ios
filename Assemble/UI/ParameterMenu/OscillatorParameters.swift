//  Assemble
//  Created by David Spry on 14/5/20.
//  Copyright © 2020 David Spry. All rights reserved.

import UIKit

struct OscillatorParameters : ParameterMenu {
    
    internal enum Sections: Int {
        case header
        case lpf
        case vca
        case vcf
        case sections
    }
    
    var name: String = "Oscillators"
    
    var toggle: Int32? = nil
    
    var oscillator: OscillatorShape = .sine
    
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
    
    var parameters: [(address: Int32, type: ParameterLabelScale)]
    {
        switch (oscillator)
        {
        case .sine:
            return [
                (address: kSinFilterFrequency, type: .continuousSlow),
                (address: kSinFilterResonance, type: .continuousSlow),
                (address: kSinAmpAttack, type: .continuousFast),
                (address: kSinAmpHold, type: .continuousFast),
                (address: kSinAmpRelease, type: .continuousFast),
                (address: kSinFilterAttack, type: .continuousFast),
                (address: kSinFilterHold, type: .continuousFast),
                (address: kSinFilterRelease, type: .continuousFast)
            ]
        
        case .triangle:
            return [
                (address: kTriFilterFrequency, type: .continuousFast),
                (address: kTriFilterResonance, type: .continuousFast),
                (address: kTriAmpAttack, type: .continuousFast),
                (address: kTriAmpHold, type: .continuousFast),
                (address: kTriAmpRelease, type: .continuousFast),
                (address: kTriFilterAttack, type: .continuousFast),
                (address: kTriFilterHold, type: .continuousFast),
                (address: kTriFilterRelease, type: .continuousFast)
            ]
            
        case .square:
            return [
                (address: kSqrFilterFrequency, type: .continuousSlow),
                (address: kSqrFilterResonance, type: .continuousSlow),
                (address: kSqrAmpAttack, type: .continuousFast),
                (address: kSqrAmpHold, type: .continuousFast),
                (address: kSqrAmpRelease, type: .continuousFast),
                (address: kSqrFilterAttack, type: .continuousFast),
                (address: kSqrFilterHold, type: .continuousFast),
                (address: kSqrFilterRelease, type: .continuousFast)
            ]
            
        case .sawtooth:
            return [
                (address: kSawFilterFrequency, type: .continuousSlow),
                (address: kSawFilterResonance, type: .continuousSlow),
                (address: kSawAmpAttack, type: .continuousFast),
                (address: kSawAmpHold, type: .continuousFast),
                (address: kSawAmpRelease, type: .continuousFast),
                (address: kSawFilterAttack, type: .continuousFast),
                (address: kSawFilterHold, type: .continuousFast),
                (address: kSawFilterRelease, type: .continuousFast)
            ]
            
        default: fatalError("[OscillatorParameters] Unknown oscillator")
        }
    }

    var sections: Int = Sections.sections.rawValue
    
    func itemsInSection(_ section: Int) -> Int {
        switch (section)
        {
        case Sections.header.rawValue: return 1
        case Sections.lpf.rawValue: return 2
        case Sections.vca.rawValue: fallthrough
        case Sections.vcf.rawValue: return 3
        default: fatalError("[OscillatorParameters] Unknown section")
        }
    }

    func labelFor(_ path: IndexPath) -> String {
        switch (path.section)
        {
        case Sections.lpf.rawValue: return labels[path.row]
        case Sections.vca.rawValue: return labels[path.row + 2]
        case Sections.vcf.rawValue: return labels[path.row + 3 + 2]
        default: fatalError("[OscillatorParameters] Unknown section")
        }
    }
    
    func parameterFor(_ path: IndexPath) -> (address: Int32, type: ParameterLabelScale) {
        switch (path.section)
        {
        case Sections.lpf.rawValue: return parameters[path.row]
        case Sections.vca.rawValue: return parameters[path.row + 2]
        case Sections.vcf.rawValue: return parameters[path.row + 3 + 2]
        default: fatalError("[OscillatorParameters] Unknown section")
        }
    }

    func headerFor(table: UITableView, path: IndexPath) -> UITableViewCell {
        let reuseIdentifier = "oscillatorsHeader"
        let cell = table.dequeueReusableCell(withIdentifier: reuseIdentifier, for: path)
        return cell
    }
}

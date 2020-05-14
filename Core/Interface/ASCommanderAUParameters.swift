//  Assemble
//  Created by David Spry on 7/5/20.
//  Copyright © 2020 David Spry. All rights reserved.

import AudioUnit
import Foundation

struct ASCommanderAUParameters {
    static private let defaultBPM: Float = 120
    static private let defaultSubdivison: Float = 4
    
    static private let defaultEnvelopeA: Float = 5.0
    static private let defaultEnvelopeH: Float = 0.0
    static private let defaultEnvelopeR: Float = 500.0
    
    static private let defaultFilterFrequency: Float = 1
    static private let defaultFilterResonance: Float = 0
    
    // MARK: - Parameter Groups
    static public let parametersClock =
        AUParameterTree.createGroup(withIdentifier: "parametersClock",
                                    name: "Clock",
                                    children: [
                                    ASCommanderAUParameters.clockBPM,
                                    ASCommanderAUParameters.clockSubdivision
        ])

    static public let parametersFilter =
        AUParameterTree.createGroup(withIdentifier: "parametersFilter",
                                    name: "Lowpass Filter",
                                    children: [
                                    ASCommanderAUParameters.sinFilterFrequency,
                                    ASCommanderAUParameters.sinFilterResonance,
                                    ASCommanderAUParameters.triFilterFrequency,
                                    ASCommanderAUParameters.triFilterResonance,
                                    ASCommanderAUParameters.sqrFilterFrequency,
                                    ASCommanderAUParameters.sqrFilterResonance,
                                    ASCommanderAUParameters.sawFilterFrequency,
                                    ASCommanderAUParameters.sawFilterResonance
        ])

    static public let parametersSine =
        AUParameterTree.createGroup(withIdentifier: "parametersSine",
                                    name: "Sine Oscillator",
                                    children: [
                                    ASCommanderAUParameters.sinAmpAttack,
                                    ASCommanderAUParameters.sinAmpHold,
                                    ASCommanderAUParameters.sinAmpRelease,
                                    ASCommanderAUParameters.sinFilterAttack,
                                    ASCommanderAUParameters.sinFilterHold,
                                    ASCommanderAUParameters.sinFilterRelease
        ])
    
    static public let parametersTriangle =
        AUParameterTree.createGroup(withIdentifier: "parametersTriangle",
                                    name: "Triangle Oscillator",
                                    children: [
                                    ASCommanderAUParameters.triAmpAttack,
                                    ASCommanderAUParameters.triAmpHold,
                                    ASCommanderAUParameters.triAmpRelease,
                                    ASCommanderAUParameters.triFilterAttack,
                                    ASCommanderAUParameters.triFilterHold,
                                    ASCommanderAUParameters.triFilterRelease
        ])
    
    static public let parametersSquare =
        AUParameterTree.createGroup(withIdentifier: "parametersSquare",
                                    name: "Square Oscillator",
                                    children: [
                                    ASCommanderAUParameters.sqrAmpAttack,
                                    ASCommanderAUParameters.sqrAmpHold,
                                    ASCommanderAUParameters.sqrAmpRelease,
                                    ASCommanderAUParameters.sqrFilterAttack,
                                    ASCommanderAUParameters.sqrFilterHold,
                                    ASCommanderAUParameters.sqrFilterRelease
        ])
    
    static public let parametersSawtooth =
        AUParameterTree.createGroup(withIdentifier: "parametersSawtooth",
                                    name: "Sawtooth Oscillator",
                                    children: [
                                    ASCommanderAUParameters.sawAmpAttack,
                                    ASCommanderAUParameters.sawAmpHold,
                                    ASCommanderAUParameters.sawAmpRelease,
                                    ASCommanderAUParameters.sawFilterAttack,
                                    ASCommanderAUParameters.sawFilterHold,
                                    ASCommanderAUParameters.sawFilterRelease
        ])

    static public let parametersDelay =
        AUParameterTree.createGroup(withIdentifier: "parametersStereoDelay",
                                    name: "Stereo Delay",
                                    children: [
                                    ASCommanderAUParameters.stereoDelayToggle,
                                    ASCommanderAUParameters.stereoDelayFeedback,
                                    ASCommanderAUParameters.stereoDelayTimeLeft,
                                    ASCommanderAUParameters.stereoDelayTimeRight,
                                    ASCommanderAUParameters.stereoDelayMix,
                                    ASCommanderAUParameters.stereoDelayModulationSpeed,
                                    ASCommanderAUParameters.stereoDelayModulationDepth
        ])
    
    static public let parametersVibrato =
        AUParameterTree.createGroup(withIdentifier: "parametersVibrato",
                                    name: "Vibrato",
                                    children: [
                                    ASCommanderAUParameters.vibratoToggle,
                                    ASCommanderAUParameters.vibratoSpeed,
                                    ASCommanderAUParameters.vibratoDepth
        ])
    
    // MARK: - Clock Parameters
    
    static var clockBPM: AUParameter = {
        let parameter =
            AUParameterTree.createParameter(withIdentifier: "kClockBPM",
                                            name: "Clock BPM",
                                            address: AUParameterAddress(kClockBPM),
                                            min: 30, max: 300,
                                            unit: .BPM,
                                            unitName: "BPM",
                                            flags: [.flag_IsReadable, .flag_IsWritable],
                                            valueStrings: nil,
                                            dependentParameters: nil)
        parameter.value = ASCommanderAUParameters.defaultBPM
        return parameter
    }()
    
    static var clockSubdivision: AUParameter = {
        let parameter =
            AUParameterTree.createParameter(withIdentifier: "kClockSubdivision",
                                            name: "Clock Subdivision",
                                            address: AUParameterAddress(kClockSubdivision),
                                            min: 2, max: 7,
                                            unit: .beats,
                                            unitName: "ticks",
                                            flags: [.flag_IsReadable, .flag_IsWritable],
                                            valueStrings: nil,
                                            dependentParameters: nil)
        parameter.value = ASCommanderAUParameters.defaultSubdivison
        return parameter
    }()
    
    // MARK: - Sine Oscillator Filter Parameters
    
    static var sinFilterFrequency: AUParameter = {
        let parameter =
            AUParameterTree.createParameter(withIdentifier: "kSinFilterFrequency",
                                            name: "[SIN] Filter frequency",
                                            address: AUParameterAddress(kSinFilterFrequency),
                                            min: 0, max: 1,
                                            unit: .hertz,
                                            unitName: "Hz",
                                            flags: [.flag_IsReadable, .flag_IsWritable,
                                                    .flag_IsHighResolution,
                                                    .flag_DisplayExponential],
                                            valueStrings: nil,
                                            dependentParameters: nil)
        parameter.value = ASCommanderAUParameters.defaultFilterFrequency
        return parameter
    }()
    
    static var sinFilterResonance: AUParameter = {
        let parameter =
            AUParameterTree.createParameter(withIdentifier: "kSinFilterResonance",
                                            name: "[SIN] Filter resonance",
                                            address: AUParameterAddress(kSinFilterResonance),
                                            min: 0, max: 1,
                                            unit: .generic,
                                            unitName: nil,
                                            flags: [.flag_IsReadable, .flag_IsWritable],
                                            valueStrings: nil,
                                            dependentParameters: nil)
        parameter.value = ASCommanderAUParameters.defaultFilterResonance
        return parameter
    }()
    
    // MARK: - Sine Oscillator Amplitude Envelope Parameters
    
    static var sinAmpAttack: AUParameter = {
        let parameter =
            AUParameterTree.createParameter(withIdentifier: "kSinAmpAttack",
                                            name: "[SIN] AE Attack",
                                            address: AUParameterAddress(kSinAmpAttack),
                                            min: 0, max: 4000,
                                            unit: .milliseconds,
                                            unitName: "ms",
                                            flags: [.flag_IsReadable, .flag_IsWritable],
                                            valueStrings: nil,
                                            dependentParameters: nil)
        parameter.value = ASCommanderAUParameters.defaultEnvelopeA
        return parameter
    }()
    
    static var sinAmpHold: AUParameter = {
        let parameter =
            AUParameterTree.createParameter(withIdentifier: "kSinAmpHold",
                                            name: "[SIN] AE Hold",
                                            address: AUParameterAddress(kSinAmpHold),
                                            min: 0, max: 4000,
                                            unit: .milliseconds,
                                            unitName: "ms",
                                            flags: [.flag_IsReadable, .flag_IsWritable],
                                            valueStrings: nil,
                                            dependentParameters: nil)
        parameter.value = ASCommanderAUParameters.defaultEnvelopeH
        return parameter
    }()
    
    static var sinAmpRelease: AUParameter = {
        let parameter =
            AUParameterTree.createParameter(withIdentifier: "kSinAmpRelease",
                                            name: "[SIN] AE Release",
                                            address: AUParameterAddress(kSinAmpRelease),
                                            min: 0, max: 4000,
                                            unit: .milliseconds,
                                            unitName: "ms",
                                            flags: [.flag_IsReadable, .flag_IsWritable],
                                            valueStrings: nil,
                                            dependentParameters: nil)
        parameter.value = ASCommanderAUParameters.defaultEnvelopeR
        return parameter
    }()
    
    // MARK: - Sine Oscillator Filter Envelope Parameters
    
    static var sinFilterAttack: AUParameter = {
        let parameter =
            AUParameterTree.createParameter(withIdentifier: "kSinFilterAttack",
                                            name: "[SIN] FE Attack",
                                            address: AUParameterAddress(kSinFilterAttack),
                                            min: 0, max: 4000,
                                            unit: .milliseconds,
                                            unitName: "ms",
                                            flags: [.flag_IsReadable, .flag_IsWritable],
                                            valueStrings: nil,
                                            dependentParameters: nil)
        parameter.value = ASCommanderAUParameters.defaultEnvelopeA
        return parameter
    }()
    
    static var sinFilterHold: AUParameter = {
        let parameter =
            AUParameterTree.createParameter(withIdentifier: "kSinFilterHold",
                                            name: "[SIN] FE Hold",
                                            address: AUParameterAddress(kSinFilterHold),
                                            min: 0, max: 4000,
                                            unit: .milliseconds,
                                            unitName: "ms",
                                            flags: [.flag_IsReadable, .flag_IsWritable],
                                            valueStrings: nil,
                                            dependentParameters: nil)
        parameter.value = ASCommanderAUParameters.defaultEnvelopeH
        return parameter
    }()
    
    static var sinFilterRelease: AUParameter = {
        let parameter =
            AUParameterTree.createParameter(withIdentifier: "kSinFilterRelease",
                                            name: "[SIN] FE Release",
                                            address: AUParameterAddress(kSinFilterRelease),
                                            min: 0, max: 4000,
                                            unit: .milliseconds,
                                            unitName: "ms",
                                            flags: [.flag_IsReadable, .flag_IsWritable],
                                            valueStrings: nil,
                                            dependentParameters: nil)
        parameter.value = ASCommanderAUParameters.defaultEnvelopeR
        return parameter
    }()
    
    // MARK: - Triangle Oscillator Filter Parameters
    
    static var triFilterFrequency: AUParameter = {
        let parameter =
            AUParameterTree.createParameter(withIdentifier: "kTriFilterFrequency",
                                            name: "[TRI] Filter frequency",
                                            address: AUParameterAddress(kTriFilterFrequency),
                                            min: 0, max: 1,
                                            unit: .hertz,
                                            unitName: "Hz",
                                            flags: [.flag_IsReadable, .flag_IsWritable,
                                                    .flag_IsHighResolution,
                                                    .flag_DisplayExponential],
                                            valueStrings: nil,
                                            dependentParameters: nil)
        parameter.value = ASCommanderAUParameters.defaultFilterFrequency
        return parameter
    }()
    
    static var triFilterResonance: AUParameter = {
        let parameter =
            AUParameterTree.createParameter(withIdentifier: "kTriFilterResonance",
                                            name: "[TRI] Filter resonance",
                                            address: AUParameterAddress(kTriFilterResonance),
                                            min: 0, max: 1,
                                            unit: .generic,
                                            unitName: nil,
                                            flags: [.flag_IsReadable, .flag_IsWritable],
                                            valueStrings: nil,
                                            dependentParameters: nil)
        parameter.value = ASCommanderAUParameters.defaultFilterResonance
        return parameter
    }()
    
    // MARK: - Triangle Oscillator Amplitude Envelope Parameters
    
    static var triAmpAttack: AUParameter = {
        let parameter =
            AUParameterTree.createParameter(withIdentifier: "kTriAmpAttack",
                                            name: "[TRI] AE Attack",
                                            address: AUParameterAddress(kTriAmpAttack),
                                            min: 0, max: 4000,
                                            unit: .milliseconds,
                                            unitName: "ms",
                                            flags: [.flag_IsReadable, .flag_IsWritable],
                                            valueStrings: nil,
                                            dependentParameters: nil)
        parameter.value = ASCommanderAUParameters.defaultEnvelopeA
        return parameter
    }()
    
    static var triAmpHold: AUParameter = {
        let parameter =
            AUParameterTree.createParameter(withIdentifier: "kTriAmpHold",
                                            name: "[TRI] AE Hold",
                                            address: AUParameterAddress(kTriAmpHold),
                                            min: 0, max: 4000,
                                            unit: .milliseconds,
                                            unitName: "ms",
                                            flags: [.flag_IsReadable, .flag_IsWritable],
                                            valueStrings: nil,
                                            dependentParameters: nil)
        parameter.value = ASCommanderAUParameters.defaultEnvelopeH
        return parameter
    }()
    
    static var triAmpRelease: AUParameter = {
        let parameter =
            AUParameterTree.createParameter(withIdentifier: "kTriAmpRelease",
                                            name: "[TRI] AE Release",
                                            address: AUParameterAddress(kTriAmpRelease),
                                            min: 0, max: 4000,
                                            unit: .milliseconds,
                                            unitName: "ms",
                                            flags: [.flag_IsReadable, .flag_IsWritable],
                                            valueStrings: nil,
                                            dependentParameters: nil)
        parameter.value = ASCommanderAUParameters.defaultEnvelopeR
        return parameter
    }()
    
    // MARK: - Triangle Oscillator Filter Envelope Parameters
    
    static var triFilterAttack: AUParameter = {
        let parameter =
            AUParameterTree.createParameter(withIdentifier: "kTriFilterAttack",
                                            name: "[TRI] FE Attack",
                                            address: AUParameterAddress(kTriFilterAttack),
                                            min: 0, max: 4000,
                                            unit: .milliseconds,
                                            unitName: "ms",
                                            flags: [.flag_IsReadable, .flag_IsWritable],
                                            valueStrings: nil,
                                            dependentParameters: nil)
        parameter.value = ASCommanderAUParameters.defaultEnvelopeA
        return parameter
    }()
    
    static var triFilterHold: AUParameter = {
        let parameter =
            AUParameterTree.createParameter(withIdentifier: "kTriFilterHold",
                                            name: "[TRI] FE Hold",
                                            address: AUParameterAddress(kTriFilterHold),
                                            min: 0, max: 4000,
                                            unit: .milliseconds,
                                            unitName: "ms",
                                            flags: [.flag_IsReadable, .flag_IsWritable],
                                            valueStrings: nil,
                                            dependentParameters: nil)
        parameter.value = ASCommanderAUParameters.defaultEnvelopeH
        return parameter
    }()
    
    static var triFilterRelease: AUParameter = {
        let parameter =
            AUParameterTree.createParameter(withIdentifier: "kTriFilterRelease",
                                            name: "[TRI] FE Release",
                                            address: AUParameterAddress(kTriFilterRelease),
                                            min: 0, max: 4000,
                                            unit: .milliseconds,
                                            unitName: "ms",
                                            flags: [.flag_IsReadable, .flag_IsWritable],
                                            valueStrings: nil,
                                            dependentParameters: nil)
        parameter.value = ASCommanderAUParameters.defaultEnvelopeR
        return parameter
    }()
    
    // MARK: - Square Oscillator Filter Parameters
    
    static var sqrFilterFrequency: AUParameter = {
        let parameter =
            AUParameterTree.createParameter(withIdentifier: "kSqrFilterFrequency",
                                            name: "[SQR] Filter frequency",
                                            address: AUParameterAddress(kSqrFilterFrequency),
                                            min: 20, max: 20_000,
                                            unit: .hertz,
                                            unitName: "Hz",
                                            flags: [.flag_IsReadable, .flag_IsWritable,
                                                    .flag_IsHighResolution,
                                                    .flag_DisplayExponential],
                                            valueStrings: nil,
                                            dependentParameters: nil)
        parameter.value = ASCommanderAUParameters.defaultFilterFrequency
        return parameter
    }()
    
    static var sqrFilterResonance: AUParameter = {
        let parameter =
            AUParameterTree.createParameter(withIdentifier: "kSqrFilterResonance",
                                            name: "[SQR] Filter resonance",
                                            address: AUParameterAddress(kSqrFilterResonance),
                                            min: 0, max: 1,
                                            unit: .generic,
                                            unitName: nil,
                                            flags: [.flag_IsReadable, .flag_IsWritable],
                                            valueStrings: nil,
                                            dependentParameters: nil)
        parameter.value = ASCommanderAUParameters.defaultFilterResonance
        return parameter
    }()
    
    // MARK: - Square Oscillator Amplitude Envelope Parameters
    
    static var sqrAmpAttack: AUParameter = {
        let parameter =
            AUParameterTree.createParameter(withIdentifier: "kSqrAmpAttack",
                                            name: "[SQR] AE Attack",
                                            address: AUParameterAddress(kSqrAmpAttack),
                                            min: 0, max: 4000,
                                            unit: .milliseconds,
                                            unitName: "ms",
                                            flags: [.flag_IsReadable, .flag_IsWritable],
                                            valueStrings: nil,
                                            dependentParameters: nil)
        parameter.value = ASCommanderAUParameters.defaultEnvelopeA
        return parameter
    }()
    
    static var sqrAmpHold: AUParameter = {
        let parameter =
            AUParameterTree.createParameter(withIdentifier: "kSqrAmpHold",
                                            name: "[SQR] AE Hold",
                                            address: AUParameterAddress(kSqrAmpHold),
                                            min: 0, max: 4000,
                                            unit: .milliseconds,
                                            unitName: "ms",
                                            flags: [.flag_IsReadable, .flag_IsWritable],
                                            valueStrings: nil,
                                            dependentParameters: nil)
        parameter.value = ASCommanderAUParameters.defaultEnvelopeH
        return parameter
    }()
    
    static var sqrAmpRelease: AUParameter = {
        let parameter =
            AUParameterTree.createParameter(withIdentifier: "kSqrAmpRelease",
                                            name: "[SQR] AE Release",
                                            address: AUParameterAddress(kSqrAmpRelease),
                                            min: 0, max: 4000,
                                            unit: .milliseconds,
                                            unitName: "ms",
                                            flags: [.flag_IsReadable, .flag_IsWritable],
                                            valueStrings: nil,
                                            dependentParameters: nil)
        parameter.value = ASCommanderAUParameters.defaultEnvelopeR
        return parameter
    }()
    
    // MARK: - Square Oscillator Filter Envelope Parameters
    
    static var sqrFilterAttack: AUParameter = {
        let parameter =
            AUParameterTree.createParameter(withIdentifier: "kSqrFilterAttack",
                                            name: "[SQR] FE Attack",
                                            address: AUParameterAddress(kSqrFilterAttack),
                                            min: 0, max: 4000,
                                            unit: .milliseconds,
                                            unitName: "ms",
                                            flags: [.flag_IsReadable, .flag_IsWritable],
                                            valueStrings: nil,
                                            dependentParameters: nil)
        parameter.value = ASCommanderAUParameters.defaultEnvelopeA
        return parameter
    }()
    
    static var sqrFilterHold: AUParameter = {
        let parameter =
            AUParameterTree.createParameter(withIdentifier: "kSqrFilterHold",
                                            name: "[SQR] FE Hold",
                                            address: AUParameterAddress(kSqrFilterHold),
                                            min: 0, max: 4000,
                                            unit: .milliseconds,
                                            unitName: "ms",
                                            flags: [.flag_IsReadable, .flag_IsWritable],
                                            valueStrings: nil,
                                            dependentParameters: nil)
        parameter.value = ASCommanderAUParameters.defaultEnvelopeH
        return parameter
    }()
    
    static var sqrFilterRelease: AUParameter = {
        let parameter =
            AUParameterTree.createParameter(withIdentifier: "kSqrFilterRelease",
                                            name: "[SQR] FE Release",
                                            address: AUParameterAddress(kSqrFilterRelease),
                                            min: 0, max: 4000,
                                            unit: .milliseconds,
                                            unitName: "ms",
                                            flags: [.flag_IsReadable, .flag_IsWritable],
                                            valueStrings: nil,
                                            dependentParameters: nil)
        parameter.value = ASCommanderAUParameters.defaultEnvelopeR
        return parameter
    }()
    
    // MARK: - Sawtooth Oscillator Filter Parameters
    
    static var sawFilterFrequency: AUParameter = {
        let parameter =
            AUParameterTree.createParameter(withIdentifier: "kSawFilterFrequency",
                                            name: "[SAW] Filter frequency",
                                            address: AUParameterAddress(kSawFilterFrequency),
                                            min: 0, max: 1,
                                            unit: .hertz,
                                            unitName: "Hz",
                                            flags: [.flag_IsReadable, .flag_IsWritable,
                                                    .flag_IsHighResolution,
                                                    .flag_DisplayExponential],
                                            valueStrings: nil,
                                            dependentParameters: nil)
        parameter.value = ASCommanderAUParameters.defaultFilterFrequency
        return parameter
    }()
    
    static var sawFilterResonance: AUParameter = {
        let parameter =
            AUParameterTree.createParameter(withIdentifier: "kSawFilterResonance",
                                            name: "[SAW] Filter resonance",
                                            address: AUParameterAddress(kSawFilterResonance),
                                            min: 0, max: 1,
                                            unit: .generic,
                                            unitName: nil,
                                            flags: [.flag_IsReadable, .flag_IsWritable],
                                            valueStrings: nil,
                                            dependentParameters: nil)
        parameter.value = ASCommanderAUParameters.defaultFilterResonance
        return parameter
    }()
    
    // MARK: - Sawtooth Oscillator Amplitude Envelope Parameters
    
    static var sawAmpAttack: AUParameter = {
        let parameter =
            AUParameterTree.createParameter(withIdentifier: "kSawAmpAttack",
                                            name: "[SAW] AE Attack",
                                            address: AUParameterAddress(kSawAmpAttack),
                                            min: 0, max: 4000,
                                            unit: .milliseconds,
                                            unitName: "ms",
                                            flags: [.flag_IsReadable, .flag_IsWritable],
                                            valueStrings: nil,
                                            dependentParameters: nil)
        parameter.value = ASCommanderAUParameters.defaultEnvelopeA
        return parameter
    }()
    
    static var sawAmpHold: AUParameter = {
        let parameter =
            AUParameterTree.createParameter(withIdentifier: "kSawAmpHold",
                                            name: "[SAW] AE Hold",
                                            address: AUParameterAddress(kSawAmpHold),
                                            min: 0, max: 4000,
                                            unit: .milliseconds,
                                            unitName: "ms",
                                            flags: [.flag_IsReadable, .flag_IsWritable],
                                            valueStrings: nil,
                                            dependentParameters: nil)
        parameter.value = ASCommanderAUParameters.defaultEnvelopeH
        return parameter
    }()
    
    static var sawAmpRelease: AUParameter = {
        let parameter =
            AUParameterTree.createParameter(withIdentifier: "kSawAmpRelease",
                                            name: "[SAW] AE Release",
                                            address: AUParameterAddress(kSawAmpRelease),
                                            min: 0, max: 4000,
                                            unit: .milliseconds,
                                            unitName: "ms",
                                            flags: [.flag_IsReadable, .flag_IsWritable],
                                            valueStrings: nil,
                                            dependentParameters: nil)
        parameter.value = ASCommanderAUParameters.defaultEnvelopeR
        return parameter
    }()
    
    // MARK: - Sawtooth Oscillator Filter Envelope Parameters
    
    static var sawFilterAttack: AUParameter = {
        let parameter =
            AUParameterTree.createParameter(withIdentifier: "kSawFilterAttack",
                                            name: "[SAW] FE Attack",
                                            address: AUParameterAddress(kSawFilterAttack),
                                            min: 0, max: 4000,
                                            unit: .milliseconds,
                                            unitName: "ms",
                                            flags: [.flag_IsReadable, .flag_IsWritable],
                                            valueStrings: nil,
                                            dependentParameters: nil)
        parameter.value = ASCommanderAUParameters.defaultEnvelopeA
        return parameter
    }()
    
    static var sawFilterHold: AUParameter = {
        let parameter =
            AUParameterTree.createParameter(withIdentifier: "kSawFilterHold",
                                            name: "[SAW] FE Hold",
                                            address: AUParameterAddress(kSawFilterHold),
                                            min: 0, max: 4000,
                                            unit: .milliseconds,
                                            unitName: "ms",
                                            flags: [.flag_IsReadable, .flag_IsWritable],
                                            valueStrings: nil,
                                            dependentParameters: nil)
        parameter.value = ASCommanderAUParameters.defaultEnvelopeH
        return parameter
    }()
    
    static var sawFilterRelease: AUParameter = {
        let parameter =
            AUParameterTree.createParameter(withIdentifier: "kSawFilterRelease",
                                            name: "[SAW] FE Release",
                                            address: AUParameterAddress(kSawFilterRelease),
                                            min: 0, max: 4000,
                                            unit: .milliseconds,
                                            unitName: "ms",
                                            flags: [.flag_IsReadable, .flag_IsWritable],
                                            valueStrings: nil,
                                            dependentParameters: nil)
        parameter.value = ASCommanderAUParameters.defaultEnvelopeR
        return parameter
    }()
    
    // MARK: - Stereo Delay Parameters
    
    static var stereoDelayToggle: AUParameter = {
        let parameter =
            AUParameterTree.createParameter(withIdentifier: "kDelayToggle",
                                            name: "Stereo Delay Toggle",
                                            address: AUParameterAddress(kStereoDelayToggle),
                                            min: 0, max: 1,
                                            unit: .boolean,
                                            unitName: nil,
                                            flags: [.flag_IsReadable, .flag_IsWritable],
                                            valueStrings: nil,
                                            dependentParameters: nil)
        parameter.value = 0
        return parameter
    }()

    static private let delayTimes =
    [ "1/1", "1/2D", "1/2", "1/4D", "1/4", "1/8D", "1/8", "1/16D", "1/16" ]

    static var stereoDelayTimeLeft: AUParameter = {
        let parameter =
            AUParameterTree.createParameter(withIdentifier: "kStereoDelayLTime",
                                            name: "Stereo Delay Time (L)",
                                            address: AUParameterAddress(kStereoDelayLTime),
                                            min: 0, max: 8,
                                            unit: .indexed,
                                            unitName: nil,
                                            flags: [.flag_IsReadable, .flag_IsWritable],
                                            valueStrings: ASCommanderAUParameters.delayTimes,
                                            dependentParameters: nil)
        parameter.value = 6
        return parameter
    }()
    
    static var stereoDelayTimeRight: AUParameter = {
        let parameter =
            AUParameterTree.createParameter(withIdentifier: "kStereoDelayRTime",
                                            name: "Stereo Delay Time (R)",
                                            address: AUParameterAddress(kStereoDelayRTime),
                                            min: 0, max: 8,
                                            unit: .indexed,
                                            unitName: nil,
                                            flags: [.flag_IsReadable, .flag_IsWritable],
                                            valueStrings: ASCommanderAUParameters.delayTimes,
                                            dependentParameters: nil)
        parameter.value = 6
        return parameter
    }()
    
    static var stereoDelayFeedback: AUParameter = {
        let parameter =
            AUParameterTree.createParameter(withIdentifier: "kDelayFeedback",
                                            name: "Stereo Delay Feedback",
                                            address: AUParameterAddress(kDelayFeedback),
                                            min: 0, max: 1,
                                            unit: .generic,
                                            unitName: nil,
                                            flags: [.flag_IsReadable, .flag_IsWritable],
                                            valueStrings: nil,
                                            dependentParameters: nil)
        parameter.value = 0.55
        return parameter
    }()
    
    static var stereoDelayMix: AUParameter = {
        let parameter =
            AUParameterTree.createParameter(withIdentifier: "kDelayMix",
                                            name: "Stereo Delay Mix",
                                            address: AUParameterAddress(kDelayMix),
                                            min: 0, max: 1,
                                            unit: .generic,
                                            unitName: nil,
                                            flags: [.flag_IsReadable, .flag_IsWritable],
                                            valueStrings: nil,
                                            dependentParameters: nil)
        parameter.value = 0.35
        return parameter
    }()
    
    static var stereoDelayModulationSpeed: AUParameter = {
        let parameter =
            AUParameterTree.createParameter(withIdentifier: "kDelayModulationSpeed",
                                            name: "Stereo Delay Modulation Speed",
                                            address: AUParameterAddress(kDelayModulationSpeed),
                                            min: 0.1, max: 10,
                                            unit: .hertz,
                                            unitName: "Hz",
                                            flags: [.flag_IsReadable, .flag_IsWritable],
                                            valueStrings: nil,
                                            dependentParameters: nil)
        parameter.value = 1.0
        return parameter
    }()
    
    static var stereoDelayModulationDepth: AUParameter = {
        let parameter =
            AUParameterTree.createParameter(withIdentifier: "kDelayModulationDepth",
                                            name: "Stereo Delay Modulation Depth",
                                            address: AUParameterAddress(kDelayModulationDepth),
                                            min: 0, max: 1,
                                            unit: .generic,
                                            unitName: nil,
                                            flags: [.flag_IsReadable, .flag_IsWritable],
                                            valueStrings: nil,
                                            dependentParameters: nil)
        parameter.value = 0.25
        return parameter
    }()
    
    // MARK: - Vibrato Parameters
    
    static var vibratoToggle: AUParameter = {
        let parameter =
            AUParameterTree.createParameter(withIdentifier: "kVibratoToggle",
                                            name: "Vibrato Toggle",
                                            address: AUParameterAddress(kVibratoToggle),
                                            min: 0, max: 1,
                                            unit: .boolean,
                                            unitName: nil,
                                            flags: [.flag_IsReadable, .flag_IsWritable],
                                            valueStrings: nil,
                                            dependentParameters: nil)
        parameter.value = 0
        return parameter
    }()
    
    static var vibratoSpeed: AUParameter = {
        let parameter =
            AUParameterTree.createParameter(withIdentifier: "kVibratoSpeed",
                                            name: "Vibrato Speed",
                                            address: AUParameterAddress(kVibratoSpeed),
                                            min: 0.1, max: 15,
                                            unit: .hertz,
                                            unitName: "Hz",
                                            flags: [.flag_IsReadable, .flag_IsWritable],
                                            valueStrings: nil,
                                            dependentParameters: nil)
        parameter.value = 0.65
        return parameter
    }()
    
    static var vibratoDepth: AUParameter = {
        let parameter =
            AUParameterTree.createParameter(withIdentifier: "kVibratoDepth",
                                            name: "Vibrato Depth",
                                            address: AUParameterAddress(kVibratoDepth),
                                            min: 0, max: 1,
                                            unit: .generic,
                                            unitName: nil,
                                            flags: [.flag_IsReadable, .flag_IsWritable],
                                            valueStrings: nil,
                                            dependentParameters: nil)
        parameter.value = 0.2
        return parameter
    }()
    
}

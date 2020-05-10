//  Assemble
//  ============================

import AudioUnit

@objc open class ASCommander : ASComponent, KeyboardListener, SequencerDelegate
{
    @objc public var commander: ASCommanderAU?

    public static var acd = AudioComponentDescription()

    @objc public override init()
    {
        ASCommander.acd.componentType = kAudioUnitType_Generator
        ASCommander.acd.componentSubType = FourCharCode("ASMB")
        ASCommander.acd.componentManufacturer = FourCharCode("DSPR")

        AUAudioUnit.registerSubclass(ASCommanderAU.self,
                                     as: ASCommander.acd,
                                     name: "Synthesiser",
                                     version: 1);

        super.init()
        
        AVAudioUnit.instantiate(with: ASCommander.acd, options: [])
        { (avAudioUnit, error) in
            guard let avAudioUnit = avAudioUnit else { fatalError() }
            
            self.unit = avAudioUnit
            self.node = avAudioUnit
            self.commander = avAudioUnit.auAudioUnit as? ASCommanderAU
            print("[Commander] AVAudioUnit Instantiated!")
        }
    }
    
    public var length: Int {
        return commander?.length ?? 0
    }
    
    public var currentRow: Int {
        return commander?.currentRow ?? 0
    }
    
    public var currentPattern: Int {
        return commander?.currentPattern ?? 0
    }
    
    public var ticking: Bool {
        guard let commander = commander else { return false }
        return commander.ticking
    }
    
    func setParameter(_ parameter: Int32, to value: Float) {
        commander?.setParameterWithAddress(AUParameterAddress(parameter), value: value)
    }
    
    func getParameter(_ parameter: Int32) -> Float {
        return commander?.parameter(withAddress: AUParameterAddress(parameter)) ?? 0.0
    }
    
    func setFilter(frequency value: Float, oscillator: OscillatorShape) {
        var parameter: AUParameterAddress
        switch oscillator
        {
        case .sine:     parameter = AUParameterAddress(kSinFilterFrequency); break
        case .triangle: parameter = AUParameterAddress(kTriFilterFrequency); break
        case .square:   parameter = AUParameterAddress(kSqrFilterFrequency); break
        case .sawtooth: parameter = AUParameterAddress(kSawFilterFrequency); break
        default: return
        }
        
        commander?.setParameterImmediatelyWithAddress(parameter, value: value)
    }
    
    func setFilter(resonance value: Float, oscillator: OscillatorShape) {
        var parameter: AUParameterAddress
        switch oscillator
        {
        case .sine:     parameter = AUParameterAddress(kSinFilterResonance); break
        case .triangle: parameter = AUParameterAddress(kTriFilterResonance); break
        case .square:   parameter = AUParameterAddress(kSqrFilterResonance); break
        case .sawtooth: parameter = AUParameterAddress(kSawFilterResonance); break
        default: return
        }
        
        commander?.setParameterImmediatelyWithAddress(parameter, value: value)
    }
    
    @discardableResult
    public func playOrPause() -> Bool
    {
        guard let commander = commander else { return false }
        
        return commander.playOrPause()
    }
    
    // MARK: - Sequencer Delegate
    
    func addOrModifyNote(xy: CGPoint, note: Int, shape: OscillatorShape) {
        guard let commander = commander else { return }
        commander.addNote(x: xy.nx, y: xy.ny, note: note, shape: shape.rawValue)
    }

    func eraseNote(xy: CGPoint) {
        guard let commander = commander else { return }
        commander.eraseNote(x: xy.nx, y: xy.ny)
    }

    // MARK: - Keyboard Listener
    
    func pressNote(_ note: Int, shape: OscillatorShape) {
        guard let commander = commander else { return }
        if !commander.ticking { commander.playNote(note: note, shape: shape.rawValue) }
     }
    
    func didToggleMode() {
        guard let commander = commander else { return }
        commander.toggleMode()
    }
}

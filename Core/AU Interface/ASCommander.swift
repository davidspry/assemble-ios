//  Assemble
//  ============================
//  Copyright © 2020 David Spry. All rights reserved.

import AudioUnit

@objc open class ASCommander : ASComponent, KeyboardListener, TransportListener
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
                                     name: "Assemble",
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
        get {
            guard let commander = commander else { return false }
            return    commander.ticking
        }
        
        set (shouldTick) {
            guard let commander = commander else { return }
            let ticking = commander.ticking
            if        shouldTick != ticking {
                      commander.playOrPause()
            }
        }
        
    }
    
    func setParameter(_ parameter: Int32, to value: Float) {
        let address = AUParameterAddress(parameter)
        let parameter = commander?.parameterTree?.parameter(withAddress: address)
        if let parameter = parameter { return parameter.value = value }
        commander?.setParameterWithAddress(address, value: value)
    }

    func getParameter(_ parameter: Int32) -> Float {
        return commander?.parameter(withAddress: AUParameterAddress(parameter)) ?? 0.0
    }

    @discardableResult
    public func playOrPause() -> Bool {
        guard let commander = commander else { return false }
        return commander.playOrPause()
    }

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
    
    // MARK: - Transport Listener

    func didToggleMode() {
        let mode = Int(getParameter(kSequencerMode))
        setParameter(kSequencerMode, to: Float((mode + 1) & 1))
    }
}

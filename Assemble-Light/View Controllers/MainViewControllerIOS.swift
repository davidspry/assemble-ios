//  Assemble
//  Created by David Spry on 26/7/20.
//  Copyright © 2020 David Spry. All rights reserved.

import UIKit

class MainViewControlleriOS: UIViewController, KeyboardSettingsListener {

    let engine = Engine()

    let modeStrings = ["PATTERN MODE", "SONG MODE"]
    
    /// The y-axis centre constraint of the SpriteKit sequencer.
    /// This is used to alter the position of sequencer to accommodate the on-screen keyboard
    /// on small device screens.

    @IBOutlet weak var sequencerCentreY: NSLayoutConstraint!

    private(set) var updater: CADisplayLink!

    /// Button stack outlets

    @IBOutlet weak var optionsButton: UIButton!
    
    /// Outlets

    @IBOutlet weak var mode:       UIButton!
    @IBOutlet weak var keyboard:   Keyboard!
    @IBOutlet weak var patterns:   PatternOverview!
    @IBOutlet weak var transport:  TransportiOS!
    @IBOutlet weak var sequencer:  Sequencer!
    @IBOutlet weak var tempoLabel: ParameterLabel!
    @IBOutlet weak var descriptionLabel: UILabel!

    /// Envelope settings
    
    var envelopePresets = [0, 0, 0, 0]

    /// The system's visual theme (light/dark)

    private lazy var systemTheme = traitCollection.userInterfaceStyle
    
    /// Indicate whether the theme is dark, `true`, or light, `false` from `UserDefaults`
    /// or by matching the system theme.

    var usingDarkTheme: Bool {
        set (isDarkTheme) {
            let key = UserDefaultsKeys.isDarkTheme
            let defaults = UserDefaults()
            defaults.set(isDarkTheme, forKey: key)
        }

        get {
            let key = UserDefaultsKeys.isDarkTheme
            let defaults = UserDefaults()
            if     let isDarkTheme = defaults.value(forKey: key) as? Bool {
                return isDarkTheme
            }   else {
                let usingDarkMode = systemTheme == .dark
                defaults.set(usingDarkMode, forKey: key)
                return usingDarkMode
            }
        }
    }
    
    /// Load the visual theme accessible from the `usingDarkTheme` property,
    /// and update the theme toggle button's icon to reflect the opposite theme.

    public func loadVisualTheme() {
        UIApplication.shared.windows.forEach({
            $0.overrideUserInterfaceStyle = usingDarkTheme ? .dark : .light
        })
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        unlockAssembleCore()
        connectListeners()
        establishDisplayLink()
        initialiseTempoLabel()
        loadVisualTheme()
        engine.start()

        descriptionLabel.text = nil
    }
    
    private func connectListeners() {
        keyboard.listeners.add(sequencer)
        keyboard.listeners.add(Assemble.core)

        transport.listeners.add(self)
        transport.listeners.add(keyboard)
    }
    
    private func initialiseTempoLabel() {
        tempoLabel.initialise(with: kClockBPM, increment: 1.0, and: .discreteFast)
    }

    private func establishDisplayLink() {
        updater = CADisplayLink(target: self, selector: #selector(refreshInterface))
        updater.add(to: .main, forMode: .default)
    }
    
    // MARK: - KeyboardSettingsListener
    
    func didToggleKeyboardDisplay(_ show: Bool) {
        let margin: CGFloat = 8
        let translation = -(keyboard.visibilityTranslation)
        let difference: CGFloat = keyboard.frame.minY - sequencer.frame.maxY
        
        var delta: CGFloat = 0
        if (difference + translation) < margin {
            delta = translation - (margin - difference)
        }

        DispatchQueue.main.async {
            if show { self.sequencerCentreY.constant = delta }
            else    { self.sequencerCentreY.constant = 0 }
            UIView.animate(withDuration: 0.15) {
                self.view.layoutIfNeeded()
            }
        }
    }

    // MARK: - Core-UI Synchronisation

    @objc func refreshInterface() {
        descriptionLabel.text = sequencer.UI.noteString
        descriptionLabel.isHidden = descriptionLabel.text == nil

        let isSongMode = Int(Assemble.core.getParameter(kSequencerMode))
        mode.setTitle(modeStrings[isSongMode & 1], for: .normal)

        sequencer.UI.patternDidChange(to: Assemble.core.currentPattern)
        patterns.setNeedsDisplay()

        let row = Assemble.core.currentRow
        sequencer.UI.row.moveTo(row: row)
    }

    private func unlockAssembleCore() {
        Assemble.core.setParameter(kIAPToggle001, to: 1)
    }

    @IBAction func didChangeMode(_ sender: UIButton) {
        Assemble.core.didToggleMode()
    }

    func didResetAllPatterns() {
           Assemble.core.commander?.clearAllPatterns()
        if Assemble.core.ticking { transport.pressPlayOrPause() }
        sequencer.initialiseFromUnderlyingState()
        patterns.loadStates()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        if segue.identifier == "optionsSegue" {
            guard let destination = segue.destination as? OptionsViewControlleriOS
            else { return }
            
            destination.delegate = self
        }
    }
}

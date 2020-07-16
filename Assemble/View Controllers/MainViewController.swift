//  Assemble
//  Created by David Spry on 10/3/20.
//  Copyright © 2020 David Spry. All rights reserved.

import UIKit
import AVFoundation

/// Target requirements
///     - iOS 13.4: Computer keyboard interface
///     - iOS 13.0: AudioUnit user presets

class MainViewController : UIViewController, KeyboardSettingsListener
{
    /// Assemble's audio engine, which wraps the underlying `AVAudioEngine`

    let engine = Engine()
    
    /// A `CADisplayLink` that periodically updates the UI

    private(set) var updater: CADisplayLink!
    
    /// The class responsible for recording audio and generating video media

    private(set) var recorder: MediaRecorder!
    
    /// A view controller that handles presses from an external computer keyboard

    let computerKeyboard = ComputerKeyboard()
    
    /// Strings representing the two modes of the Assemble sequencer.
    /// The mode button displays these strings to indicate the current mode.

    let modeStrings = ["PATTERN MODE", "SONG MODE"]

    /// The on-screen piano keyboard
    
    @IBOutlet weak var keyboard: Keyboard!
    
    /// The SpriteKit sequencer representation

    @IBOutlet weak var sequencer: Sequencer!
    
    /// The real-time audio visualisation view

    @IBOutlet weak var waveform: Waveform!
    
    /// An overview of the current sequence

    @IBOutlet weak var patterns: PatternOverview!
    
    /// The transport bar, including the oscillator selector, keyboard visibility toggle,
    /// play-pause button, and record button.

    @IBOutlet weak var transport: Transport!
    
    /// The y-axis centre constraint of the SpriteKit sequencer.
    /// This is used to alter the position of sequencer to accommodate the on-screen keyboard
    /// on small device screens.

    @IBOutlet weak var sequencerCentreY: NSLayoutConstraint!

    /// The label displaying the name of the current preset

    @IBOutlet weak var presetLabel: UILabel!
    
    /// A button allowing the user to switch between the light and dark visual themes

    @IBOutlet weak var themeButton: UIButton!
    
    /// A button that displays the current sequencer mode and allows the user to toggle between the modes.

    @IBOutlet weak var modeButton: UIButton!
    
    /// A `ParameterLabel` exposing the tempo of the underlying clock to user control

    @IBOutlet weak var tempoLabel: ParameterLabel!
    
    /// A description of the note underlying the user's cursor on the SpriteKit sequencer

    @IBOutlet weak var descriptionLabel: PaddedLabel!
    
    /// The button that opens the unlock screen, where Assemble's IAP can be purchased or restored.
    
    @IBOutlet weak var unlockButton: UIButton!
    
    /// The button that opens the unlocked features screen, which is available to owners of Assemble's IAP product.

    @IBOutlet weak var unlockedFeaturesButton: UIButton!
    
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

    private func loadVisualTheme() {
        let icon: UIImage?
        if usingDarkTheme { icon = UIImage.init(systemName: "sun.max.fill") }
        else              { icon = UIImage.init(systemName: "moon.fill") }
        
        themeButton.setImage(icon, for: .normal)
        UIApplication.shared.windows.forEach({
            $0.overrideUserInterfaceStyle = usingDarkTheme ? .dark : .light
        })
    }
    
    /// Toggle the visual theme between light and dark, and store the chosen theme in the `UserDefaults` structure.

    @IBAction func didSetTheme(_ sender: UIButton) {
        usingDarkTheme = usingDarkTheme ? false : true
        loadVisualTheme()
    }

    /// Connect classes and UI components together as listeners in order that
    /// user interaction and other signals can be propagated throughout the application interface

    private func connectListeners() {
        /// Connect listeners to the musical Keyboard component

        keyboard.listeners.add(sequencer)
        keyboard.listeners.add(Assemble.core)
        keyboard.settingsListeners.add(computerKeyboard)
        
        /// Connect listeners to the ComputerKeyboard interface

        computerKeyboard.listeners.add(sequencer)
        computerKeyboard.listeners.add(Assemble.core)
        computerKeyboard.settingsListeners.add(keyboard)
        computerKeyboard.settingsListeners.add(transport)
        computerKeyboard.transportListeners.add(transport)

        /// Connect listeners to the Transport component

        transport.listeners.add(self)
        transport.listeners.add(keyboard)
        transport.listeners.add(computerKeyboard)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        /// Define Assemble's main view controller as the presentation context.
        
        definesPresentationContext = true
        
        /// Determine whether the user owns Assemble's IAP and respond accordingly.
        
        unlockIfPurchaseVerified()
        
        /// Add the computer keyboard controller in the background
        /// such that it handles keyboard presses but doesn't handle taps.
        
        addInBackground(computerKeyboard)
        
        /// Initialise the visual theme and the theme toggle button from `UserDefaults`.
        /// By default, the theme matches the system.

        loadVisualTheme()
        
        /// Initialise the Recorded with a reference to the `AVAudioEngine`
        
        recorder = MediaRecorder(engine.engine)
        
        /// Initialise the tempo `ParameterLabel` with its parameter address and settings.
        
        tempoLabel.initialise(with: kClockBPM, increment: 1.0, and: .discreteFast)
        
        /// Establish the `CADisplayLink` that synchronises the UI with the given frequency

        establishDisplayLink(fps: nil)
        
        /// Establish delegate/listener relationships between classes who require it

        connectListeners()
        
        /// Register to receive notifications from the transport when audio recording should begin or end
        
        let selector = #selector(useRecorder(_:))
        NotificationCenter.default.addObserver(self, selector: selector, name: .beginRecording, object: nil)
        NotificationCenter.default.addObserver(self, selector: selector, name: .stopRecording,  object: nil)
        NotificationCenter.default.addObserver(self, selector: selector, name: .defineRecording, object: nil)

        /// Start the `AVAudioEngine`
        
        engine.start()
    }
    
    /// Establish a `CADisplayLink` for the purpose of updating the UI.
    /// - Note: If `nil` is passed as the value of `fps`, the default frequency (the refresh rate of the screen) will be used.
    /// - Parameter fps: The number of times the specified callback should be executed per second
    
    private func establishDisplayLink(fps: Int?) {
        let callback = #selector(refreshInterface)
        updater = CADisplayLink(target: self, selector: callback)
        updater.add(to: .main, forMode: .default)
        guard let fps = fps else { return }
        updater.preferredFramesPerSecond = fps
    }

    /// Use the `MediaRecorder` to either begin a new recording or end an ongoing recording.
    ///
    /// This function is a callback to be triggered by an `NSNotification`
    /// Specifically, the notifications that should call this function are:
    ///     `NSNotification.Name.defineRecording` to define the recording session,
    ///     `NSNotification.Name.beginRecording` to begin recording, and
    ///     `NSNotification.Name.stopRecording` to end a recording session.
    ///
    /// - Parameter notification: The notification that triggered the function call.

    @objc private func useRecorder(_ notification: NSNotification) {
        if recorder.recording {
            transport.setRecordButtonUsable(false)
            recorder.stop(didCompleteRecording(_:))
        }

        if notification.name == NSNotification.Name.defineRecording {
            performSegue(withIdentifier: "defineRecordingSegue", sender: nil)
        }

        else if notification.name == NSNotification.Name.beginRecording {
            guard let settings = notification.object as? VideoSettings else { return }

            recorder.setVideoMode(to: settings.mode)
            recorder.record(video: settings.video, mode: usingDarkTheme, visualisation: settings.type)
        }
    }

    /// Handle the result of a media recording from the `MediaRecorder`
    /// - Parameter file: The URL of the recorded audio or generated video, or `nil` if an error occurred.
    
    private func didCompleteRecording(_ file: URL?) {
        transport.setRecordButtonUsable(true)
        
        guard let url = file else {
            transport.didPressRecord(sender: transport.record)
            return
        }

        switch file?.pathExtension {
        case MediaUtilities.MediaType.video.rawValue:
             return performSegue(withIdentifier: "shareCardSegue", sender: url)
        case MediaUtilities.MediaType.audio.rawValue:
             return presentFile(url)
        default: print("[MediaUtilities] Unknown path extension.")
        }
    }
    
    /// Present an file to the user as an activity item in a `UIActivityViewController` rooted in the transport bar.
    /// - Parameter file: The URL of the file to present to the user

    private func presentFile(_ file: URL) {
        let rect = CGRect(x: transport.frame.midX, y: transport.frame.minY, width: 0, height: 0)
        let activity = UIActivityViewController(activityItems: [file], applicationActivities: nil)
        activity.popoverPresentationController?.sourceView = view
        activity.popoverPresentationController?.sourceRect = rect
        activity.popoverPresentationController?.permittedArrowDirections = .down
        activity.excludedActivityTypes =
        [
            .addToReadingList,
            .assignToContact,
            .markupAsPDF,
            .openInIBooks
        ]
        
        present(activity, animated: true, completion: nil)
    }
    
    /// Respond to the on-screen keyboard being shown or hidden
    ///
    /// In order that everything can fit on the smallest iPad screen sizes, the sequencer may
    /// need to move upwards to make space for the on-screen keyboard. There should be approximately
    /// 48 points of space between the bottom of the sequencer and the top of the keyboard.
    ///
    /// This function computes the amount of space between the keyboard and the sequencer and modifies
    /// the position of the sequencer such that there remains 48 points of space between the two elements.
    ///
    /// On large screens, such as the 12.9" iPad Pro, no translation of the sequencer's position is required.
    ///
    /// - Parameter show: An indicator as to whether or not the keyboard should be shown or hidden.

    func didToggleKeyboardDisplay(_ show: Bool) {
        let margin: CGFloat = 48
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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated);
        loadFactoryPresetsOnFirstUse()
        waveform.start()
    }
    
    // MARK: - UI-Core Interaction
    
    @IBAction func didChangeMode(_ sender: UIButton) {
        Assemble.core.didToggleMode()
    }

    // MARK: - State Save/Load Interface

    public func beginNewSong() {
        Assemble.core.commander?.loadInitialState()
        presetLabel.text = Assemble.core.commander?.currentPreset?.name
        if Assemble.core.ticking { transport.pressPlayOrPause() }
        updateUIFromState()
    }
    
    /// Load the user preset with the index `position` in the underlying `userPresets` array
    /// and subsequently update the UI to reflect it.

    public func loadState(_ position: Int) {
        if Assemble.core.ticking { transport.pressPlayOrPause() }
        Assemble.core.commander?.loadFromPreset(number: position)
        updateUIFromState()
    }

    /// Save the current preset with the given name
    /// - Parameter name: The desired name for the preset

    public func saveState(named name: String) {
        guard let preset = Assemble.core.commander?.currentPreset
        else { return print("[MainViewController] CurrentPreset is nil") }

        let renamed = name != preset.name
        if !renamed { Assemble.core.commander?.saveCurrentPreset() }
        else        { Assemble.core.commander?.renamePreset(preset, to: name) }
        presetLabel.text = name
    }

    /// Create a new preset with the given name and save the new preset.
    /// - Parameter name: The desired name for the preset.
    /// - Returns: `true` if the preset saved correctly; `false` otherwise.
    /// - Precondition: A preset with the number `-(K + 1)`, where `K` is the number of user presets, does not exist.

    @discardableResult
    public func copyState(named name: String) -> Bool {
        if let saved = Assemble.core.commander?.saveState(named: name) {
            if saved { presetLabel.text = name }
            return saved
        }

        return false
    }

    /// If the application is being loaded for the first time, load the factory presets, select the first one,
    /// and update the UI to reflect it.

    private func loadFactoryPresetsOnFirstUse() {
        let defaults = UserDefaults()
        let key = UserDefaultsKeys.isFirstLaunch
        if let isFirstLaunch = defaults.value(forKey: key) as? Bool,
             !(isFirstLaunch) {
            Assemble.core.commander?.loadFactoryPreset(number: 0)
            return
        }   else { defaults.setValue(false, forKey: key) }

        DispatchQueue.main.async {
            var count = Assemble.core.commander?.userPresets.count
            Assemble.core.commander?.copyFactoryPreset(number: 3, false)
            while count == Assemble.core.commander?.userPresets.count {
                Thread.sleep(forTimeInterval: 0.025)
            }

            count = Assemble.core.commander?.userPresets.count
            Assemble.core.commander?.copyFactoryPreset(number: 2, false)
            while count == Assemble.core.commander?.userPresets.count {
                Thread.sleep(forTimeInterval: 0.025)
            }
            
            Assemble.core.commander?.copyFactoryPreset(number: 1, true)
            self.presetLabel.text = Assemble.core.commander?.currentPreset?.name
            self.sequencer.initialiseFromUnderlyingState()
            self.patterns.loadStates()
            self.tempoLabel.reinitialise()
        }
    }
    
    /// Update all UI elements in order that they reflect the underlying state.
    
    private func updateUIFromState() {
        presetLabel.text = Assemble.core.commander?.currentPreset?.name
        sequencer.initialiseFromUnderlyingState()
        tempoLabel.reinitialise()
        patterns.loadStates()
    }
    
    // MARK: - IAP Verification
    
    /// Determine whether Assemble's limitations should be turned off by checking whether the user owns
    /// Assemble's in-app purchase.
    ///
    /// If the IAP has been purchased, then the value of the key `UserDefaultsKeys.iap` will be `true`.
    /// Otherwise, the value of the key will be `nil` (on first launch) or `false`.
    ///
    /// The `IAPVerifier` will asynchronously check with Apple's servers in case a refund (or some other change) has occurred.

    private func unlockIfPurchaseVerified() {
        let defaults = UserDefaults()
        let key = UserDefaultsKeys.iap
        if  let verified = defaults.value(forKey: key) as? Bool,
                verified == true {
            unlockButton.isHidden = true
            unlockedFeaturesButton.isHidden = false
            Assemble.core.setParameter(kIAPToggle001, to: 1)
            
        }
        
        Assemble.core.setParameter(kIAPToggle001, to: 1)
        unlockButton.isHidden = true
        unlockedFeaturesButton.isHidden = false

//        IAPVerifier.verifier.restorePurchases() { owned, identifier in
//            guard identifier == key else {
//                return print("[IAPVerifier] Received unknown identifier: \(identifier).")
//            }
//
//            defaults.set(owned, forKey: key)
//            unlockButton.isHidden = owned
//            unlockedFeaturesButton.isHidden = !(owned)
//            Assemble.core.setParameter(kIAPToggle001, to: owned ? 1 : 0)
//        }
    }
    
    // MARK: - Core-UI Synchronisation
    
    /// Refresh the UI in order to synchronise it with the underlying state.
    /// This is intended to be called continually at regular intervals.

    @objc func refreshInterface() {
        descriptionLabel.text = sequencer.UI.noteString
        descriptionLabel.isHidden = descriptionLabel.text == nil

        let mode = Int(Assemble.core.getParameter(kSequencerMode))
        modeButton.setTitle(modeStrings[mode & 1], for: .normal)

        sequencer.UI.patternDidChange(to: Assemble.core.currentPattern)
        patterns.setNeedsDisplay()

        let row = Assemble.core.currentRow
        sequencer.UI.row.moveTo(row: row)
    }
    
    // MARK: - Storyboard Navigation
    
    /// Prepare to perform a segue to some other `UIViewController`

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)

        presentedViewController?.dismiss(animated: true, completion: nil)

        if segue.identifier == "persistenceSegue" {
            guard let destination = segue.destination as? PersistenceViewController
            else { return }

            destination.delegate = self
        }
        
        else if segue.identifier == "saveCopySegue" {
            guard let destination = segue.destination as? SaveCopyViewController
            else { return }

            destination.delegate = self
        }
        
        else if segue.identifier == "newSongSegue" {
            guard let destination = segue.destination as? NewSongViewController
            else { return }

            destination.delegate = self
        }
        
        else if segue.identifier == "shareCardSegue" {
            guard let destination = segue.destination as? ShareCardViewController
            else { return }
            
            destination.file = sender as? URL
        }
    }
}

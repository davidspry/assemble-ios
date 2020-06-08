//  Assemble
//  Created by David Spry on 10/3/20.
//  Copyright © 2020 David Spry. All rights reserved.

import UIKit
import AVFoundation

class MainViewController : UIViewController
{
    let engine = Engine()
    var updater: CADisplayLink!
    var recorder: MediaRecorder!
    let computerKeyboard = ComputerKeyboard()
    
    let modeStrings = ["PATTERN MODE", "SONG MODE"]

    @IBOutlet weak var keyboard:  Keyboard!
    @IBOutlet weak var sequencer: Sequencer!
    @IBOutlet weak var waveform:  Waveform!
    @IBOutlet weak var patterns:  PatternOverview!
    @IBOutlet weak var transport: Transport!

    @IBOutlet weak var presetLabel: UILabel!
    @IBOutlet weak var modeButton: UIButton!
    @IBOutlet weak var tempoLabel: ParameterLabel!
    @IBOutlet weak var descriptionLabel: PaddedLabel!

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

        transport.listeners.add(keyboard)
        transport.listeners.add(computerKeyboard)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /// Add the computer keyboard controller in the background
        /// such that it handles keyboard presses but doesn't handle taps.
        
        addInBackground(computerKeyboard)
        
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
    /// - Note: This function is a callback to be triggered by an `NSNotification`
    /// - Parameter notification: The notification that triggered the function call.
    /// Specifically, the notifications that should call this function are:
    ///     `NSNotification.Name.beginRecording`, and;
    ///     `NSNotification.Name.stopRecording`

    @objc private func useRecorder(_ notification: NSNotification) {
        if recorder.recording {
            recorder.stop(didCompleteRecording(_:))
            transport.setRecordButtonUsable(false)
        }

        if notification.name == NSNotification.Name.beginRecording {
            recorder.record(video: true, visualisation: .lissajous)
        }
    }
    
    /// Handle the result of a media recording from the `MediaRecorder`
    /// - Parameter file: The URL of the recorded audio or generated video, or `nil` if an error occurred.
    
    private func didCompleteRecording(_ file: URL?) {
        guard let url = file else { return }
        let rect = CGRect(x: view.bounds.midX, y: transport.frame.minY, width: 0, height: 0)
        let activity = UIActivityViewController(activityItems: [url], applicationActivities: nil)
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
        transport.setRecordButtonUsable(true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated);
        loadFactoryPresetOnFirstUse()
        waveform.start()
    }
    
    // MARK: - UI-Core Interaction
    
    @IBAction func didChangeMode(_ sender: UIButton) {
        Assemble.core.didToggleMode()
    }

    // MARK: - Save/Load Facilitation

    public func beginNewSong() {
        if Assemble.core.ticking { transport.pressPlayOrPause() }
        Assemble.core.commander?.loadInitialState()
        presetLabel.text = Assemble.core.commander?.currentPreset?.name
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

    /// If the application is being loaded for the first time, load the factory preset and update
    /// the UI to reflect it.
    ///
    /// <TODO: Consider a welcome panel with a few tips on first launch>

    private func loadFactoryPresetOnFirstUse() {
        let defaults = UserDefaults()
        if let value = defaults.value(forKey: "FirstUse") as? Bool,
               value == false {
            return
        }   else { defaults.setValue(false, forKey: "FirstUse") }

        Assemble.core.commander?.loadFactoryPreset(number: 1)
        sequencer.initialiseFromUnderlyingState()
        patterns.loadStates()
        tempoLabel.reinitialise()
    }
    
    /// Update all UI elements in order that they reflect the underlying state.
    
    private func updateUIFromState() {
        presetLabel.text = Assemble.core.commander?.currentPreset?.name
        sequencer.initialiseFromUnderlyingState()
        tempoLabel.reinitialise()
        patterns.loadStates()
    }
    
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
        if segue.identifier == "persistenceSegue" {
            guard let destination = segue.destination as? PersistenceViewController
            else { return }

            destination.delegate = self
        }
        
        if segue.identifier == "saveCopySegue" {
            guard let destination = segue.destination as? SaveCopyViewController
            else { return }

            destination.delegate = self
        }
        
        if segue.identifier == "newSongSegue" {
            guard let destination = segue.destination as? NewSongViewController
            else { return }

            destination.delegate = self
        }
    }
}

//  Assemble
//  Created by David Spry on 24/6/20.
//  Copyright © 2020 David Spry. All rights reserved.

import UIKit

class DefineRecordingViewController: UIViewController {

    @IBOutlet weak var windowPanel: UIView!

    @IBOutlet weak var mediaTypeSelector: UISegmentedControl!

    @IBOutlet weak var waveform: UIButton!

    @IBOutlet weak var waveformLabel: UILabel!
    
    @IBOutlet weak var lissajous: UIButton!
    
    @IBOutlet weak var lissajousLabel: UILabel!
    
    private var visualisationButtonsActive: Bool = true

    private var visualisation: Visualisation = .lissajous {
        didSet {
            guard  visualisation != oldValue else { return }
            let target = visualisation == .waveform ? waveform : lissajous
            let button = visualisation == .waveform ? lissajous : waveform
            let transparent: CGColor  = UIColor.clear.cgColor
            let borderColor: CGColor? = UIColor.init(named: "Secondary")?.cgColor
            
            DispatchQueue.main.async {
                let appear = CABasicAnimation()
                    appear.duration  = 0.15
                    appear.fromValue = transparent
                    appear.toValue   = borderColor

                target?.layer.add(appear, forKey: "borderColor")
                target?.layer.borderColor = borderColor
                target?.layer.borderWidth = 1.5
                
                let disappear = CABasicAnimation()
                    disappear.duration  = 0.15
                    disappear.fromValue = borderColor
                    disappear.toValue   = transparent

                button?.layer.add(disappear, forKey: "borderColor")
                button?.layer.borderColor = transparent
                button?.layer.borderWidth = 1.5
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupMediaTypeSelector()
        visualisation = .waveform
        waveform.isPointerInteractionEnabled = true
        lissajous.isPointerInteractionEnabled = true

        let selector = #selector(didSelectMediaType)
        mediaTypeSelector.addTarget(self, action: selector, for: .valueChanged)
    }
    
    @IBAction private func selectWaveform(_ sender: UIButton) {
        visualisation = .waveform
    }
    
    @IBAction private func selectLissajous(_ sender: UIButton) {
        visualisation = .lissajous
    }
    
    /// Indicate whether the audio visualisation type buttons should be activate or not.
    /// - Parameter usable: A flag to indicate whether the visualisation buttons should be active or inactive.

    private func setVisualisationButtons(to usable: Bool) {
        if visualisationButtonsActive == usable { return }
        else { visualisationButtonsActive = usable }
        
        self.waveform.isUserInteractionEnabled  = usable
        self.lissajous.isUserInteractionEnabled = usable
        
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.35) {
                self.waveform.alpha       = usable ? 1.0 : 0.35
                self.waveformLabel.alpha  = usable ? 1.0 : 0.35
                self.lissajous.alpha      = usable ? 1.0 : 0.35
                self.lissajousLabel.alpha = usable ? 1.0 : 0.35
            }
            
        }
    }
    
    @objc private func didSelectMediaType(_ selector: UISegmentedControl) {
        switch selector.selectedSegmentIndex {
        case 0:    return setVisualisationButtons(to: false)
        case 1, 2: return setVisualisationButtons(to: true)
        default: print("[DefineRecordingViewController] Unknown media type segment index.")
        }
    }
    
    /// Dismiss the view controller if the user taps outside of the main window panel

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        guard let touch = touches.first else { return }
        let location = touch.location(in: windowPanel)
        let shouldDismiss = !(windowPanel.point(inside: location, with: nil))
        if  shouldDismiss {
            dismiss(animated: true, completion: nil)
        }
    }
    
    /// Notify the system that a new media recording session should begin using the user's selected settings, then dismiss the view controller.
    ///
    /// The settings are included in the notification as a `VideoSettings`, which is defined in `MediaUtilities`.
    /// - Parameter sender: The `UIButton` who called the method.

    @IBAction func didPressRecord(_ sender: UIButton) {
        let video = mediaTypeSelector.selectedSegmentIndex > 0
        let mode = mediaTypeSelector.selectedSegmentIndex == 1 ? VideoMode.square : VideoMode.portrait
        let settings: VideoSettings = (video: video, mode: mode, type: visualisation)
        NotificationCenter.default.post(name: .beginRecording, object: settings)
        dismiss(animated: true, completion: nil)
    }
    
    /// Dismiss the view controller if the user taps the return button

    @IBAction func didPressReturn(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    /// Dismiss the view controller if the user taps the close button

    @IBAction func didPressClose(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    /// Initialise the media type selector.
    /// The media type selector allows the user to select between audio, square video, and portrait video media.

    private func setupMediaTypeSelector() {
        setupMediaTypeSelectorFont()
        styleMediaTypeSelector()
    }
    
    /// Setup the media type selector's font

    private func setupMediaTypeSelectorFont() {
        let font = UIFont.init(name: "JetBrainsMono-Regular", size: 13)
        let secondaryColour = UIColor.init(named: "Secondary") ?? UIColor.lightText
        mediaTypeSelector.setTitleTextAttributes([.foregroundColor : UIColor.white],   for: .selected)
        mediaTypeSelector.setTitleTextAttributes([.foregroundColor : secondaryColour], for: .normal)
        mediaTypeSelector.setTitleTextAttributes([.foregroundColor : secondaryColour], for: .highlighted)
        mediaTypeSelector.setTitleTextAttributes([.font : font as Any], for: .normal)
        mediaTypeSelector.layoutIfNeeded()
    }
    
    /// Set the background colour and tint colour of the media type selector

    private func styleMediaTypeSelector() {
        mediaTypeSelector.masksToBounds = false
        mediaTypeSelector.backgroundColor = UIColor.clear
        mediaTypeSelector.selectedSegmentTintColor = UIColor.mutedOrange
        mediaTypeSelector.selectedSegmentIndex = 1
    }

}

//  Assemble
//  Created by David Spry on 17/6/20.
//  Copyright © 2020 David Spry. All rights reserved.

import UIKit

class HelpViewController: UIViewController {

    @IBOutlet weak var text: UILabel!

    @IBOutlet weak var windowContainer: UIStackView!

    @IBOutlet weak var interfaceType: UISegmentedControl!

    override func viewDidLoad() {
        super.viewDidLoad()
        text.textColor = UIColor.init(named: "Foreground")
        setupSegmentedControl()
        styleSegmentedControl()
        displayTouchText()
    }

    /// Setup the interface selector's font
    
    private func setupSegmentedControl() {
        let font = UIFont.init(name: "JetBrainsMono-Regular", size: 13)
        let secondaryColour = UIColor.init(named: "Secondary") ?? UIColor.lightText
        interfaceType.setTitleTextAttributes([.foregroundColor : UIColor.white],   for: .selected)
        interfaceType.setTitleTextAttributes([.foregroundColor : secondaryColour], for: .normal)
        interfaceType.setTitleTextAttributes([.foregroundColor : secondaryColour], for: .highlighted)
        interfaceType.setTitleTextAttributes([.font : font as Any], for: .normal)
        interfaceType.layoutIfNeeded()
    }
    
    /// Set the background colour and tint colour of the media type selector

    private func styleSegmentedControl() {
        interfaceType.masksToBounds = false
        interfaceType.backgroundColor = UIColor.clear
        interfaceType.selectedSegmentTintColor = UIColor.mutedOrange
        interfaceType.selectedSegmentIndex = 0
    }
    
    /// Dismiss the view controller if the user taps outside of the text panel

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        guard let touch = touches.first else { return }
        let location = touch.location(in: windowContainer)
        let shouldDismiss = !(windowContainer.point(inside: location, with: nil))
        if  shouldDismiss {
            dismiss(animated: true, completion: nil)
        }
    }
    
    /// Dismiss the view controller if the user taps the dismiss button
    
    @IBAction func didPressDismiss(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    /// Load and display the help text for the touch interface

    private func displayTouchText() {
        text.attributedText = touchText
    }
    
    /// A guide to using Assemble with a touch interface

    var touchText: NSAttributedString {
        let bold = [NSAttributedString.Key.font : UIFont.init(name: "JetBrainsMono-Medium",  size: 16)!]
        let body = [NSAttributedString.Key.font : UIFont.init(name: "JetBrainsMono-Regular", size: 14)!]
        let text = NSMutableAttributedString()
            text.append(NSAttributedString(string: "Usage overview\n\n", attributes: bold))

        let notesHead = "Placing and erasing notes\n\n"
        let notesBody =
        """
        To place a note on the sequencer, select a position on the grid by tapping it, then tap a key on the on-screen keyboard.

        To display the on-screen musical keyboard, select the circular button on the left side of the transport bar at the bottom of the screen.
        
        To select an oscillator for a new note, tap one of the oscillator names (SIN, TRI, SQR, or SAW) on the transport bar at the bottom of the screen. Each oscillator is associated with a colour. After selecting an oscillator, it will become highlighted with its corresponding colour.

        To erase an existing note, press its position on the sequencer until a delete button appears. Pressing the delete button will erase the note.
        \n\n
        """

        text.append(NSAttributedString(string: notesHead, attributes: bold))
        text.append(NSAttributedString(string: notesBody, attributes: body))
        
        let patternsHead = "Selecting, sequencing, and clearing patterns\n\n"
        let patternsBody =
        """
        Assemble's sequencer has two modes: PATTERN MODE, and SONG MODE. These modes are selectable by pressing the mode button, which is located in the top-left corner of the screen.

        A sequence is built from patterns. When the sequencer is using PATTERN MODE, the selected pattern will play repeatedly. When the sequencer is in SONG MODE, each active pattern will play sequentially.

        Each of the eight available patterns is represented by a cirular icon in the pattern overview, which is located in the bottom-right corner of the screen.

        To toggle the state of a pattern between active and inactive, double-tap its icon in the pattern overview. The sequence of patterns flows from left-to-right and from top-to-bottom. Active patterns have white icons, and inactive patterns have gray icons.

        To select a pattern for editing or playback, tap its icon in the pattern overview. If the sequencer is playing, then the newly selected pattern will be enqueued. Otherwise, the newly selected pattern will be displayed immediately. The icon of the currently selected pattern has a white border. The icon of an enqueued pattern has a pulsating white border.

        To clear a pattern, press upon its icon in the pattern overview until a delete button appears. Pressing the delete button will clear the pattern and deactivate it.
        \n\n
        """

        text.append(NSAttributedString(string: patternsHead, attributes: bold))
        text.append(NSAttributedString(string: patternsBody, attributes: body))
        
        let transportHead = "Play and pause, setting the tempo, and recording during playback\n\n"
        let transportBody =
        """
        The sequencer's play and pause control is accessible in the transport bar at the bottom of the screen.

        At any time, the sequencer's tempo can be changed by pressing and dragging the tempo display, which is located in the top-left corner of the screen. The tempo is given in beats per minute.
        \n\n
        """
        
        text.append(NSAttributedString(string: transportHead, attributes: bold))
        text.append(NSAttributedString(string: transportBody, attributes: body))
        
        let recordHead = "Recording during playback\n\n"
        let recordBody =
        """
        Assemble can record audio and optionally generate videos from audio recordings.

        To begin any recording session, press the red, circular button positioned next to the play-pause button on the transport bar. Define the desired recording settings in the window that subsequently appears, then press the RECORD button. Assemble will begin recording immediately and will continue to record until the transport bar's red, circular button is pressed again.

        Assemble encodes audio in real-time, but video generation is performed after the fact in the background. Generating video is a computationally intensive task and may take seconds to complete. While a video is being generated, the transport bar's red, circular button will be disabled.

        Square videos are 1080 pixels wide. Portrait videos are 1080 pixels wide and 1920 pixels high.

        Video files are saved automatically, with permission, to the photo library.
        \n\n
        """

        text.append(NSAttributedString(string: recordHead, attributes: bold))
        text.append(NSAttributedString(string: recordBody, attributes: body))
        
        let visualisationHead = "Visualising audio\n\n"
        let visualisationBody =
        """
        Assemble offers two real-time audio visualisations: a standard, waveform plot, and a Lissajous plot.

        To cycle between these visualisation modes during playback, tap the audio visualiser in the top-left corner of the screen.

        Either type of audio visualisation can be selected for a video generated from a recording session. The selection occurs on the BEGIN RECORDING window.
        """
        
        text.append(NSAttributedString(string: visualisationHead, attributes: bold))
        text.append(NSAttributedString(string: visualisationBody, attributes: body))
        
        let line = NSMutableParagraphStyle()
            line.lineSpacing = 8

        text.addAttribute(.paragraphStyle, value: line, range: NSRange(location: 0, length: text.length))
        
        return text
    }
    
    /// Load and display the help text for the computer keyboard interface

    private func displayKeyboardText() {
        text.attributedText = keyboardText
    }
    
    /// A guide to using Assemble with a computer keyboard interface

    var keyboardText: NSAttributedString {
        let bold = [NSAttributedString.Key.font : UIFont.init(name: "JetBrainsMono-Medium",  size: 16)!]
        let body = [NSAttributedString.Key.font : UIFont.init(name: "JetBrainsMono-Regular", size: 14)!]
        let text = NSMutableAttributedString()
            text.append(NSAttributedString(string: "Computer keyboard interface\n\n", attributes: bold))
        
        let basicHead = "Navigation\n\n"
        let basicBody =
        """
        arrows \t\t Navigate on the sequencer
        spacebar \t\t Play or pause the sequencer
        tab \t\t\t Toggle between SONG MODE and PATTERN MODE
        \n
        """
        
        text.append(NSAttributedString(string: basicHead, attributes: bold))
        text.append(NSAttributedString(string: basicBody, attributes: body))
        
        let placeHead = "Placing new notes on the sequencer\n\n"
        let placeBody =
        """
        a-g \t\t\t Place a natural note
        A-G \t\t\t Place a sharp note
        ⇧ + 1-7 \t\t Select an octave number between 1 and 7
        ⇧ + [, ] \t\t Select the next or previous oscillator
        \n
        """
        
        text.append(NSAttributedString(string: placeHead, attributes: bold))
        text.append(NSAttributedString(string: placeBody, attributes: body))
        
        let modifyHead = "Erasing from or modifying notes on the sequencer\n\n"
        let modifyBody =
        """
        a-g, A-G \t\t Modify the pitch of an existing note
        delete \t\t Erase an existing note
        1-7 \t\t\t Set the octave of an existing note
        [, ] \t\t\t Set the oscillator type of an existing note
        """
        
        text.append(NSAttributedString(string: modifyHead, attributes: bold))
        text.append(NSAttributedString(string: modifyBody, attributes: body))

        let line = NSMutableParagraphStyle()
            line.lineSpacing = 8

        text.addAttribute(.paragraphStyle, value: line, range: NSRange(location: 0, length: text.length))

        return text
    }
    
    @IBAction func valueSelected(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex
        {
        case 0: displayTouchText(); return
        case 1: displayKeyboardText(); return
        default: return
        }
        
    }
    
}

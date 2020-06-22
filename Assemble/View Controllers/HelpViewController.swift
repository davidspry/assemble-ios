//  Assemble
//  Created by David Spry on 17/6/20.
//  Copyright © 2020 David Spry. All rights reserved.

import UIKit

class HelpViewController: UIViewController {

    @IBOutlet weak var text: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        displayTouchText()
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        dismiss(animated: true, completion: nil)
    }
    
    private func displayTouchText() {
        text.text =
        """
        -----------------------
        NOTES: PLACING, ERASING
        -----------------------
        
        To display the on-screen musical keyboard, select the circular button on the left side of the transport bar at the bottom of the screen.
        
        To select an oscillator for a new note, tap one of the oscillator names -- SIN, TRI, SQR, SAW -- on the transport bar at the bottom of the screen. Each oscillator is associated with a colour. After selecting an oscillator, it will become highlighted with its corresponding colour.
        
        To place a note on the sequencer, select a position on the grid by tapping it, then tap a key on the on-screen keyboard.
        
        To erase an existing note, press its position on the sequencer until a delete button appears. Pressing the delete button will erase the note.
        
        -----------------------------------------------
        PATTERNS: SELECTION, STATE, ERASURE, SEQUENCING
        -----------------------------------------------

        Assemble's sequencer has two modes: PATTERN MODE, and SONG MODE. These modes are selectable by pressing the mode button, which is located in the top-left corner of the screen.
        
        A sequence is built from patterns. When the sequencer is using PATTERN MODE, the selected pattern will play repeatedly. When the sequencer is in SONG MODE, each active pattern will play sequentially.
        
        Each of the eight available patterns is represented by a cirular icon in the pattern overview, which is located in the bottom-right corner of the screen.
        
        To toggle the state of a pattern, double-tap the icon that represents it in the pattern overview. The sequence of patterns flows from left-to-right and from top-to-bottom. Active patterns have white icons, and inactive patterns have gray icons. The c

        The currently selected pattern is indicated by a white border. Any enqued patterns, which are selected during playback, are indicated by a pulsating white border.
        
        To clear a pattern, press the icon that represents the pattern in the pattern overview (in the bottom-right corner of the screen) until a delete button appears. Pressing the delete button will clear the pattern and deactivate it.
        
        -------------------------------------
        TRANSPORT: PLAY, PAUSE, TEMPO, RECORD
        -------------------------------------
        
        The play and pause control is accessible in the transport bar at the bottom of the screen.
        
        To change the tempo of the sequencer, tap and drag the tempo display in the top-left corner of the screen. The tempo is given in beats per minute.

        -------------
        VISUALISATION
        -------------
        """
    }
    
    private func displayKeyboardText() {
        text.text =
        """
        
        
        
        """
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

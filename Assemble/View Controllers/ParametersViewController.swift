//  ParametersViewController.swift
//  Assemble
//  Created by David Spry on 13/5/20.
//  Copyright © 2020 David Spry. All rights reserved.

import UIKit

class ParametersViewController: UIViewController {

    @IBOutlet weak var tableOscillators: UITableView!
    @IBOutlet weak var tableDelay: UITableView!
    @IBOutlet weak var tableVibrato: UITableView!
    
    internal let menuOscillators = OscillatorParameters()
    internal let menuDelay = StereoDelayParameters()
    internal let menuVibrato = VibratoParameters()

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        dismiss(animated: true, completion: nil)
    }
    
    @objc func didSelectOscillator(_ selector: OscillatorSelector) {
        print(selector.selectedSegmentIndex)
    }

    @objc func didToggle(_ button: UIButton) {
        switch (button.tag)
        {
        case 0x1: // Delay
            print("Delay toggle")
            break
        case 0x2: // Vibrato
            print("Vibrato toggle")
            break
        default: return
        }
    }
}

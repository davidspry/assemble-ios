//  Assemble
//  Created by David Spry on 13/5/20.
//  Copyright © 2020 David Spry. All rights reserved.

import UIKit

class ParametersViewController: UIViewController {

    @IBOutlet weak var tableOscillators: UITableView!
    @IBOutlet weak var tableDelay: UITableView!
    @IBOutlet weak var tableVibrato: UITableView!
    
    internal var menuOscillators = OscillatorParameters()
    internal var menuDelay = StereoDelayParameters()
    internal var menuVibrato = VibratoParameters()

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        dismiss(animated: true, completion: nil)
    }
    
    @objc func didSelectOscillator(_ selector: OscillatorSelector) {
        if let oscillator = OscillatorShape(rawValue: selector.selectedSegmentIndex) {
            menuOscillators.oscillator = oscillator
            tableOscillators.reloadData()
        } 
    }

    @objc func didToggle(_ button: UIButton) {
        switch (button.tag)
        {
        case 0x1:
            print("[ParametersViewController] Delay toggle")
            break
        case 0x2:
            print("[ParametersViewController] Vibrato toggle")
            break
        default: return
        }
    }
}

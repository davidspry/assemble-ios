//  Assemble
//  Created by David Spry on 21/5/20.
//  Copyright © 2020 David Spry. All rights reserved.

import UIKit

class PersistenceViewController: UIViewController {

    weak var delegate: MainViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        dismiss(animated: true, completion: nil)
    }

}

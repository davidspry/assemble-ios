//  Assemble
//  Created by David Spry on 18/5/20.
//  Copyright © 2020 David Spry. All rights reserved.

import Foundation

extension NSNotification.Name {
    
    static let playOrPause = NSNotification.Name(rawValue: "ASPlayOrPause")
    
    static let clearCurrentPattern = NSNotification.Name(rawValue: "ASClearCurrentPattern")

    static let beginRecording = NSNotification.Name(rawValue: "ASBeginRecording")
    
    static let stopRecording = NSNotification.Name(rawValue: "ASStopRecording")

}

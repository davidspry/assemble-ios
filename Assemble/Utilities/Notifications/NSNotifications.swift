//  Assemble
//  Created by David Spry on 18/5/20.
//  Copyright © 2020 David Spry. All rights reserved.

import Foundation

/// Notifications that can be broadcast to classes who register to observe them

extension NSNotification.Name {
    
    /// Play or pause the transport
    
    static let playOrPause = NSNotification.Name(rawValue: "ASPlayOrPause")
    
    /// Clear the pattern whose index is stored in the `NSNotification`'s `object` property

    static let clearPattern = NSNotification.Name(rawValue: "ASClearPattern")
    
    /// Update the representation pattern whose index is stored in the `NSNotification`'s `object` property

    static let updatePattern = NSNotification.Name(rawValue: "ASUpdatePattern")

    /// Define a recording session for the `MediaRecorder`
    
    static let defineRecording = NSNotification.Name(rawValue: "ASDefineRecording")
    
    /// Begin a recording session using the `MediaRecorder`
    
    static let beginRecording = NSNotification.Name(rawValue: "ASBeginRecording")
    
    /// Stop a recording session using the `MediaRecorder`

    static let stopRecording = NSNotification.Name(rawValue: "ASStopRecording")
    
    /// Update special user entitlements to reflect a change in the user's IAP ownership
    
    static let updateEntitlements = NSNotification.Name(rawValue: "ASUpdateEntitlements")

}

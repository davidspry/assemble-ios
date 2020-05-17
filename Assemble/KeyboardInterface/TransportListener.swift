//  Assemble
//  Created by David Spry on 14/5/20.
//  Copyright © 2020 David Spry. All rights reserved.

import Foundation

/// A class who conforms to `TransportListener` can receive
/// information or data about the state of the sequencer.

protocol TransportListener: AnyObject {
    
    /// Toggle the transport

    func pressPlayOrPause()
}

/**
 This extension provides default implementations for the TransportListener protocol,
 thereby relaxing the requirement for subclassers to implement each one.
*/

extension TransportListener {
    func pressPlayOrPause() {}
}

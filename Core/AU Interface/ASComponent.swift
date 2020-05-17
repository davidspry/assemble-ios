//  Assemble
//  ============================
//  Copyright © 2020 David Spry. All rights reserved.

import AVFoundation

@objc open class ASComponent : NSObject
{
    @objc open var node = AVAudioNode()
    @objc open var unit : AVAudioUnit?
}

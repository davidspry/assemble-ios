//  Assemble
//  ============================

import AVFoundation

@objc open class ASComponent : NSObject
{
    @objc open var node = AVAudioNode()
    @objc open var unit : AVAudioUnit?
}

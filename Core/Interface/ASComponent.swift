//  Assemble
//  ============================
//  Original author: Aurelius Prochazka.
//  Copyright 2018 AudioKit. All rights reserved.
//  License: <https://github.com/AudioKit/AudioKit/blob/master/LICENSE>

import AVFoundation

@objc open class ASComponent : NSObject
{
    @objc open var node = AVAudioNode()
    @objc open var unit : AVAudioUnit?
}

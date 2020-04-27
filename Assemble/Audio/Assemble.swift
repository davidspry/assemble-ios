//  Assemble
//  Created by David Spry on 1/4/20.
//  Copyright © 2020 David Spry. All rights reserved.

import UIKit
import AVFoundation

struct Assemble
{
    public static let core = ASCommander()
    
    public static var format: AVAudioFormat!
    
    public static var channelCount: UInt32 = 2;
    
    public static var sampleRate: Double = 48_000;
    
    public static let patternWidth : CGFloat = {
        return CGFloat(SEQUENCER_WIDTH)
    }()
    
    public static let patternHeight : CGFloat = {
        return CGFloat(Assemble.core.length)
    }()
    
    public static let shape : CGSize = {
        return CGSize(width: Int(SEQUENCER_WIDTH),
                      height: Assemble.core.length)
    }()
    
    public static var device: UIUserInterfaceIdiom {
        return UIDevice.current.userInterfaceIdiom
    }
}

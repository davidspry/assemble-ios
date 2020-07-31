//  Assemble
//  Created by David Spry on 1/4/20.
//  Copyright © 2020 David Spry. All rights reserved.

import UIKit
import AVFoundation

/// Assemble's core and important settings

struct Assemble
{
    /// A single instance of the underlying Assemble core

    public static let core = ASCommander()
    
    /// The audio format in use by the Assemble core
    
    public static var format: AVAudioFormat!
    
    /// The width of the sequencer in terms of dots on the grid

    public static let patternWidth : CGFloat = {
        return CGFloat(SEQUENCER_WIDTH)
    }()
    
    /// The height of the sequencer in terms of dots on the grid
    
    public static let patternHeight : CGFloat = {
        return CGFloat(Assemble.core.length)
    }()
    
    /// The shape, (height, width), of the sequencer, in terms of dots on the grid.

    public static let shape : CGSize = {
        return CGSize(width: Int(SEQUENCER_WIDTH),
                      height: Assemble.core.length)
    }()
    
    /// The `UIDevice` being used currently.

    public static var device: UIUserInterfaceIdiom {
        return UIDevice.current.userInterfaceIdiom
    }

}

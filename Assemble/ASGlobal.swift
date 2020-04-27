//
//  ASMSettings.swift
//  Assemble
//
//  Created by David Spry on 1/4/20.
//  Copyright © 2020 David Spry. All rights reserved.
//

import UIKit
import AVFoundation

struct Assemble
{
    public static var bpm : UInt = 120;
    
    public static var format: AVAudioFormat!
    
    public static var channelCount: UInt32 = 2;
    
    public static var sampleRate: Double = 48_000;
    
    public static let defaultPatternWidth : CGFloat = 16
    
    public static let defaultPatternHeight : CGFloat = 16
    
    public static var device: UIUserInterfaceIdiom {
        return UIDevice.current.userInterfaceIdiom
    }
}

//  Recorder.swift
//  Created by David Spry on 1/6/20.
//  Copyright © 2020 David Spry. All rights reserved.

import UIKit
import AVFoundation

/// Record audio from an `AVAudioEngine` into an `AVAudioFile`

class Recorder
{
    var recording = false
    
    private var file: AVAudioFile?
    
    private let _bufferSize: UInt32 = 1024

    private weak var engine: AVAudioEngine!
    
    private lazy var settings: [String:Any] =
    [
        AVFormatIDKey    : kAudioFormatMPEG4AAC,
        AVSampleRateKey  : Assemble.format.sampleRate,
        AVNumberOfChannelsKey : Assemble.format.channelCount
   ]

    init(_ engine: AVAudioEngine) {
        self.engine = engine
    }
    
    private func writeAudio(_ buffer: AVAudioPCMBuffer, _ time: AVAudioTime)
    {
        do    { try file?.write(from: buffer) }
        catch { print("[Recorder] AVAudioFile could not be written to.") }
    }
    
    public func record()
    {
        let path = Recorder.createNewFile()

        do    { self.file = try AVAudioFile(forWriting: path, settings: settings) }
        catch { print("[Recorder] AVAudioFile could not be created.") }

        engine.mainMixerNode.installTap(onBus: 0, bufferSize: _bufferSize,
                                        format: Assemble.format, block: writeAudio(_:_:))

        print("[Recorder] Recording started.")
        recording = true
    }
    
    public func stop(_ complete: @escaping (URL?) -> ())
    {
        recording = false
        engine.mainMixerNode.removeTap(onBus: 0)
        print("[Recorder] Recording stopped.")
        complete(file?.url)
    }

    private class func createNewFile() -> URL
    {
        guard let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        else { fatalError("[Recorder] FileManager returned empty URLs array.")}

        let timestamp = Int(Date().timeIntervalSince1970)
        let filename  = String(format: "Assemble_%d", timestamp)
        let filepath  = documents.appendingPathComponent(filename)
                                 .appendingPathExtension("aac")

        if FileManager.default.fileExists(atPath: filepath.absoluteString)
        {
            do    { try FileManager.default.removeItem(atPath: filepath.absoluteString) }
            catch { print("[Recorder] File exists but could not be removed.\n\(error)") }
        }

        print("[Recorder] New file created: \(filepath)")
        return filepath
    }

}

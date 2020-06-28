//  Assemble
//  Created by David Spry on 1/6/20.
//  Copyright © 2020 David Spry. All rights reserved.

import UIKit
import Accelerate
import AVFoundation

/// Record audio from an `AVAudioEngine` into an `AVAudioFile` and optionally generate a video from the audio at a user-specified size.

class MediaRecorder
{
    private(set) var recording = false
    
    private(set) var shouldGenerateVideo = false
    
    private(set) var visualTheme: UIUserInterfaceStyle = .dark
    
    private(set) var visualisation: Visualisation = .waveform
    
    private(set) var videoSize: (W: Int, H: Int) = (1080, 1080) {
        didSet {
            settings.video["AVVideoWidthKey"]  = videoSize.W
            settings.video["AVVideoHeightKey"] = videoSize.H
        }
    }

    private var file: AVAudioFile?

    private let _bufferSize: UInt32 = 1024

    private weak var engine: AVAudioEngine!
    
    private lazy var settings: (audio: [String:Any], video: [String:Any]) =
    (
        audio:
        [
            AVFormatIDKey    : kAudioFormatMPEG4AAC,
            AVSampleRateKey  : Assemble.format.sampleRate,
            AVNumberOfChannelsKey : min(Assemble.format.channelCount, 2)
        ],
        video:
        [
            AVVideoCodecKey  : AVVideoCodecType.h264,
            AVVideoWidthKey  : videoSize.W,
            AVVideoHeightKey : videoSize.H
        ]
    )

    init(_ engine: AVAudioEngine) {
        self.engine = engine
    }
    
    /// Write a buffer of audio data to the class's `AVAudioFile`.
    /// - Note: `.write(from:)` throws an error when the `AVAudioFile` and the
    /// `AVAudioPCMBuffer` have different formats, and `AVAudioFile` does not appear to be
    /// compatible with formats consisting in numbers of channels greater than 2, so recording
    /// does not work with audio interfaces whose `AVAudioFormat` uses more than 2 channels.

    private func writeAudio(_ buffer: AVAudioPCMBuffer, _ time: AVAudioTime)
    {
        do    { try file?.write(from: buffer) }
        catch {
            print("[Recorder] AVAudioFile could not be written to.")
            recordingDidFail()
        }
    }
    
    /// Set the video mode, which defines the size of the video.
    /// The available options are square video (1080 pixels) and portrait video (1080x1920 pixels).
    /// By default, square videos are generated.
    ///
    /// - Note: 1080x1920 is the recommended size for an Instagram story.
    /// - Parameter mode: A `VideoMode` constant that represents a video size and shape

    public func setVideoMode(to mode: VideoMode) {
        switch mode {
        case .square:   return videoSize = (1080, 1080)
        case .portrait: return videoSize = (1080, 1920)
        }
    }

    /// Begin recording media
    /// - Parameter video: A flag to indicate whether a video should be generated for the recording or not.
    /// - Parameter mode:  A flag to indicate whether the video should use the dark or light visual theme.
    /// - Parameter visualisation: The type of audio visualisation to use in the generated video
    
    public func record(video: Bool, mode isDarkMode: Bool, visualisation type: Visualisation = .waveform)
    {
        visualisation = type
        
        shouldGenerateVideo = video

        visualTheme = isDarkMode ? .dark : .light

        let path = MediaRecorder.createNewFile(extension: MediaUtilities.MediaType.audio.rawValue)

        do
        {
            self.file = try AVAudioFile(forWriting: path, settings: settings.audio,
                                        commonFormat: Assemble.format.commonFormat,
                                        interleaved:  Assemble.format.isInterleaved)
        }   catch { print("[Recorder] AVAudioFile could not be created.") }

        engine.mainMixerNode.installTap(onBus: 0, bufferSize: _bufferSize,
                                        format: nil, block: writeAudio(_:_:))
        
        print("[Recorder] Recording started.")
        recording = true
    }
    
    /// In the event that a recording fails, the `stopRecording` notification should be broadcast in order to trigger
    /// the series of functions that handles the end of a recording session.
    /// The class's `AVAudioFile` is set to nil before stopping the recording, which ensures that Assemble does
    /// not prevent an empty audio file to ths user.

    private func recordingDidFail()
    {
        if let file = file { MediaRecorder.deleteExistingFile(file.url) }
        shouldGenerateVideo = false
        file = nil

        NotificationCenter.default.post(name: NSNotification.Name.stopRecording, object: nil)
    }

    /// Stop recording media
    /// - Parameter complete: A method that should be called with the encoded media

    public func stop(_ complete: @escaping (URL?) -> ())
    {
        recording = false
        print("[Recorder] Recording stopped.")
        engine.mainMixerNode.removeTap(onBus: 0)
        guard let file = file else {
            print("[Recorder] File is nil on recording stop")
            return complete(nil)
        }
        
        if shouldGenerateVideo { generateVideo(for: file.url, then: complete) }
        else                   { complete(file.url) }
    }

    /// Create a new file with the given path extension in the user's documents directory
    /// - Parameter extension: The path extension for the file. e.g., "mp4", "mov".

    private class func createNewFile(extension pathExtension: String) -> URL
    {
        guard let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        else { fatalError("[Recorder] FileManager returned empty URLs array.")}

        let timestamp = Int(Date().timeIntervalSince1970)
        let filename  = String(format: "Assemble_%d", timestamp)
        let filepath  = documents.appendingPathComponent(filename)
                                 .appendingPathExtension(pathExtension)

        if FileManager.default.fileExists(atPath: filepath.absoluteString)
        {
            do    { try FileManager.default.removeItem(atPath: filepath.absoluteString) }
            catch { print("[Recorder] File exists but could not be removed.\n\(error)") }
        }

        print("[Recorder] New file created: \(filepath)")
        return filepath
    }
    
    /// Attempt to delete the file at the given URL
    /// - Parameter filepath: The URL of the file to be deleted
    
    private class func deleteExistingFile(_ filepath: URL) {
        DispatchQueue.main.async {
            var result = false

            if FileManager.default.isDeletableFile(atPath: filepath.path)
            {
                do    { try FileManager.default.removeItem(at: filepath); result = true }
                catch { print("[Recorder] File exists but could not be removed\n\(error)") }
            }   else  { print("[Recorder] File is not deleteable.") }
            
            if result { print("[Recorder] File was removed successfully") }
        }
    }

    /// Generate a video from the given audio file
    /// - Parameter audioFile: The URL of the audio file whose contents should be used to generate a video
    /// - Parameter complete:  A completion handler, which will be passed the video after a successful encode, or nil otherwise.

    private func generateVideo(for audioFile: URL, then complete: @escaping (URL?) -> ()) {
        var success = false
        
        let file: AVAudioFile!
        do    { try file = AVAudioFile(forReading: audioFile) }
        catch { return }
        
        let writer: AVAssetWriter!

        let framesPerSecond: Double = 24
        let audioLengthInSamples = file.length
        let videoLengthInFrames  = Int((Double(audioLengthInSamples) / file.fileFormat.sampleRate * framesPerSecond).rounded(.up))
        let frameLengthInSamples = Int((file.fileFormat.sampleRate / framesPerSecond).rounded(.up))
        let videoFrameDuration   = CMTime(seconds: 1, preferredTimescale: CMTimeScale(framesPerSecond))

        let filepath = MediaRecorder.createNewFile(extension: MediaUtilities.MediaType.video.rawValue)
        do    { writer = try AVAssetWriter(outputURL: filepath, fileType: .mp4) }
        catch { return }
        
        let W = videoSize.W
        let H = videoSize.H
        let video = AVAssetWriterInput(mediaType: .video, outputSettings: settings.video)
        let attributes : [String : Any] = [
            String(kCVPixelBufferPixelFormatTypeKey) : Int(kCVPixelFormatType_32ARGB),
            String(kCVPixelBufferWidthKey)  : W,
            String(kCVPixelBufferHeightKey) : H
        ]

        let adapter = AVAssetWriterInputPixelBufferAdaptor(assetWriterInput: video, sourcePixelBufferAttributes: attributes)

        writer.add(video)
        writer.startWriting()
        writer.startSession(atSourceTime: CMTime(seconds: 1, preferredTimescale: Int32(framesPerSecond)))

        var frame = 0
        var total = 0
        let queue = DispatchQueue(label: "assemble.video.queue", qos: .default)
        video.requestMediaDataWhenReady(on: queue, using: {
            if video.isReadyForMoreMediaData && frame < Int(videoLengthInFrames)
            {
                let lastFrameTime = CMTimeMake(value: Int64(frame), timescale: Int32(framesPerSecond))
                let presentationTime = frame == 0 ? lastFrameTime : CMTimeAdd(lastFrameTime, videoFrameDuration)
                let audioBufferPosition = frame * frameLengthInSamples

                let size  = CGSize(width: W, height: H)
                UITraitCollection.init(userInterfaceStyle: self.visualTheme).performAsCurrent {
                    let image = self.generateImage(size: size, audio: file, frame: audioBufferPosition)
                    if !self.appendPixelBuffer(image: image, adapter: adapter, time: presentationTime) {
                        print("[MediaRecorder] Failed to append pixel buffer to adapter for frame \(frame).")
                        return
                    }
                }

                frame = frame + 1
                let progress = Int(Float(frame) / Float(videoLengthInFrames) * 100)
                if  progress > total {
                    total = progress
                    print("[MediaRecorder] Progress: \(total)%")
                }
            }

            if (frame >= videoLengthInFrames) {
                video.markAsFinished()
                writer.finishWriting() {
                    success = writer.status == .completed && writer.error == nil
                    if success {
                        print("[Recorder] Video encoded successfully:\n\(filepath)")
                        self.merge(audio: file.url, video: filepath, then: complete)
                    }
                }
            }
        })
    }
    
    /// Generate an image for the given audio file at the given frame
    /// - Parameter size: The expected size for the image
    /// - Parameter file: The audio file who should be visualised
    /// - Parameter position: The current frame of the given audio file

    private func generateImage(size: CGSize, audio file: AVAudioFile, frame position: Int) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, true, 1)
        let context = UIGraphicsGetCurrentContext()
        let color: UIColor = UIColor.init(named: "Background") ?? .black
            color.setFill()
        let frame = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        context?.fill(frame)
        
        let step = 16
        let frames = AVAudioFrameCount(2048)
        var data   = [[Float]](repeating: [Float](repeating: 0.0, count: Int(frames / UInt32(step))), count: 2)
        if let format = AVAudioFormat(commonFormat: .pcmFormatFloat32,
                                   sampleRate:   file.fileFormat.sampleRate,
                                   channels:     file.fileFormat.channelCount,
                                   interleaved:  false)
        {
            if let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frames)
            {
                file.framePosition = AVAudioFramePosition(position)
                do    { try file.read(into: buffer, frameCount: frames) }
                catch { return UIImage(color: color, size: size) }

                if let floatBuffer = buffer.floatChannelData {
                    let L = 0, R = format.channelCount > 1 ? 1 : 0
                    for (i, block) in stride(from: 0, to: Int(frames), by: step).enumerated() {
                        vDSP_meanv(&floatBuffer[L][block], 1, &data[0][i], vDSP_Length(step))
                        vDSP_meanv(&floatBuffer[R][block], 1, &data[1][i], vDSP_Length(step))
                    }
                }
            }
        }

        drawAudio(from: data, in: context, with: size)

        guard let result = UIGraphicsGetImageFromCurrentImageContext()
        else { return UIImage(color: color, size: size) }
        UIGraphicsEndImageContext()
        return result
    }
    
    /// Visualise the given audio data in the given context
    /// - Parameter data: An array of audio samples
    /// - Parameter context: The context in which the visualisation should be drawn
    /// - Parameter size: The total available size for the visualisation

    private func drawAudio(from data: [[Float]], in context: CGContext?, with size: CGSize) {
        guard let context = context else { return }
        let primary: UIColor = UIColor.init(named: "Foreground") ?? .white
        let secondary: UIColor = primary.withAlphaComponent(0.25)

        context.setLineCap (.round)
        context.setLineJoin(.round)
        context.setStrokeColor(secondary.cgColor)
        context.setLineWidth(4.0)
        drawGrid(in: context, size: size)
        context.strokePath()
        
        context.beginPath()
        context.setLineWidth(2.0)
        context.setStrokeColor(primary.cgColor)
        if visualisation == .waveform {  drawWaveform(from: data, size: size, in: context) }
        else                          { drawLissajous(from: data, size: size, in: context) }
        context.strokePath()

        drawAssembleBadge(in: context, size: size)
    }
    
    /// Draw a dot grid in the given `CGContext`
    /// - Parameter context: The context in which the dot grid should be drawn
    /// - Parameter size: The total available size for the drawing
    
    private func drawGrid(in context: CGContext, size: CGSize) {
        let path = CGMutablePath()
        let width = min(size.height, size.width) * 0.6
        let delta = CGFloat((width / 18).rounded(.up))
        let m: CGPoint = CGPoint(x: (size.width - width) / 2.0, y: (size.height - width) / 2.0)

        for y in stride(from: 0, through: width, by: delta) {
            for x in stride(from: 0, through: width, by: delta) {
                let xy = CGPoint(x: m.x + x, y: m.y + y)
                path.move(to: xy)
                path.addArc(center: xy, radius: 1, startAngle: 0, endAngle: 0, clockwise: true)
            }
        }

        context.addPath(path)
    }
    
    /// Draw an Assemble badge in the given `CGContext`
    /// - Parameter context: The context in which the dot grid should be drawn
    /// - Parameter size: The total available size for the drawing

    private func drawAssembleBadge(in context: CGContext, size: CGSize) {
        let square: CGFloat = 70
        let margin: CGFloat = square / 2.0
        let xy = CGPoint(x: margin, y: size.height - square - margin)
        if let logo = UIImage.init(named: "AssembleBadge"), let image = logo.cgImage {
            let imageFrame = CGRect(x: xy.x, y: xy.y, width: square, height: square)
            context.draw(image, in: imageFrame)
        }
    }

    /// Draw a waveform visualisation in the given `CGContext`
    /// - Parameter data: A buffer of audio samples
    /// - Parameter size: The total available size for the visualisation
    /// - Parameter context: The context in which the visualisation should be drawn

    private func drawWaveform(from data: [[Float]], size: CGSize, in context: CGContext) {
        let gain:  CGFloat = 1.0
        let width: CGFloat = size.width * 0.5
        let delta: CGFloat = width / CGFloat(data[0].count)

        let m: CGPoint = CGPoint(x: size.width / 2.0, y: size.height / 2.0)
        var x: CGFloat = m.x - width / 2.0
        
        context.move(to: CGPoint(x: x, y: m.y + CGFloat(data[0][0] + data[1][0]) * m.y * gain))
        for i in 0 ..< data[0].count {
            let y = m.y + CGFloat(data[0][i] + data[1][i]) * m.y * gain
            context.addLine(to: CGPoint(x: x, y: y))
            x = x + delta
        }
    }
    
    /// Draw a Lissajous figure in the given `CGContext`
    /// - Parameter data: A buffer of audio samples
    /// - Parameter size: The total available size for the visualisation
    /// - Parameter context: The context in which the visualisation should be drawn

    private func drawLissajous(from data: [[Float]], size: CGSize, in context: CGContext) {
        let gain: CGFloat = 3.0
        let m = CGPoint(x: size.width / 2.0, y: size.height / 2.0)
        let x = m.x + CGFloat(data[0][0]) * m.y
        let y = m.y + CGFloat(data[1][0]) * m.y

        context.move(to: .init(x: x, y: y))
        for i in 0 ..< data[0].count {
            let x = m.x + CGFloat(data[0][i]) * m.y * gain
            let y = m.y + CGFloat(data[1][i]) * m.y * gain
            let point = CGPoint(x: x, y: y)
            context.addLine(to: point)
        }
    }
    
    /// Append the contents of the given image as a pixel buffer to the given pixel buffer adapter at the given presentation time.
    /// - Parameter image: The `UIImage` to be drawn to the buffer.
    /// - Parameter adapter: The pixel buffer adpater to which the contents of the given image should be appended.
    /// - Parameter time: The presentation time of the given image
    /// - Author: Amrit Tiwari <https://stackoverflow.com/a/40884021/9611538>

    private func appendPixelBuffer(image: UIImage, adapter: AVAssetWriterInputPixelBufferAdaptor, time: CMTime) -> Bool
    {
        var appended = false

        autoreleasepool
        {
            if  let bufferPool = adapter.pixelBufferPool {
                let bufferPointer = UnsafeMutablePointer<CVPixelBuffer?>.allocate(capacity: 1)

                defer {
                    bufferPointer.deinitialize(count: 1)
                    bufferPointer.deallocate()
                }

                let status: CVReturn = CVPixelBufferPoolCreatePixelBuffer(
                    kCFAllocatorDefault,
                    bufferPool,
                    bufferPointer
                )

                if let buffer = bufferPointer.pointee, status == 0 {
                    drawToBuffer(buffer, from: image)
                    appended = adapter.append(buffer, withPresentationTime: time)
                }
            }
        }

        return appended
    }
    
    /// Draw the contents of the given `UIImage` to the given `CVPixelBuffer`
    /// - Parameter buffer: The `CVPixelBuffer` to write to
    /// - Parameter image:  The `UIImage` to be drawn to the pixel buffer
    /// - Author: Amrit Tiwari <https://stackoverflow.com/a/40884021/9611538>

    private func drawToBuffer(_ buffer: CVPixelBuffer, from image: UIImage)
    {
        CVPixelBufferLockBaseAddress(buffer, CVPixelBufferLockFlags(rawValue: .zero))
        let W = Int(image.size.width), H = Int(image.size.height)

        let data = CVPixelBufferGetBaseAddress(buffer)
        let colourspace = CGColorSpaceCreateDeviceRGB()
        let context = CGContext(data: data, width: W, height: H, bitsPerComponent: 8,
                                bytesPerRow: CVPixelBufferGetBytesPerRow(buffer),
                                space: colourspace, bitmapInfo: CGImageAlphaInfo.premultipliedFirst.rawValue)

        context?.draw(image.cgImage!, in: CGRect(x: 0, y: 0, width: CGFloat(W), height: CGFloat(H)))
        CVPixelBufferUnlockBaseAddress(buffer, CVPixelBufferLockFlags(rawValue: .zero))
    }

    /// Merge the contents of an audio file and a video file together, then encode the result in a new MP4 file.
    /// - Note: If the merge is successful, the original video file will be deleted.
    /// - Parameter audio: The URL of the audio file to use
    /// - Parameter video: The URL of the video file to use
    /// - Parameter complete: A completion handler, which will be passed the result of this method.

    private func merge(audio: URL, video: URL, then complete: @escaping (URL?) -> ()) {
        let composition = AVMutableComposition()
        let videoTrack = composition.addMutableTrack(withMediaType: .video, preferredTrackID: kCMPersistentTrackID_Invalid)
        let audioTrack = composition.addMutableTrack(withMediaType: .audio, preferredTrackID: kCMPersistentTrackID_Invalid)
        
        let video = AVURLAsset(url: video)
        let audio = AVURLAsset(url: audio)
        guard video.isExportable, let videoAsset = video.tracks(withMediaType: .video).first else { return }
        guard audio.isExportable, let audioAsset = audio.tracks(withMediaType: .audio).first else { return }

        let videoRange = CMTimeRangeMake(start: CMTime.zero, duration: video.duration)
        let audioRange = CMTimeRangeMake(start: CMTime.zero, duration: audio.duration)
        
        do  {
            try videoTrack?.insertTimeRange(videoRange, of: videoAsset, at: CMTime.zero)
            try audioTrack?.insertTimeRange(audioRange, of: audioAsset, at: CMTime.zero)
        }   catch { print(error); return }

        let export = AVAssetExportSession(asset: composition, presetName: AVAssetExportPresetHighestQuality)
        export?.shouldOptimizeForNetworkUse = true
        export?.outputFileType = AVFileType.mp4
        export?.outputURL = MediaRecorder.createNewFile(extension: MediaUtilities.MediaType.video.rawValue)
        export?.timeRange = CMTimeRangeMake(start: CMTime.zero, duration: video.duration)

        export?.exportAsynchronously {
            if export?.status == .completed {
                guard let url = export?.outputURL else { return }
                print("[Recorder] A/V merge completed:\n\(url)")
                MediaRecorder.deleteExistingFile(video.url)
                DispatchQueue.main.async {
                    complete(url)
                }
            }
            
            if export?.status == .failed {
                guard let error = export?.error else { return }
                print("[Recorder] A/V merge failed:\n\(error)")
                DispatchQueue.main.async {
                    complete(audio.url)
                }
            }
        }
    }
}

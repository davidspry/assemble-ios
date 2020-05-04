//  Assemble
//  Created by David Spry on 28/4/20.
//  Copyright © 2020 David Spry. All rights reserved.

import UIKit
import Accelerate

/// Display modes for the Waveform audio visualiser

enum Visualisation {
    case waveform
    case lissajous
}

/// A UIView subclass that visualises audio in real-time using different display modes.

class Waveform: UIView {

    /// The display mode of the Waveform view

    public var mode: Visualisation = .waveform

    private var updater: CADisplayLink!
    private var waveform = CAShapeLayer()
    
    /**
     `r`, `w` represent indices that define where data should be written to and read from.
     `n` is a flag representing the presence of new data to be read.

     In order to avoid a data race, the real-time thread should not write to the memory that the UI thread is reading from.

     There are two "channels" of data for each of the stereo output channels in `ldata` and `rdata`.

     When the UI thread needs new data, it performs an atomic XOR operation:
     `r = r ^ n`
     `w = w ^ n`

     If `n` has been set, the read/write indices will swap. Otherwise, they'll remain the same until
     the write stage has completed and new data is present to be written.
     
     - SeeAlso: "Double Buffering" https://www.youtube.com/watch?v=ndeN983j_GQ
     */

    private var r: UInt32 = 1
    private var w: UInt32 = 0
    private var n: UInt32 = 0
    private var ldata = [UnsafeMutablePointer<Float>]()
    private var rdata = [UnsafeMutablePointer<Float>]()
    
    /// The frameLength property of the buffer from the tap requires initialisation before use.
    /// A buffer size that's within the bounds of the frameCapacity must be set.

    private var bufferSize : Int32!
    private let _bufferSize: UInt32 = 1024
    private let points     : Int = 64

    /// In order to produce `points` samples from a
    /// buffer size of `_bufferSize`, the buffer is
    /// divided into `points` subarrays, each with this length.
    /// The arithmetic mean is computed for each subarray.
    /// `step` is used to define the stride size for the function
    /// that computes the mean.

    lazy private var step: Int = {
        return Int(bufferSize) / points
    }()
    
    /// The distance to travel along the x-axis in order that
    /// `points` points fit the width of the bounds.

    lazy private var delta: CGFloat = {
        return bounds.width / CGFloat(points)
    }()

    /// A scalar to adjust the scale of the visualisation

    private var gain: CGFloat = 0.85

    /**
     Install a tap on the output bus of the Assemble core in order to access the sample data.

     Samples from the Assemble core are copied to a block of memory reserved for `points` samples.
     The samples are accumulated from the tap in buffer sizes of `bufferSize`, but only `points` values are produced. Each of these values is the arithmetic mean of some sub-sequence of `step` samples.

     For example, `points[k]` is the average of the samples in `floatBuffer[0][k ..< k + step]`.

     `vDSP_meanv` is from the `Accelerate` framework, which leverages the hardware's capacity for vectorisation in order to perform tasks like this efficiently.

     After copying the data into the appropriate channel in `data`, set `n`to `1`, which signals that new data is available for the UI thread to read from.

     - Note: This tap should be removed in `deinit`.
    */

    private func installTap() {
        Assemble.core.unit?.installTap(onBus: 0, bufferSize: _bufferSize, format: Assemble.format, block: { buffer, time in
            buffer.frameLength = self._bufferSize
            if let floatBuffer = buffer.floatChannelData {
                let w = Int(self.w)
                for (i, block) in stride(from: 0, to: Int(self.bufferSize), by: self.step).enumerated() {
                    vDSP_meanv(&floatBuffer[0][block], 1, &self.ldata[w][i], vDSP_Length(self.step))
                    vDSP_meanv(&floatBuffer[1][block], 1, &self.rdata[w][i], vDSP_Length(self.step))
                    OSAtomicOr32(1, &self.n)
                }
                return
            }
            
            else {
                print("[Waveform] Error! Could not read Assemble buffer.")
                return
            }
        })
    }
    
    /// Redraw the waveform. This should be called by a CADisplayLink with a suitable high refresh rate.

    @objc private func redraw() {
        setNeedsDisplay()
    }
    
    /// Toggle the display modes of the Waveform visualiser

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        mode = mode == .waveform ? .lissajous : .waveform
    }
    
    
    /// Plot the sample data across the width of the bounds.
    /// The scale in the y-direction is set by the `gain` property.
    /// - Parameter path: The path that should contain the visualisation.

    private func drawWaveform(on path: inout CGMutablePath) {
        var x: CGFloat = 0
        let r: Int = Int(self.r)
        path.move(to: CGPoint(x: 0, y: bounds.midY + CGFloat(ldata[r][0]) * bounds.midY * self.gain))
        for i in 0 ..< points {
            let y = bounds.midY + CGFloat(ldata[r][i]) * bounds.midY * self.gain
            path.addLine(to: CGPoint(x: x, y: y))
            x = x + delta
        }
    }

    /// Plot the sample data as a Lissajous visualisation, where the x coordinate is determined by the left audio channel
    /// and the y coordinate is determined by the right audio channel.
    /// - Parameter path: The path that should contain the visualisation.

    private func drawLissajous(on path: inout CGMutablePath) {
        let r: Int = Int(self.r)
        let x = bounds.midX + CGFloat(ldata[r][0]) * bounds.midY * self.gain
        let y = bounds.midY + CGFloat(rdata[r][0]) * bounds.midY * self.gain
        path.move(to: CGPoint(x: x, y: y))
        for i in 0 ..< points {
            let x = bounds.midX + CGFloat(ldata[r][i]) * bounds.midY * self.gain
            let y = bounds.midY + CGFloat(rdata[r][i]) * bounds.midY * self.gain
            let point = CGPoint(x: x, y: y)
            path.addLine(to: point)
        }
    }

    /// Render the visualisation to the screen.
    /// If new data has been written from the buffer when the draw method begins, which should be true invariably given the disparity between the read and write speeds, then the read and write channels should be switched in order to read the newest sample data from the tap.
    /// Set `n` to `0` to indicate that the newest data has been accessed. `n` will be set to `1` again during next write operation.
    /// - Note: `draw(_ rect:)` must be overridden in order to perform any custom drawing.

    override func draw(_ rect: CGRect) {}
    override func draw(_ layer: CALayer, in ctx: CGContext)
    {
        OSAtomicXor32(n, &w)
        OSAtomicXor32(n, &r)
        OSAtomicAnd32(0, &n)

        var path = CGMutablePath()
        
        switch (mode)
        {
        case .waveform:  drawWaveform(on:  &path); break
        case .lissajous: drawLissajous(on: &path); break
        }

        CATransaction.begin()
        CATransaction.setDisableActions(true)
        waveform.path = path
        CATransaction.commit()
    }

    /// Install an audio tap on the Assemble core and begin to visualise the sample data

    public func start() {
        installTap()
    }

    required init?(coder: NSCoder) {
        bufferSize = Int32(_bufferSize)

        super.init(coder: coder)
        
        updater = CADisplayLink(target: self, selector: #selector(redraw))
        updater.add(to: .main, forMode: .default)

        ldata.reserveCapacity(2)
        rdata.reserveCapacity(2)
        ldata.append(UnsafeMutablePointer<Float>.allocate(capacity: points))
        ldata.append(UnsafeMutablePointer<Float>.allocate(capacity: points))
        rdata.append(UnsafeMutablePointer<Float>.allocate(capacity: points))
        rdata.append(UnsafeMutablePointer<Float>.allocate(capacity: points))
        ldata[0].assign(repeating: 0.0, count: points)
        ldata[1].assign(repeating: 0.0, count: points)
        rdata[0].assign(repeating: 0.0, count: points)
        rdata[1].assign(repeating: 0.0, count: points)

        waveform.lineWidth = 1.5
        waveform.lineCap = .round
        waveform.lineJoin = .round
        waveform.fillColor = UIColor.clear.cgColor
        waveform.strokeColor = UIColor.white.cgColor

        layer.addSublayer(waveform)
    }
    
    deinit
    {
        Assemble.core.unit?.removeTap(onBus: 0)
    }
}

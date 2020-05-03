//  Assemble
//  Created by David Spry on 28/4/20.
//  Copyright © 2020 David Spry. All rights reserved.

import UIKit
import Accelerate

class Waveform: UIView {

    private var updater: CADisplayLink!
    private var waveform = CAShapeLayer()
    
    /**
     "Double Buffering"
     
     `r`, `w` represent indices that define where data should be written to and read from.
     `n` is a flag representing the presence of new data to be read.

     There are two "channels" of data in `data`. In order to avoid a data-race, the real-time thread
     should not write to the memory that the UI thread is reading from.

     When the non-real-time thread needs new data, it performs an atomic XOR operation:
     `r = r ^ n`
     `w = w ^ n`
     
     If `n` has been set, the read/write indices will swap. Otherwise, they'll remain the same until
     the write stage has completed and new data is present to be written.
     */

    private var r: UInt32 = 1
    private var w: UInt32 = 0
    private var n: UInt32 = 0
    private var data = [UnsafeMutablePointer<Float>]()
    
    private var bufferSize : Int32!
    private let _bufferSize: UInt32 = 1024
    
    private var gain  : CGFloat = 15
    private let points: Int = 32

    lazy private var step: Int = {
        return Int(bufferSize) / points
    }()
    
    lazy private var delta: CGFloat = {
        return bounds.width / CGFloat(points)
    }()

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
                    vDSP_meanv(&floatBuffer[0][block], 1, &self.data[w][i], vDSP_Length(self.step))
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
    
    @objc private func redraw() {
        setNeedsDisplay()
    }

    /// Render the waveform data to the screen.
    /// If new data has been written from the buffer when the draw method begins, which should be true invariably given the disparity between the read and write speeds, then the read and write channels should be switched in order to read the newest sample data from the tap.
    /// Set `n` to `0` to indicate that the newest data has been accessed. `n` will be set to `1` again during next write operation.
    /// - Note: `draw(_ rect:)` must be overridden in order to perform any custom drawing.

    override func draw(_ rect: CGRect) {}
    override func draw(_ layer: CALayer, in ctx: CGContext)
    {
        OSAtomicXor32(n, &w)
        OSAtomicXor32(n, &r)
        OSAtomicAnd32(0, &n)

        var x: CGFloat = 0
        let r: Int = Int(self.r)
        let path = CGMutablePath()
        path.move(to: CGPoint(x: 0, y: bounds.midY + CGFloat(data[r][0]) * bounds.midY * self.gain))
        for i in 0 ..< points {
            let y = bounds.midY + CGFloat(data[r][i]) * bounds.midY * self.gain
            path.addLine(to: CGPoint(x: x, y: y))
            x = x + delta
        }

        CATransaction.begin()
        CATransaction.setDisableActions(true)
        waveform.path = path
        CATransaction.commit()
    }

    public func start() {
        installTap()
    }
    
    required init?(coder: NSCoder) {
        bufferSize = Int32(_bufferSize)

        super.init(coder: coder)
        
        updater = CADisplayLink(target: self, selector: #selector(redraw))
        updater.add(to: .main, forMode: .default)

        data.reserveCapacity(2)
        data.append(UnsafeMutablePointer<Float>.allocate(capacity: points))
        data.append(UnsafeMutablePointer<Float>.allocate(capacity: points))
        data[0].assign(repeating: 0.0, count: points)
        data[1].assign(repeating: 0.0, count: points)

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

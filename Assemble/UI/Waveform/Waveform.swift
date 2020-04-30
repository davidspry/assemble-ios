//  Assemble
//  Created by David Spry on 28/4/20.
//  Copyright © 2020 David Spry. All rights reserved.

import UIKit
import Accelerate

class Waveform: UIView {

    private var updater: CADisplayLink!

    private var waveform = CAShapeLayer()
    
    private var data: UnsafeMutablePointer<Float>!

    private var bufferSize: Int32!
    
    private let _bufferSize: UInt32 = 1024
    
    private var gain: CGFloat = 15
    
    private let points: Int = 32
    
    lazy private var step: Int = {
        return Int(bufferSize) / points
    }()
    
    lazy private var delta: CGFloat = {
        return bounds.width / CGFloat(points)
    }()

    /**
     Install a tap on the output bus of the Assemble core in order to access the sample data.

     The samples from the Assemble core are copied to a block of memory reserved for `points` contiguous samples, which is pointed to by `data`.
     The samples are accumulated from the tap in buffer sizes of `bufferSize`, but only `points` values are produced. The values that are produced are the arithmetic mean of each subsequence of `step` samples from the tap. For example, `points[k]` is the average of the samples in `floatBuffer[0][k ..< k + step]`.
     
     `vDSP_meanv` is from the `Accelerate` framework, which leverages the hardware's capacity for vectorisation in order to perform tasks like this efficiently.

     - Note: The tap should be removed upon `deinit`.
    */

    private func installTap() {
        Assemble.core.unit?.installTap(onBus: 0, bufferSize: _bufferSize, format: Assemble.format, block: { buffer, time in
            buffer.frameLength = self._bufferSize
            if let floatBuffer = buffer.floatChannelData {
                for (i, block) in stride(from: 0, to: Int(self.bufferSize), by: self.step).enumerated() {
                    vDSP_meanv(&floatBuffer[0][block], 1, &self.data[i], vDSP_Length(self.step))
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

    override func draw(_ rect: CGRect) {}
    override func draw(_ layer: CALayer, in ctx: CGContext) {
        let path = CGMutablePath()
        
        var x: CGFloat = 0
        path.move(to: CGPoint(x: 0, y: bounds.midY + CGFloat(data[0]) * bounds.midY * self.gain))
        for i in 0 ..< points {
            let y = bounds.midY + CGFloat(data[i]) * bounds.midY * self.gain
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

        data = UnsafeMutablePointer<Float>.allocate(capacity: points)
        data.assign(repeating: 0, count: points)

        waveform.lineWidth = 1.25
        waveform.lineCap = .round
        waveform.lineJoin = .round
        waveform.fillColor = UIColor.clear.cgColor
        waveform.strokeColor = UIColor.white.cgColor

        layer.addSublayer(waveform)
    }
    
    deinit {
        Assemble.core.unit?.removeTap(onBus: 0)
    }

}

/**
 Bubble waveform type:
 
     let m = CGFloat(abs(data[i]))
     if u {
     let y = bounds.midY + m * bounds.midY * self.gain
     path.addLine(to: CGPoint(x: x, y: y))
     path.addArc(center: CGPoint(x: x + delta / 2, y: y), radius: delta / 2,
                 startAngle: CGFloat.pi, endAngle: 0, clockwise: true)
     
     }
     else {
     let y = bounds.midY - m * bounds.midY * self.gain
     path.addLine(to: CGPoint(x: x, y: y))
     path.addArc(center: CGPoint(x: x + delta / 2, y: y), radius: delta / 2,
                 startAngle: CGFloat.pi, endAngle: 0, clockwise: false)
     }

     u = !u
 
 */

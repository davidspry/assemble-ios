//  Assemble
//  Created by David Spry on 28/4/20.
//  Copyright © 2020 David Spry. All rights reserved.

import UIKit
import Accelerate

class Waveform: UIView {

    private var data: UnsafeMutablePointer<Float>!
    private var waveform = CAShapeLayer()
    private var bufferSize: Int!
    private let _bufferSize: UInt32 = 1024
    
    private let step: Int = 32
    private var gain: CGFloat = 20
    lazy private var delta: CGFloat = {
        return bounds.width / (CGFloat(bufferSize!) / CGFloat(self.step))
    }()

    private func installTap() {
        Assemble.core.unit?.installTap(onBus: 0, bufferSize: _bufferSize, format: Assemble.format, block: { buffer, time in
            /**
             From Apple's documentation:
             "By default, the frameLength property is not initialized to a useful value; you must set this property before using the buffer. The length must be less than or equal to the frameCapacity of the buffer."
             */
            buffer.frameLength = self._bufferSize
            guard let floatBuffer = buffer.floatChannelData else {
                print("[Waveform] Error! Could not read Assemble buffer.")
                return
            }
            
            self.push(from: floatBuffer)
        })
    }
    
    private func push(from buffer: UnsafePointer<UnsafeMutablePointer<Float>>) {
        cblas_scopy(Int32(bufferSize), buffer[1], 1, data, 1)
    }
    
    override func draw(_ rect: CGRect) {}
    override func draw(_ layer: CALayer, in ctx: CGContext) {
        let path = CGMutablePath()

        var x: CGFloat = 0
        path.move(to: CGPoint(x: 0, y: bounds.midY))
        for i in stride(from: 0, to: bufferSize, by: step) {
            path.addLine(to: CGPoint(x: x, y: bounds.midY + CGFloat(data[i]) * bounds.midY * self.gain))
            x = x + delta
        }

        waveform.path = path
    }
    
    public func start() {
        installTap()
    }
    
    required init?(coder: NSCoder) {
        bufferSize = Int(_bufferSize)
        super.init(coder: coder)
        backgroundColor = .green
        data = UnsafeMutablePointer<Float>.allocate(capacity: bufferSize)
        data.assign(repeating: 0, count: bufferSize)

        waveform.lineWidth = 3.0
        waveform.strokeColor = UIColor.white.cgColor
        layer.addSublayer(waveform)
    }
    
    deinit {
        Assemble.core.unit?.removeTap(onBus: 0)
    }

}

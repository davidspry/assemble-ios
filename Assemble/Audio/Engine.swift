//  Assemble
//  Created by David Spry on 10/3/20.
//  Copyright © 2020 David Spry. All rights reserved.

import AVFoundation

class Engine
{
    private let engine = AVAudioEngine()

    init() {
        Assemble.sampleRate = engine.outputNode.outputFormat(forBus: 0).sampleRate;
        Assemble.format = engine.outputNode.outputFormat(forBus: 0);
        Assemble.channelCount = Assemble.format.channelCount;
    }
    
    func start() {
        engine.prepare();
        do    { try engine.start(); }
        catch { print("The engine could not be started: \(error)"); }
    }

    func stop() {
        engine.stop();
    }

    func connect(_ unit: ASComponent) {
        engine.attach(unit.node)
        engine.connect(unit.node, to: engine.mainMixerNode, format: Assemble.format)
    }
}

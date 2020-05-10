//  Assemble
//  Created by David Spry on 10/3/20.
//  Copyright © 2020 David Spry. All rights reserved.

import AVFoundation

class Engine
{
    private let engine = AVAudioEngine()

    /// Initialise the underlying AVAudioEngine and capture the format for global access.

    init() {
        Assemble.format = engine.outputNode.outputFormat(forBus: 0);
        connect(Assemble.core)

        let route = AVAudioSession.routeChangeNotification
        let callback: Selector = #selector(audioRouteDidChange(_:))
        let configuration: NSNotification.Name = .AVAudioEngineConfigurationChange
        NotificationCenter.default.removeObserver(self, name: route, object: nil)
        NotificationCenter.default.removeObserver(self, name: configuration, object: nil)
        NotificationCenter.default.addObserver(self, selector: callback, name: route, object: nil)
        NotificationCenter.default.addObserver(self, selector: callback, name: configuration, object: nil)
    }

    func start() {
        engine.prepare()
        do    { try engine.start() }
        catch { print("The engine could not be started: \(error)") }
    }

    func stop() {
        engine.stop();
    }

    func connect(_ unit: ASComponent) {
        engine.attach(unit.node)
        engine.connect(unit.node, to: engine.mainMixerNode, format: Assemble.format)
        engine.connect(engine.mainMixerNode, to: engine.outputNode, format: Assemble.format)
    }

    /// In the event that the audio output device is changed, the AVAudioEngine needs to be restarted.
    /// The new audio format is subsequently propagated to the underlying AudioUnit.

    @objc private func tryEngineRestart() {
        stop()
        start()
        Assemble.format = engine.outputNode.outputFormat(forBus: 0)
    }

    /// This function is called when either the `AVAudioSession.routeChangeNotification`
    /// or `.AVAudioEngineConfigurationChange` notifications are broadcast, such as when
    /// the a new audio output device is used.
    ///
    /// - Note: `NSNotifications` are not necessarily broadcast on the main thread. In the case
    /// where a notification arrives from another thread, respond by executing subsequent actions on the
    /// main thread explicitly.

    @objc private func audioRouteDidChange(_ notification: NSNotification) {
        if Thread.isMainThread { tryEngineRestart() }
        else { DispatchQueue.main.async(execute: tryEngineRestart) }
    }
    
}

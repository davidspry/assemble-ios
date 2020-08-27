//  Assemble
//  Created by David Spry on 30/4/20.
//  Copyright © 2020 David Spry. All rights reserved.

import UIKit

class PatternOverview: UIView, UIGestureRecognizerDelegate, TransportListener {

    private let activeColour    : UIColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
    private let patternOnColour : UIColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
    private let patternOffColour: UIColor = #colorLiteral(red: 0.2156862745, green: 0.2156862745, blue: 0.2156862745, alpha: 1)

    private var lastTappedNode: Int?
    private var lastTappedTime: TimeInterval?
    private var tapSpeedThreshold: TimeInterval = 0.3
    private var nodeDestination: Int?

    private var patternOptions = PatternOptions()
    private var lastSelectedPattern: Int?
    private let longPressRecogniser = UILongPressGestureRecognizer()

    private var states = [Bool]()
    private var shapes = [CAShapeLayer]()
    private let patterns = Int(PATTERNS)
    
    /// The index of the node representing the current pattern.

    internal var pattern : Int = 0 {
        willSet (newPattern) {
            shapes[pattern].strokeColor = nil
            shapes[newPattern].strokeColor = activeColour.cgColor
            shapes[newPattern].removeAllAnimations()
        }
        
        didSet { Assemble.core.setParameter(kSequencerCurrentPattern, to: Float(pattern)) }
    }

    /// The index of the node representing the next pattern.

    internal var nextPattern : Int = 0 {
        willSet (newPattern) {
            if newPattern == pattern {
                dequeue(&shapes[nextPattern])
                pattern = newPattern
                return
            }
            if nextPattern != pattern { dequeue(&shapes[nextPattern]) }
            enqueue(&shapes[newPattern])
        }
        
        didSet { Assemble.core.setParameter(kSequencerNextPattern, to: Float(nextPattern)) }
    }

    private let scalar = CGFloat(0.55)
    lazy private var rows = max(1, CGFloat(patterns / 4))
    lazy private var cols = CGFloat(patterns / Int(rows))
    lazy private var radius = min(0.5 * bounds.height / rows, 0.5 * bounds.width / cols)
    lazy private var diameter = radius * 2
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        isMultipleTouchEnabled = false
        shapes.reserveCapacity(patterns)
        states.reserveCapacity(patterns)

        establishClearPatternView()
        longPressRecogniser.delegate = self
        longPressRecogniser.minimumPressDuration  = 0.3
        longPressRecogniser.numberOfTouchesRequired = 1
        longPressRecogniser.cancelsTouchesInView = true
        longPressRecogniser.addTarget(self, action: #selector(handleLongPress(_:)))
        addGestureRecognizer(longPressRecogniser)

        let callbackPlayPause = #selector(handlePlayPauseNotification)
        NotificationCenter.default.addObserver(self, selector: callbackPlayPause, name: .playOrPause, object: nil)

        initialisePatternShapes()
        loadStates()
    }
    
    private func initialisePatternShapes() {
        for r in stride(from: 0, to: rows, by: 1) {
            for c in stride(from: 0, to: cols, by: 1) {
                let path  = UIBezierPath()
                let layer = CAShapeLayer()
                
                let x = c * diameter + radius
                let y = r * diameter + radius
                path.addArc(withCentre: CGPoint(x: x, y: y), radius: radius * scalar)

                layer.path = path.cgPath
                layer.lineWidth = 3.0
                layer.strokeColor = nil
                layer.shouldRasterize = true
                layer.allowsEdgeAntialiasing = true
                layer.rasterizationScale = 2.0 * UIScreen.main.scale
                layer.fillColor = patternOffColour.cgColor

                self.layer.insertSublayer(layer, below: patternOptions.layer)
                shapes.append(layer)
                states.append(false)
            }
        }
    }
    
    /// Poll the core for the state of each pattern. This should be called whenever a song is loaded.

    public func loadStates() {
        DispatchQueue.main.async {
            self.hidePatternOptionsView()
            for pattern in 0 ..< self.patterns {
                Assemble.core.setParameter(kSequencerCurrentPattern, to: Float(pattern))
                let state = Bool(Int(Assemble.core.getParameter(kSequencerPatternState)))
                self.set(pattern: pattern, to: state)
            }

            self.reset()
        }
    }
    
    /// Set the current pattern index to 0 in the core and update the UI accordingly.

    public func reset() {
        let pattern = Assemble.core.getParameter(kSequencerFirstActive)
        Assemble.core.setParameter(kSequencerCurrentPattern, to: pattern)
        self.pattern = Int(pattern)
    }

    /// Toggle the state of a `Pattern` and update its icon.
    /// - Parameter pattern: The index of the `Pattern` whose state should be toggled, starting from `0`.

    public func toggle(pattern: Int) {
        guard pattern > -1 && pattern < patterns else { return }
        let state = !states[pattern]
        set(pattern: pattern, to: state)
        Assemble.core.setParameter(kSequencerPatternState, to: Float(pattern))
    }

    /// Set the state of a `Pattern` icon.
    ///
    /// Setting the state of a `Pattern` in the Swift context obviates the need to regularly poll the C++ context
    /// for the state of each `Pattern`.
    ///
    /// - Parameter pattern: The index of the `Pattern` whose state should be set, starting from `0`.
    /// - Parameter state: The desired state to set.

    private func set(pattern: Int, to state: Bool) {
        guard pattern > -1 && pattern < patterns else { return }
        states[pattern] = state
        shapes[pattern].fillColor = state ? patternOnColour.cgColor :
                                            patternOffColour.cgColor
    }
    
    /// Perform an animation to signify a queued pattern on the given `CAShapeLayer`.
    ///
    /// When a pattern is enqueued, its icon should pulsate until it becomes the current pattern.
    /// This animation can be removed in `dequeue(_: inout CAShapeLayer)`.
    ///
    /// - Parameter layer: The `CAShapeLayer` to perform the animation upon.

    private func enqueue(_ layer: inout CAShapeLayer) {
        let animation = CABasicAnimation()
            animation.fromValue = 0.0
            animation.toValue   = 3.0
            animation.duration  = 0.35
            animation.autoreverses = true
            animation.repeatCount  = .greatestFiniteMagnitude
        
        layer.add(animation, forKey: "lineWidth")
        layer.strokeColor = activeColour.cgColor
    }
    
    /// Remove all animations from the given `CAShapeLayer` and reset its stroke colour to `nil`.
    ///
    /// This method exists to turn off the animations set in `enqueue(_: inout CAShapeLayer)`.
    ///
    /// - Parameter layer: The `CAShapeLayer` whose animations should be removed.
    
    private func dequeue(_ layer: inout CAShapeLayer) {
        layer.removeAllAnimations()
        layer.strokeColor = nil
    }
    
    internal func locationFromNodeIndex(_ node: Int) -> CGPoint? {
        if node < 0 || node > patterns { return nil }

        let r = CGFloat(node / Int(cols))
        let c = CGFloat(node % Int(cols))
        
        let x = c * diameter + radius
        let y = r * diameter + radius

        return CGPoint(x: x, y: y)
    }
    
    internal func nodeFromTouchLocation(_ touch: CGPoint) -> Int? {
        if touch.x > diameter * (cols + 1) { return nil }
        if touch.y > diameter * (rows + 1) { return nil }
        
        let y = Int(touch.y / diameter)
        let x = Int(touch.x / diameter)
        
        return y * Int(cols) + x
    }

    /// Handle a tap on the given node.
    ///
    /// If another tap has occurred on the same node within the `tapSpeedThreshold`,
    /// a double-tap is assumed and any enqueued single taps are precluded by setting `nodeDestination` equal to `nil`.
    /// Otherwise, a single-tap is enqueued.
    ///
    /// - Parameter node: The index of the pattern node that was pressed

    private func handleTap(on node: Int) {
        if node == lastTappedNode, let time = lastTappedTime,
            (ProcessInfo.processInfo.systemUptime - time) < tapSpeedThreshold {
            toggle(pattern: node)
            lastTappedNode = nil
            nodeDestination = nil
        }
        
        else {
            lastTappedNode = node
            nodeDestination = node
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(200)) {
                guard let node = self.nodeDestination else { return }
                if Assemble.core.ticking { self.nextPattern = node }
                else                     { self.pattern = node     }
            }
        }

        lastTappedTime = ProcessInfo.processInfo.systemUptime
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        guard let node = nodeFromTouchLocation(touch.location(in: self)) else { return }
        guard node > -1 && node < patterns else { return }
        hidePatternOptionsView()
        handleTap(on: node)
    }
    
    public func redrawIfNeeded() {
        let currentPattern = Assemble.core.currentPattern
        if pattern != currentPattern {
            pattern = currentPattern
            setNeedsDisplay()
        }
    }

    override func draw(_ rect: CGRect) {}
    override func draw(_ layer: CALayer, in ctx: CGContext) {}
    
    /// When a play/pause notification is received, unify the current pattern and the next pattern.
    ///
    /// This prevents the pulsating next pattern animation from persisting after playback has been stopped,
    /// and it resets the pattern queue when playback begins.
    ///
    /// - Parameter notification: The `NSNotification` that has been received.

    @objc func handlePlayPauseNotification(_ notification: NSNotification) {
        pattern = Int(Assemble.core.getParameter(kSequencerCurrentPattern))
        if nextPattern != pattern {
            dequeue(&shapes[nextPattern])
            nextPattern = pattern
        }
    }

    /// Handle a long press on the given node
    ///
    /// If a long press occurs on a node, the user is presented with an option to clear the corresponding pattern.
    /// In the event that the pattern should be cleared, a notification is broadcast to the sequencer and the core.
    ///
    /// - Parameter gesture: The gesture recogniser that detected the long press
    
    @objc func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
        if gesture.state != .began { return }
        let location   = gesture.location(in: self)
        guard self.bounds.contains(location) else { return }
        guard let node = nodeFromTouchLocation(location) else { return }
        guard let xy   = locationFromNodeIndex(node)     else { return }
        let roomAbove  = convert(xy, to: UIScreen.main.coordinateSpace).y > 85
        let dy         = 2 + radius + patternOptions.bounds.midY

        nextPattern = pattern
        lastSelectedPattern = node
        patternOptions.center.x = xy.x
        patternOptions.center.y = xy.y + (roomAbove ? -dy : dy)
        showPatternOptionsView()
    }

    @objc func didClearPattern(_ sender: UIButton) {
        guard let pattern = lastSelectedPattern else { return }
        NotificationCenter.default.post(name: .clearPattern, object: pattern)
        Assemble.core.commander?.clearPatternWithIndex(pattern)
        set(pattern: pattern, to: false)
        hidePatternOptionsView()
    }
    
    // MARK: - PatternOptions View
    
    private func establishClearPatternView() {
        patternOptions.initialise()
        patternOptions.delegate = self
        patternOptions.isHidden = true
        addSubview(patternOptions)
        bringSubviewToFront(patternOptions)
    }

    func showPatternOptionsView() {
        DispatchQueue.main.async {
            self.patternOptions.isHidden = false
            self.patternOptions.scaleBy(x: 0.1, y: 0.1)
            self.setPatternBrightnessForSelection()
            UIView.animate(withDuration: 0.1) {
                self.patternOptions.scaleBy(x: 1.0, y: 1.0)
            }
        }
    }

    func hidePatternOptionsView() {
        DispatchQueue.main.async {
            self.patternOptions.reset()
            self.restorePatternBrightnessAfterSelection()
            UIView.animate(withDuration: 0.1) {
                self.patternOptions.scaleBy(x: 0.1, y: 0.1)
                self.patternOptions.isHidden = true
            }
        }
    }
    
    private func setPatternBrightnessForSelection() {
        let isDarkMode = self.traitCollection.userInterfaceStyle == .dark

        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.2) {
                CATransaction.begin()
                for i in 0 ..< self.shapes.count {
                    let selected = i == self.lastSelectedPattern
                    if      selected   { self.shapes[i].fillColor = self.activeColour.cgColor  }
                    else if isDarkMode { self.shapes[i].opacity = self.states[i] ? 0.25 : 0.50 }
                    else               { self.shapes[i].opacity = self.states[i] ? 0.75 : 0.25 }
                }
                CATransaction.commit()
            }
        }
    }
    
    private func restorePatternBrightnessAfterSelection() {
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.2) {
                CATransaction.begin()
                for i in 0 ..< self.shapes.count {
                    self.shapes[i].opacity = 1.0
                    self.shapes[i].fillColor = self.states[i] ? self.patternOnColour.cgColor :
                                                                self.patternOffColour.cgColor
                }
                CATransaction.commit()
            }
        }
    }
    
    // MARK: - PatternOptions Delegation
    
    /// Instruct the core to copy the state of the last selected Pattern.

    internal func initiateCopy() {
        guard let pattern = lastSelectedPattern else { return }
        Assemble.core.commander?.copyPatternWithIndex(pattern)
        hidePatternOptionsView()
    }
    
    /// Instruct the core to paste a previously copied Pattern state into the last selected Pattern,
    /// then post a notification in order that the `SKSequencer` synchronises with the core.

    internal func initiatePaste() {
        guard let pattern = lastSelectedPattern else { return }
        Assemble.core.commander?.pasteIntoPatternWithIndex(pattern)
        NotificationCenter.default.post(name: .updatePattern, object: pattern)
        hidePatternOptionsView()
    }
    
    // MARK: - UITraitCollection update callback
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if !patternOptions.isHidden { setPatternBrightnessForSelection() }
    }

    // MARK: - UIGestureRecogniser delegate
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive event: UIEvent) -> Bool {
        if !patternOptions.isHidden,
            let touch = event.allTouches?.first,
            patternOptions.point(inside: touch.location(in: patternOptions), with: nil) {
            return false
        }
        
        return true
    }
    
    // MARK: - HitTest

    /// Include subviews who fall outside the bounds of the view in the hit test. In Assemble,
    /// this allows the clear pattern icon to be pressed if it happens to appear outside the bounds of the
    /// pattern overview's `UIView`.
    ///
    /// - Author: Noam
    /// - Note: Source: <https://stackoverflow.com/a/14875673/9611538>

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView?
    {
        guard !clipsToBounds && !isHidden && alpha > 0 else { return nil }

        for member in subviews.reversed() {
            let subPoint = member.convert(point, from: self)
            guard let result = member.hitTest(subPoint, with: event) else { continue }
            return result
        }

        hidePatternOptionsView()
        return super.hitTest(point, with: event)
    }
}

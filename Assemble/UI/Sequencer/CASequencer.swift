//  Assemble
//  ============================
//  Created by David Spry on 24/8/20.
//  Copyright © 2020 David Spry. All rights reserved.

import UIKit

class CASequencer: CAGrid, KeyboardListener, UIGestureRecognizerDelegate {
    
    /// The index of the sequencer's current pattern

    internal var pattern: Int = 0

    /// A string describing the note underlying the user's cursor

    var noteString: String?
    
    /// Strings describing each note of the sequence
    
    internal var noteStrings = [[[String?]]]()
    
    /// Layers representing each note node, organised by pattern.

    internal var noteShapeLayers = [[CANoteNode]]()
    
    /// The location of the note that the user has elected to erase

    internal var noteToErase: CGPoint?

    /// A button used by the user to erase notes from the sequencer

    internal lazy var eraseButtonView = UIView()

    /// The gesture used to move and display the `eraseButtonView`

    internal let longPressRecogniser = UILongPressGestureRecognizer()
    
    // MARK: - Initialisation

    override init(frame: CGRect) {
        super.init(frame: frame)
        initialise()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        initialise()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        addSubviewToFront(eraseButtonView)
    }
    
    /// Prepare the sequencer for use by initialising its gesture recogniser, note-erase button, and notification callbacks.

    internal func initialise() {
        initialiseDataStructures()
        initialiseEraseButtonView()
        initialiseLongPressRecogniser()

        /// Register to receive notifications when the user elects to clear or update a pattern's representation.

        let nc = NotificationCenter.default
        nc.addObserver(self, selector: #selector(clearPattern),  name: .clearPattern,  object: nil)
        nc.addObserver(self, selector: #selector(updatePattern), name: .updatePattern, object: nil)
    }
    
    private func initialiseDataStructures() {
        let patterns = Int(PATTERNS)
        let W = Int(SEQUENCER_WIDTH)
        let H = Assemble.core.length
        let empty: [String?] = Array.init(repeating: nil, count: W)

        self.noteStrings.reserveCapacity(patterns)
        self.noteStrings.append(contentsOf: Array.init(repeating: [], count: patterns))

        self.noteShapeLayers.reserveCapacity(patterns)
        self.noteShapeLayers.append(contentsOf: Array.init(repeating: [], count: patterns))

        for k in 0 ..< patterns {
            self.noteStrings[k].append(contentsOf: Array.init(repeating: empty, count: H))
        }
    }
    
    /// Initialise the note-erase button view.

    internal func initialiseEraseButtonView() {
        let frame = CGRect(origin: .zero, size: .square(30))
        let button = ColouredButton(backgroundColour: .sineNoteColour, textColour: .offWhite)
            button.setTitle("X", for: .normal)
            button.addTarget(self, action: #selector(didPressErase), for: .touchUpInside)

        eraseButtonView.frame = frame
        eraseButtonView.isHidden = true
        eraseButtonView.addSubview(button)
    }
    
    /// Initialise the sequencer's long press recogniser, which is used to make the note-erase button view appear.

    internal func initialiseLongPressRecogniser() {
        longPressRecogniser.delegate = self
        longPressRecogniser.minimumPressDuration = 0.2
        longPressRecogniser.numberOfTouchesRequired = 1
        longPressRecogniser.cancelsTouchesInView = false
        longPressRecogniser.addTarget(self, action: #selector(longPressed))
        addGestureRecognizer(self.longPressRecogniser)
    }
    
    // MARK: - Keyboard Listener Callbacks
    
    func pressNote(_ note: Int, shape: OscillatorShape) {
        addOrModifyNote(xy: selected, note: note, oscillator: shape)
        Assemble.core.addOrModifyNote(xy: selected, note: note, shape: shape)
    }
    
    func eraseNote() {
        eraseNote(selected)
        Assemble.core.eraseNote(xy: selected)
    }
    
    func setOctave(_ octave: Int) {
        guard let note = Assemble.core.note(at: selected) else { return }
        let pitch = NoteUtilities.modify(note: note.note, withOctave: octave)
        addOrModifyNote(xy: selected, note: pitch, oscillator: note.shape)
        Assemble.core.addOrModifyNote(xy: selected, note: pitch, shape: note.shape)
        Assemble.core.pressNote(pitch, shape: note.shape)
    }
    
    func setOscillator(_ next: Bool) {
        guard let note = Assemble.core.note(at: selected) else { return }
        let oscillator = next ? note.shape.next() : note.shape.previous()
        addOrModifyNote(xy: selected, note: note.note, oscillator: oscillator)
        Assemble.core.addOrModifyNote(xy: selected, note: note.note, shape: oscillator)
        Assemble.core.pressNote(note.note, shape: oscillator)
    }

    /// Move the user's cursor in the specified direction on the sequencer
    /// - Parameter direction: The direction, an integer in [0, 3], in which the cursor should move.

    func didNavigate(by direction: Int) {
        let w: CGFloat = Assemble.patternWidth
        let h: CGFloat = CGFloat(Assemble.core.length)

        if direction == 0 { selected.y -= 1 }
        if direction == 1 { selected.y += 1 }
        if direction == 2 { selected.x -= 1 }
        if direction == 3 { selected.x += 1 }

        if selected.y >= h { selected.y = selected.y - h }
        if selected.y <  0 { selected.y = selected.y + h }
        if selected.x >= w { selected.x = selected.x - w }
        if selected.x <  0 { selected.x = selected.x + w }
        
        noteString = noteStrings[Assemble.core.currentPattern][selected.ny][selected.nx]
    }
    
    // MARK: - Touch Control
    
    /// Destroy the note at the selected point.
    ///
    /// After the user selects a note by double-tapping and presses the delete button that appears,
    /// the Note needs to be removed from the SequencerScene, where it is drawn, and the
    /// Matrix data structure in Assemble's core C++ context. This method performs initiates
    /// both of these tasks.
    ///
    /// - Parameter sender: The `UIButton` that was pressed
    
    @objc func didPressErase(sender: UIButton) {
        guard let xy = noteToErase else { return }
        eraseNote(xy)
        hideEraseNoteView()
        Assemble.core.eraseNote(xy: xy)
    }
    
    /// Handle a long press on the Sequencer.
    ///
    /// The `UILongPressGestureRecogniser` is used to select notes for deletion. When a note is
    /// selected by long pressing, a button appears above the note to allow the user to delete the note.
    ///
    /// - Parameter gesture: The gesture recogniser used to detect the press

    @objc func longPressed(_ gesture: UILongPressGestureRecognizer) {
        guard gesture.state == .began else { return }
        guard noteStrings[Assemble.core.currentPattern][selected.ny][selected.nx] != nil
        else { return }

        eraseButtonView.center = pointFromIndices(selected)
        eraseButtonView.center.translate(x: 0, y: -35)
        noteToErase = selected
        
        showEraseNoteView()
    }
    
    // MARK: - UIGestureRecogniserDelegate

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive event: UIEvent) -> Bool {
        if !eraseButtonView.isHidden,
            let touch = event.allTouches?.first,
            eraseButtonView.point(inside: touch.location(in: eraseButtonView), with: nil) {
            return false
        }
        
        return true
    }
    
    // MARK: - Touch callbacks

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        noteString = noteStrings[Assemble.core.currentPattern][selected.ny][selected.nx]
        hideEraseNoteView()
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        noteString = noteStrings[Assemble.core.currentPattern][selected.ny][selected.nx]
    }

    // MARK: - User Interaction

    /// Add a new note to the sequencer or modify an existing note with new properties.
    /// - Parameter xy: The location in grid coordinates of the new note
    /// - Parameter note: The note number of the new note
    /// - Parameter oscillator: The oscillator to be used for the new note
    /// - Parameter pattern: The pattern that the note should belong to. By default, the current pattern will be used.

    public func addOrModifyNote(xy: CGPoint, note: Int, oscillator: OscillatorShape, pattern: Int? = nil) {
        let pattern = pattern ?? Assemble.core.currentPattern
        let existingNote = noteStrings[pattern][xy.ny][xy.nx]
        let description  = NoteUtilities.describe(note, oscillator: oscillator)
        noteStrings[pattern][xy.ny][xy.nx] = description
        noteString = description

        guard existingNote == nil else {
            modifyNote(xy: xy, oscillator: oscillator)
            return
        }

        let node = CANoteNode(type: oscillator)
        node.isHidden = pattern != self.pattern
        node.position = pointFromIndices(xy)
        node.name = xy.debugDescription
        noteShapeLayers[pattern].append(node)
        add(note: node)
    }
    
    /// Modify the oscillator of an existing note, located at the given position.
    /// - Parameter xy: The location of the note to be modified
    /// - Parameter oscillator: The desired oscillator

    internal func modifyNote(xy: CGPoint, oscillator: OscillatorShape) {
        DispatchQueue.main.async {
            self.noteShapeLayers[Assemble.core.currentPattern].forEach { node in
                if node.name == xy.debugDescription { node.recolour(type: oscillator) }
            }
        }
    }

    /// Remove and destroy every `CANoteNode` situated at the given location, `xy`.
    /// - Parameter xy: The location of the note to be erased in grid coordinates.

    func eraseNote(_ xy: CGPoint) {
        let p = Assemble.core.currentPattern
        DispatchQueue.main.async {
            self.noteShapeLayers[p].removeAll(where: { node in
                let matches = node.name == xy.debugDescription
                if  matches {
                    node.removeFromSuperlayer()
                    self.noteStrings[p][xy.ny][xy.nx] = nil
                    self.noteString = nil
                }
                return matches
            })
        }
    }
    
    // MARK: - Erase Note View

    /// Display the erase button above the selected note

    func showEraseNoteView() {
        DispatchQueue.main.async {
            self.eraseButtonView.isHidden = false
            self.eraseButtonView.scaleBy(x: 0.1, y: 0.1)
            UIView.animate(withDuration: 0.1) {
                self.eraseButtonView.scaleBy(x: 1.0, y: 1.0)
            }
        }
    }

    /// Hide the erase button from view

    func hideEraseNoteView() {
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.1) {
                self.eraseButtonView.scaleBy(x: 0.1, y: 0.1)
                self.eraseButtonView.isHidden = true
            }
        }
    }
    
    // MARK: - State Update

    /// Poll the Assemble core for its total state and initialise the scene from its contents.

    public func initialiseFromUnderlyingState() {
        guard let state = Assemble.core.commander?.collateCoreState()
        else { return }
        self.reset()
        self.initialiseFromState(state)
        self.updateNoteString()
    }

    /// Update the current note description to reflect the selected sequencer position

    internal func updateNoteString() {
        guard pattern < noteStrings.count,
              selected.ny < noteStrings[pattern].count,
              selected.nx < noteStrings[pattern][selected.ny].count
              else { noteString = nil; return }
        noteString = noteStrings[pattern][selected.ny][selected.nx]
    }
    
    /// Initialise the sequencer scene from the given state data.
    ///
    /// The key of each state string is a string of the form *PK*, where K is the index of the Pattern who should adopt the state.
    ///
    /// - Note: Each state string begins with a character that denotes whether the underlying Pattern is active or not.
    /// This character should be dropped from the data before passing it to the NoteUtilities class for decoding.

    public func initialiseFromState(_ state: [String : Any]) {
        for (key, data) in state {
            let data = (data as? String)?.dropFirst() ?? ""
            let pattern = Int(key.suffix(1))
            let notes: [NoteUtilities.Note?] = NoteUtilities.decode(from: data)

            for case let note? in notes {
                addOrModifyNote(xy: note.xy, note: note.note, oscillator: note.shape, pattern: pattern)
            }
        }
    }
    
    /// Update the scene to reflect the next pattern, `pattern`.
    ///
    /// `SequencerScene` stores each `NoteShapeNode` for each pattern in order that they can be
    /// quickly shown or hidden. At any time, only the notes that belong to the pattern that's currently playing are visible.
    ///
    /// This method shows the new pattern and hides the previous pattern.
    ///
    /// - Complexity: O(nm), where `n` and `m` are the dimensions of a pattern.

    func patternDidChange(to pattern: Int) {
        guard pattern != self.pattern else { return }

        hideEraseNoteView()
        redrawIfNeeded()
        noteString = noteStrings[Assemble.core.currentPattern][selected.ny][selected.nx]
        DispatchQueue.main.async {
            self.noteShapeLayers[self.pattern].forEach { node in node.performWithoutActions { node.isHidden = true  }}
            self.noteShapeLayers[pattern].forEach      { node in node.performWithoutActions { node.isHidden = false }}
            self.pattern = pattern
        }
    }

    /// Reset the sequencer by removing every note node and setting every note description to nil.

    private func reset() {
        self.noteShapeLayers = self.noteShapeLayers.map { pattern in
            pattern.forEach { $0.removeFromSuperlayer() }
            return []
        }

        self.noteString  = nil
        self.noteStrings = self.noteStrings.map { pattern in pattern.map { row in row.map { _ in nil } } }
    }
    
    /// Clear one of the sequencer scene's patterns.
    ///
    /// Each `NoteShapeNode` belonging to the pattern to be cleared
    /// will be removed from the scene and destroyed, and each cell in the
    /// pattern's `noteStrings` array will be set to nil. This should be called
    /// at the same time as the current pattern of the core sequencer is reset.
    ///
    /// - Parameter notification: The `NSNotification` requesting that
    /// a pattern should be cleared. The index of the pattern to be cleared is stored
    /// in the notification's `object` property.

    @discardableResult
    @objc func clearPattern(_ notification: NSNotification) -> Bool {
        guard let index = notification.object as? Int else { return false }
        return clearPatternAsynchronously(at: index, then: {
            if index == self.pattern {
                self.hideEraseNoteView()
            }
        })
    }
    
    /// Clear one of the sequencer scene's patterns.
    /// - Parameter index: The index of the pattern whose representation should be reset
    /// - Parameter callback: An optional closure that may be executed after the nominated pattern has been reset.

    @discardableResult
    internal func clearPatternAsynchronously(at index: Int, then callback: (() -> ())? = nil) -> Bool {
        guard (0 ..< noteShapeLayers.count).contains(index) else { return false }

        DispatchQueue.main.async {
            self.noteShapeLayers[index].forEach { $0.removeFromSuperlayer() }
            self.noteShapeLayers[index].removeAll()
            if Assemble.core.currentPattern == index { self.noteString = nil }
            for y in 0 ..< Int(Assemble.patternHeight) {
                for x in 0 ..< Int(Assemble.patternWidth) {
                    self.noteStrings[index][y][x] = nil
                }
            }

            callback?()
        }

        return true
    }
    
    /// Update the representation of the pattern whose index is stored in
    /// the given `NSNotification`'s `object` property.
    ///
    /// This method is triggered whenever a Pattern's state is replaced with a copied Pattern state in the core.
    ///
    /// - Parameter notification: The `NSNotification` requesting that a pattern's representation
    /// should be updated. The index of the pattern to be updated is stored in the notification's `object` property.

    @discardableResult
    @objc func updatePattern(_ notification: NSNotification) -> Bool {
        guard let index = notification.object as? Int else { return false }
        guard let state = Assemble.core.commander?.getCoreState(of: index) else { return false }
        let initialiser = { self.initialiseFromState(state) }
        clearPatternAsynchronously(at: index, then: initialiser)
        return true
    }
    
    // MARK: - Hit Test
    
    /// Include subviews who fall outside the bounds of the view in the hit test. In Assemble,
    /// this allows the delete icon to be pressed if it happens to appear outside the bounds of the view.
    ///
    /// - Author: Noam
    /// - Note: Source: <https://stackoverflow.com/a/14875673/9611538>

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        guard !clipsToBounds && !isHidden && alpha > 0 else { return nil }

        for member in subviews.reversed() {
            let subPoint = member.convert(point, from: self)
            guard let result = member.hitTest(subPoint, with: event) else { continue }
            return result
        }

        return super.hitTest(point, with: event)
    }

}

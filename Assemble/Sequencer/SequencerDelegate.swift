//  SequencerDelegate.swift
//  Assemble
//  Created by David Spry on 26/4/20.
//  Copyright © 2020 David Spry. All rights reserved.

import Foundation

protocol SequencerDelegate {
    func addOrModifyNote(xy: CGPoint, note: Int, shape: OscillatorShape)
    func eraseNote(xy: CGPoint)
}

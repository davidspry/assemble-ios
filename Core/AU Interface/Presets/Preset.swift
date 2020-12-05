//  Assemble
//  Created by David Spry on 5/12/20.
//  Copyright © 2020 David Spry. All rights reserved.

import Foundation
import CoreAudio

/// A decodable preset format for storing song and parameter data.

public struct Preset: Codable
{
    init(named: String, numbered: Int, state: [String:Any]) {
        name   = named
        number = numbered
        
        data = state["data"] as? Data ?? Data()
        type = state["type"] as? Int  ?? 1635084142
        version = state["version"] as? Int ?? 1
        subtype = state["subtype"] as? Int ?? 1095978306
        manufacturer = state["manufacturer"] as? Int ?? 1146310738
        
        var patterns = [String]()
        for i in 0 ..< 8 {
            let pattern = state["P\(i)"] as? String ?? "0"
            patterns.append(pattern)
        }
        
        self.patterns = patterns
    }
    
    init(named: String, from preset: Preset) {
        self.init(named: named, numbered: preset.number, from: preset)
    }

    init(named: String, numbered: Int, from preset: Preset) {
        name = named
        data = preset.data
        type = preset.type
        number  = numbered
        version = preset.version
        subtype = preset.subtype
        patterns = preset.patterns
        manufacturer = preset.manufacturer
    }

    internal func deserialisePreset() -> [String:Any] {
        let patterns = deserialisePatterns()
        return [
            "name" : name,
            "data" : data,
            "type" : type,
            "version" : version,
            "subtype" : subtype,
            "manufacturer" : manufacturer,
            "preset-number" : number,
        ].merging(patterns) { a, b in b }
    }
    
    private func deserialisePatterns() -> [String:Any] {
        var patterns = [String:Any]()
        let count = self.patterns.count
        
        for k in 0...7 {
            let index = "P" + k.description
            let value = k < count ? self.patterns[k] : ""
            patterns[index] = value
        }
        
        return patterns
    }
    
    public var filepath: String {
        return "Songs/\(number)_\(name).json"
    }

    /// Preset properties

    let name: String
    let data: Data
    let number: Int
    let patterns: [String]
    
    /// AudioUnit properties

    let type: Int
    let version: Int
    let subtype: Int
    let manufacturer: Int
    
    
}

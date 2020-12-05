//  Assemble
//  Created by David Spry on 5/12/20.
//  Copyright © 2020 David Spry. All rights reserved.

import Foundation
import CoreAudio

/// A decodable preset format for storing song and parameter data.

public struct Preset: Codable
{
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        name    = try container.decode(String.self, forKey: .name)
        data    = try container.decode(Data.self, forKey: .data)
        type    = try container.decode(Int.self, forKey: .type)
        number  = try container.decode(Int.self, forKey: .number)
        subtype = try container.decode(Int.self, forKey: .subtype)
        version = try container.decode(Int.self, forKey: .version)
        manufacturer = try container.decode(Int.self, forKey: .manufacturer)
        patterns = try container.decode([String].self, forKey: .patterns)
        modified = try container.decodeIfPresent(Int.self, forKey: .modified) ??
                       Int(Date().timeIntervalSince1970)
    }

    /// Construct a `Preset` with the given name, number, and state.
    /// - Parameter named:    The desired name of the preset
    /// - Parameter numbered: The desired number of the preset
    /// - Parameter state:    The preset's state

    init(named: String, numbered: Int, state: [String:Any]) {
        name    = named
        number  = numbered
        data    = state["data"] as? Data ?? Data()
        type    = state["type"] as? Int  ?? 1635084142
        version = state["version"] as? Int ?? 1
        subtype = state["subtype"] as? Int ?? 1095978306
        modified = Int(Date().timeIntervalSince1970)
        manufacturer = state["manufacturer"] as? Int ?? 1146310738
        patterns = (0...7).map { state["P\($0)"] as? String ?? "0" }
    }
    
    /// Construct a `Preset` from an existing `Preset`
    /// - Parameter preset: The existing preset.

    init(from preset: Preset) {
        self.init(named: preset.name, numbered: preset.number, from: preset)
    }
    
    /// Construct a `Preset` from an existing `Preset` by modifying its name.
    /// - Parameter named:  The desired name of the new preset
    /// - Parameter preset: The existing preset.

    init(named: String, from preset: Preset) {
        self.init(named: named, numbered: preset.number, from: preset)
    }

    /// Construct a `Preset` from an existing `Preset` by modifying its name and number.
    /// - Parameter named:    The desired name of the new preset
    /// - Parameter numbered: The desired number of the new preset
    /// - Parameter preset:   The existing preset.

    init(named: String, numbered: Int, from preset: Preset) {
        name    = named
        data    = preset.data
        type    = preset.type
        number  = numbered
        version = preset.version
        subtype = preset.subtype
        modified = Int(Date().timeIntervalSince1970)
        manufacturer = preset.manufacturer
        patterns = preset.patterns
    }
    
    /// Construct a `Preset` from an `.aupreset` file that has been decoded by an `NSKeyUnarchiver`.
    
    init(from archive: NSDictionary) {
        name    = archive.value(forKey: "name") as? String ?? ""
        type    = archive.value(forKey: "type") as? Int  ?? 0
        data    = archive.value(forKey: "data") as? Data ?? Data()
        number  = archive.value(forKey: "preset-number") as? Int ?? -50
        version = archive.value(forKey: "version") as? Int ?? 0
        subtype = archive.value(forKey: "subtype") as? Int ?? 0
        modified = Int(Date().timeIntervalSince1970)
        manufacturer = archive.value(forKey: "manufacturer") as? Int ?? 0
        patterns = (0...7).map { archive.value(forKey: "P\($0)") as? String ?? "0" }
    }

    /// Deserialise the preset's state dictionary. This can be used to set the `fullState` property.

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
    
    /// Deserialise the preset's patterns into a dictionary of strings with keys P0, P1, ..., Pn (for n patterns).

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

    /// A preset's filepath relative to the Documents directory.

    public var filepath: String {
        return "Songs/\(number)_\(name).json"
    }

    /// Decodable properties

    enum CodingKeys: String, CodingKey {
        case name
        case data
        case type
        case number
        case patterns
        case modified
        case version
        case subtype
        case manufacturer
    }
    
    /// Preset properties

    let name: String
    let data: Data
    let number: Int
    let patterns: [String]
    let modified: Int
    
    /// AudioUnit properties

    let type: Int
    let version: Int
    let subtype: Int
    let manufacturer: Int
    
    
}

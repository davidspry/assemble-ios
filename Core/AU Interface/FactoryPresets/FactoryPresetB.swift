//  Assemble
//  Created by David Spry on 16/6/20.
//  Copyright © 2020 David Spry. All rights reserved.

import Foundation

/// A factory preset and its full state

struct FactoryPresetB
{
    static var preset: AUAudioUnitPreset {
        let preset = AUAudioUnitPreset()
        preset.name = "Factory Preset B"
        preset.number = 3
        return preset
    }
    
    static let state: [String : Any]? =
    [
        "name": "Factory Preset B",
        "type": 1635084142,
        "version": 1,
        "subtype": 1095978306,
        "preset-number": 2,
        "manufacturer": 1146310738,
        "P0" :
            ([49,
              35, 4, 1, 1, 61, 3,
              35, 4, 16, 1, 37, 3,
              35, 4, 3, 3, 68, 3,
              35, 4, 12, 3, 72, 2,
              35, 4, 8, 3, 73, 4,
              35, 4, 12, 5, 72, 2,
              35, 4, 3, 7, 68, 3,
              35, 4, 12, 7, 72, 2,
              35, 4, 5, 9, 63, 3,
              35, 4, 16, 9, 44, 3,
              35, 4, 12, 9, 72, 2,
              35, 4, 8, 9, 72, 4,
              35, 4, 12, 11, 63, 2,
              35, 4, 7, 13, 70, 3,
              35, 4, 12, 13, 63, 2,
              35, 4, 8, 13, 70, 4,
              35, 4, 5, 15, 65, 3,
              35, 4, 16, 15, 41, 3
            ]).map { String(Character(UnicodeScalar($0)))}.joined(),
        "P1" :
            ([49,
              35, 4, 5, 3, 72, 3,
              35, 4, 7, 5, 68, 3,
              35, 4, 16, 5, 36, 3,
              35, 4, 12, 5, 63, 2,
              35, 4, 3, 5, 80, 4,
              35, 4, 12, 7, 63, 2,
              35, 4, 16, 7, 48, 3,
              35, 4, 9, 9, 75, 3,
              35, 4, 12, 9, 63, 2,
              35, 4, 3, 9, 96, 4,
              35, 4, 11, 11, 82, 3,
              35, 4, 16, 11, 27, 3,
              35, 4, 12, 11, 91, 2,
              35, 4, 3, 11, 91, 4,
              35, 4, 8, 13, 84, 3,
              35, 4, 12, 13, 92, 2,
              35, 4, 3, 13, 87, 4,
              35, 4, 16, 13, 39, 3,
              35, 4, 6, 15, 80, 3,
              35, 4, 12, 15, 96, 2
            ]).map { String(Character(UnicodeScalar($0)))}.joined(),
        "P2" :
            ([49,
              35, 4, 1, 1, 56, 4,
              35, 4, 16, 1, 49, 3,
              35, 4, 2, 2, 65, 4,
              35, 4, 16, 2, 37, 3,
              35, 4, 11, 2, 92, 2,
              35, 4, 11, 3, 92, 2,
              35, 4, 11, 4, 92, 2,
              35, 4, 2, 5, 65, 4,
              35, 4, 16, 7, 56, 3,
              35, 4, 2, 7, 65, 4,
              35, 4, 11, 7, 92, 2,
              35, 4, 16, 8, 44, 3,
              35, 4, 3, 8, 68, 4,
              35, 4, 11, 8, 92, 2,
              35, 4, 16, 9, 32, 3,
              35, 4, 4, 9, 72, 4,
              35, 4, 11, 9, 92, 2,
              35, 4, 4, 11, 72, 4,
              35, 4, 11, 12, 92, 2,
              35, 4, 16, 13, 53, 3,
              35, 4, 4, 13, 72, 4,
              35, 4, 11, 13, 92, 2,
              35, 4, 16, 14, 41, 3,
              35, 4, 5, 14, 75, 4,
              35, 4, 11, 14, 92, 2,
              35, 4, 16, 15, 29, 3,
              35, 4, 6, 15, 77, 4
            ]).map { String(Character(UnicodeScalar($0)))}.joined(),
        "P3" :
            ([49,
              35, 4, 1, 1, 29, 3,
              35, 4, 5, 2, 41, 3,
              35, 4, 16, 2, 91, 2,
              35, 4, 10, 3, 53, 3,
              35, 4, 16, 3, 91, 2,
              35, 4, 14, 4, 65, 3,
              35, 4, 16, 4, 91, 2,
              35, 4, 6, 6, 89, 2,
              35, 4, 4, 7, 80, 2,
              35, 4, 8, 8, 68, 3,
              35, 4, 6, 9, 84, 2,
              35, 4, 10, 10, 73, 4,
              35, 4, 8, 11, 65, 3,
              35, 4, 12, 12, 77, 3,
              35, 4, 10, 13, 68, 4,
              35, 4, 14, 14, 80, 4,
              35, 4, 12, 15, 72, 2,
              35, 4, 16, 16, 84, 3
            ]).map { String(Character(UnicodeScalar($0)))}.joined(),
        "P4" : "0",
        "P5" : "0",
        "P6" : "0",
        "P7" : "0",
        "data": Data(base64Encoded:
            "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") ?? Data()
    ]

}

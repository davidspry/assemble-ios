//  Assemble
//  Created by David Spry on 16/6/20.
//  Copyright © 2020 David Spry. All rights reserved.

import Foundation

/// A factory preset and its full state

struct FactoryPresetA
{
    static var preset: AUAudioUnitPreset {
        let preset = AUAudioUnitPreset()
        preset.name = "Factory Preset A"
        preset.number = 2
        return preset
    }
    
    static let state: [String : Any]? =
    [
        "name": "Factory Preset A",
        "type": 1635084142,
        "version": 1,
        "subtype": 1095978306,
        "preset-number": 2,
        "manufacturer": 1146310738,
        "P0" :
            ([49,
              126, 4, 1, 1, 37, 3, 
              126, 4, 10, 1, 63, 4, 
              126, 4, 14, 2, 56, 4, 
              126, 4, 10, 3, 63, 4, 
              126, 4, 3, 4, 44, 3, 
              126, 4, 10, 4, 63, 4, 
              126, 4, 6, 6, 51, 3, 
              126, 4, 10, 6, 63, 4, 
              126, 4, 1, 8, 48, 3, 
              126, 4, 14, 8, 63, 4, 
              126, 4, 1, 9, 36, 3, 
              126, 4, 1, 10, 60, 3, 
              126, 4, 10, 10, 63, 4, 
              126, 4, 10, 11, 63, 4, 
              126, 4, 3, 12, 43, 3, 
              126, 4, 10, 13, 63, 4, 
              126, 4, 6, 14, 51, 3, 
              126, 4, 13, 14, 67, 4, 
              126, 4, 15, 14, 70, 4, 
              126, 4, 9, 16, 53, 3, 
              126, 4, 14, 16, 68, 4, 
              126, 4, 16, 16, 72, 4
            ]).map { String(Character(UnicodeScalar($0)))}.joined(),
        "P1" :
            ([49,
              126, 4, 1, 1, 37, 3, 
              126, 4, 10, 1, 63, 4, 
              126, 4, 14, 2, 65, 4, 
              126, 4, 10, 3, 63, 4, 
              126, 4, 3, 4, 44, 3, 
              126, 4, 10, 4, 63, 4, 
              126, 4, 5, 6, 51, 3, 
              126, 4, 10, 6, 63, 4, 
              126, 4, 14, 8, 67, 4, 
              126, 4, 1, 8, 51, 3, 
              126, 4, 1, 9, 39, 3, 
              126, 4, 10, 10, 63, 4, 
              126, 4, 1, 10, 27, 3, 
              126, 4, 10, 11, 63, 4, 
              126, 4, 3, 12, 46, 3, 
              126, 4, 10, 13, 63, 4, 
              126, 4, 13, 13, 79, 4, 
              126, 4, 5, 14, 53, 3, 
              126, 4, 10, 14, 63, 4, 
              126, 4, 14, 14, 80, 4, 
              126, 4, 12, 14, 65, 4, 
              126, 4, 15, 15, 82, 4, 
              126, 4, 13, 15, 79, 4, 
              126, 4, 10, 16, 63, 4, 
              126, 4, 16, 16, 84, 4, 
              126, 4, 14, 16, 80, 4, 
              126, 4, 3, 16, 44, 3
            ]).map { String(Character(UnicodeScalar($0)))}.joined(),
        "P2" :
            ([49,
              126, 4, 1, 1, 41, 3, 
              126, 4, 10, 1, 67, 4, 
              126, 4, 10, 2, 67, 4, 
              126, 4, 14, 3, 72, 4, 
              126, 4, 3, 4, 48, 3, 
              126, 4, 10, 4, 67, 4, 
              126, 4, 5, 6, 56, 3, 
              126, 4, 10, 6, 67, 4, 
              126, 4, 1, 8, 55, 3, 
              126, 4, 10, 8, 67, 4, 
              126, 4, 14, 8, 70, 4, 
              126, 4, 1, 9, 43, 3, 
              126, 4, 1, 10, 31, 3, 
              126, 4, 10, 10, 67, 4, 
              126, 4, 10, 11, 67, 4, 
              126, 4, 3, 12, 46, 3, 
              126, 4, 12, 12, 70, 4, 
              126, 4, 10, 13, 67, 4, 
              126, 4, 5, 14, 51, 3, 
              126, 4, 10, 14, 67, 4, 
              126, 4, 10, 15, 67, 4, 
              126, 4, 2, 16, 44, 3, 
              126, 4, 11, 16, 68, 4
            ]).map { String(Character(UnicodeScalar($0)))}.joined(),
        "P3" :
            ([49,
              126, 4, 1, 1, 46, 3, 
              126, 4, 10, 1, 62, 4, 
              126, 4, 11, 2, 70, 4, 
              126, 4, 13, 2, 74, 4, 
              126, 4, 15, 2, 82, 4, 
              126, 4, 10, 3, 62, 4, 
              126, 4, 11, 3, 70, 4, 
              126, 4, 3, 4, 41, 3, 
              126, 4, 15, 4, 82, 4, 
              126, 4, 13, 4, 74, 4, 
              126, 4, 11, 5, 70, 4, 
              126, 4, 11, 6, 70, 4, 
              126, 4, 10, 6, 62, 4, 
              126, 4, 5, 6, 50, 3, 
              126, 4, 15, 6, 82, 4, 
              126, 4, 13, 6, 74, 4, 
              126, 4, 1, 8, 58, 3, 
              126, 4, 10, 8, 62, 4, 
              126, 4, 1, 9, 46, 3, 
              126, 4, 13, 9, 62, 4, 
              126, 4, 15, 9, 70, 4, 
              126, 4, 1, 10, 34, 3, 
              126, 4, 11, 10, 70, 4, 
              126, 4, 10, 11, 62, 4, 
              126, 4, 11, 11, 70, 4, 
              126, 4, 15, 11, 82, 4, 
              126, 4, 13, 11, 74, 4, 
              126, 4, 3, 12, 41, 3, 
              126, 4, 10, 13, 62, 4, 
              126, 4, 5, 14, 50, 3, 
              126, 4, 11, 14, 70, 4, 
              126, 4, 15, 14, 82, 4, 
              126, 4, 13, 14, 74, 4, 
              126, 4, 11, 16, 70, 4, 
              126, 4, 10, 16, 74, 4, 
              126, 4, 7, 16, 58, 3
            ]).map { String(Character(UnicodeScalar($0)))}.joined(),
        "P4" : "0",
        "P5" : "0",
        "P6" : "0",
        "P7" : "0",
        "data": Data(base64Encoded:
            "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") ?? Data()
    ]

}

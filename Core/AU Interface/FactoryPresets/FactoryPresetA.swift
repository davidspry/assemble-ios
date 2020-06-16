//  Assemble
//  Created by David Spry on 18/5/20.
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
              35, 4, 1, 1, 33, 4,
              35, 4, 6, 2, 72, 4,
              35, 4, 15, 2, 69, 3,
              35, 4, 7, 3, 60, 4,
              35, 4, 15, 3, 69, 3,
              35, 4, 4, 4, 62, 4,
              35, 4, 1, 4, 33, 4,
              35, 4, 15, 4, 69, 3,
              35, 4, 5, 5, 50, 4,
              35, 4, 8, 6, 77, 4,
              35, 4, 9, 7, 76, 4,
              35, 4, 5, 8, 62, 4,
              35, 4, 6, 9, 65, 4,
              35, 4, 1, 10, 41, 4,
              35, 4, 5, 11, 48, 4,
              35, 4, 9, 12, 64, 4,
              35, 4, 13, 13, 69, 4,
              35, 4, 1, 14, 36, 4,
              35, 4, 4, 15, 52, 4,
              35, 4, 15, 15, 67, 3,
              35, 4, 8, 16, 57, 4,
              35, 4, 15, 16, 67, 3
            ]).map { String(Character(UnicodeScalar($0)))}.joined(),
        "P1" :
            ([49,
              35, 4, 1, 1, 31, 4,
              35, 4, 8, 2, 71, 4,
              35, 4, 7, 3, 59, 4,
              35, 4, 15, 3, 67, 3,
              35, 4, 10, 4, 59, 4,
              35, 4, 11, 5, 60, 4,
              35, 4, 12, 6, 62, 4,
              35, 4, 11, 7, 50, 4,
              35, 4, 15, 7, 67, 3,
              35, 4, 1, 8, 43, 4,
              35, 4, 1, 9, 43, 4,
              35, 4, 4, 10, 47, 4,
              35, 4, 9, 11, 62, 4,
              35, 4, 15, 11, 67, 3,
              35, 4, 10, 12, 64, 4,
              35, 4, 11, 13, 65, 4,
              35, 4, 12, 14, 77, 4,
              35, 4, 3, 15, 50, 4,
              35, 4, 15, 15, 71, 3,
              35, 4, 2, 16, 55, 4
            ]).map { String(Character(UnicodeScalar($0)))}.joined(),
        "P2" :
            ([49,
              35, 4, 9, 1, 71, 4,
              35, 4, 16, 1, 83, 3,
              35, 4, 8, 2, 69, 4,
              35, 4, 9, 3, 71, 4,
              35, 4, 14, 3, 79, 3,
              35, 4, 10, 4, 64, 4,
              35, 4, 1, 5, 28, 4,
              35, 4, 16, 5, 81, 3,
              35, 4, 1, 6, 28, 4,
              35, 4, 14, 7, 76, 3,
              35, 4, 1, 8, 28, 4,
              35, 4, 5, 9, 47, 4,
              35, 4, 16, 9, 83, 3,
              35, 4, 1, 10, 28, 4,
              35, 4, 5, 11, 47, 4,
              35, 4, 14, 11, 74, 3,
              35, 4, 6, 12, 52, 4,
              35, 4, 1, 13, 40, 4,
              35, 4, 16, 13, 76, 3,
              35, 4, 1, 14, 52, 4,
              35, 4, 9, 15, 55, 4,
              35, 4, 14, 15, 81, 3,
              35, 4, 10, 16, 59, 4
            ]).map { String(Character(UnicodeScalar($0)))}.joined(),
        "P3" : "0",
        "P4" : "0",
        "P5" : "0",
        "P6" : "0",
        "P7" : "0",
        "data": Data(base64Encoded:
            "AQAAAA8AAABwAGEAcgBhAG0AZQB0AGUAcgBzAEMAbABvAGMAawAAAAkAAABrAEMAbABvAGMAawBCAFAATQAAAKpCAAARAAAAawBDAGwAbwBjAGsAUwB1AGIAZABpAHYAaQBzAGkAbwBuAAAAgED/AQ4AAABwAGEAcgBhAG0AZQB0AGUAcgBzAFMAaQBuAGUAAAAAAA0AAABrAFMAaQBuAEEAbQBwAEEAdAB0AGEAYwBrAAAAoEAAAAsAAABrAFMAaQBuAEEAbQBwAEgAbwBsAGQAAAAAAAAADgAAAGsAUwBpAG4AQQBtAHAAUgBlAGwAZQBhAHMAZQAAAPpDAAAAABAAAABrAFMAaQBuAEYAaQBsAHQAZQByAEEAdAB0AGEAYwBrAAAAyEEAAAAADgAAAGsAUwBpAG4ARgBpAGwAdABlAHIASABvAGwAZAAAAAAAAAAAABEAAABrAFMAaQBuAEYAaQBsAHQAZQByAFIAZQBsAGUAYQBzAGUAAAB6Q/8BEAAAAHAAYQByAGEAbQBlAHQAZQByAHMAUwBxAHUAYQByAGUAAAAAAA0AAABrAFMAcQByAEEAbQBwAEEAdAB0AGEAYwBrAAAAoEAAAAsAAABrAFMAcQByAEEAbQBwAEgAbwBsAGQAAAAAAAAADgAAAGsAUwBxAHIAQQBtAHAAUgBlAGwAZQBhAHMAZQAAAPpDAAAAABAAAABrAFMAcQByAEYAaQBsAHQAZQByAEEAdAB0AGEAYwBrAAAAyEEAAAAADgAAAGsAUwBxAHIARgBpAGwAdABlAHIASABvAGwAZAAAAAAAAAAAABEAAABrAFMAcQByAEYAaQBsAHQAZQByAFIAZQBsAGUAYQBzAGUAAAB6Q/8BEgAAAHAAYQByAGEAbQBlAHQAZQByAHMAVAByAGkAYQBuAGcAbABlAAAAAAANAAAAawBUAHIAaQBBAG0AcABBAHQAdABhAGMAawAAAKBAAAALAAAAawBUAHIAaQBBAG0AcABIAG8AbABkAAAAAAAAAA4AAABrAFQAcgBpAEEAbQBwAFIAZQBsAGUAYQBzAGUAAAD6QwAAAAAQAAAAawBUAHIAaQBGAGkAbAB0AGUAcgBBAHQAdABhAGMAawAAAMhBAAAAAA4AAABrAFQAcgBpAEYAaQBsAHQAZQByAEgAbwBsAGQAAAAAAAAAAAARAAAAawBUAHIAaQBGAGkAbAB0AGUAcgBSAGUAbABlAGEAcwBlAAAAekP/ARIAAABwAGEAcgBhAG0AZQB0AGUAcgBzAFMAYQB3AHQAbwBvAHQAaAAAAAAADQAAAGsAUwBhAHcAQQBtAHAAQQB0AHQAYQBjAGsAAACgQAAACwAAAGsAUwBhAHcAQQBtAHAASABvAGwAZAAAAAAAAAAOAAAAawBTAGEAdwBBAG0AcABSAGUAbABlAGEAcwBlAAAA+kMAAAAAEAAAAGsAUwBhAHcARgBpAGwAdABlAHIAQQB0AHQAYQBjAGsAAADIQQAAAAAOAAAAawBTAGEAdwBGAGkAbAB0AGUAcgBIAG8AbABkAAAAAAAAAAAAEQAAAGsAUwBhAHcARgBpAGwAdABlAHIAUgBlAGwAZQBhAHMAZQAAAHpD/wEQAAAAcABhAHIAYQBtAGUAdABlAHIAcwBGAGkAbAB0AGUAcgAAAAAAEwAAAGsAUwBpAG4ARgBpAGwAdABlAHIARgByAGUAcQB1AGUAbgBjAHkAAACAPwAAEwAAAGsAUwBpAG4ARgBpAGwAdABlAHIAUgBlAHMAbwBuAGEAbgBjAGUAbxKDOgAAEwAAAGsAVAByAGkARgBpAGwAdABlAHIARgByAGUAcQB1AGUAbgBjAHkAAACAPwAAEwAAAGsAVAByAGkARgBpAGwAdABlAHIAUgBlAHMAbwBuAGEAbgBjAGUAbxKDOgAAEwAAAGsAUwBxAHIARgBpAGwAdABlAHIARgByAGUAcQB1AGUAbgBjAHkAMzNzPwAAEwAAAGsAUwBxAHIARgBpAGwAdABlAHIAUgBlAHMAbwBuAGEAbgBjAGUAzMzMPQAAEwAAAGsAUwBhAHcARgBpAGwAdABlAHIARgByAGUAcQB1AGUAbgBjAHkAMzNzPwAAEwAAAGsAUwBhAHcARgBpAGwAdABlAHIAUgBlAHMAbwBuAGEAbgBjAGUAzMzMPf8BFQAAAHAAYQByAGEAbQBlAHQAZQByAHMAUwB0AGUAcgBlAG8ARABlAGwAYQB5AAAADAAAAGsARABlAGwAYQB5AFQAbwBnAGcAbABlAAAAgD8AAAAADgAAAGsARABlAGwAYQB5AEYAZQBlAGQAYgBhAGMAawDMzMw+AAAAABEAAABrAFMAdABlAHIAZQBvAEQAZQBsAGEAeQBMAFQAaQBtAGUAAAAAQQAAEQAAAGsAUwB0AGUAcgBlAG8ARABlAGwAYQB5AFIAVABpAG0AZQAAAABBAAAJAAAAawBEAGUAbABhAHkATQBpAHgAAACAPgAAEgAAAGsAUwB0AGUAcgBlAG8ARABlAGwAYQB5AE8AZgBmAHMAZQB0AAAAgED/AQAAEQAAAHAAYQByAGEAbQBlAHQAZQByAHMAVgBpAGIAcgBhAHQAbwAAAA4AAABrAFYAaQBiAHIAYQB0AG8AVABvAGcAZwBsAGUAAACAPwAAAAANAAAAawBWAGkAYgByAGEAdABvAFMAcABlAGUAZAAAACBAAAANAAAAawBWAGkAYgByAGEAdABvAEQAZQBwAHQAaADMzMw9//8=") ?? Data()
    ]

}

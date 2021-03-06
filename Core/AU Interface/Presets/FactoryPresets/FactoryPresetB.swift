//  Assemble
//  Created by David Spry on 11/7/20.
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
        "preset-number": 3,
        "manufacturer": 1146310738,
        "P0" :
            ([49,
              126, 4, 1, 1, 49, 4,
              126, 4, 16, 2, 61, 4,
              126, 4, 4, 3, 56, 4,
              126, 4, 16, 4, 70, 4,
              126, 4, 10, 5, 60, 4,
              126, 4, 16, 6, 72, 4,
              126, 4, 2, 7, 67, 4,
              126, 4, 1, 8, 41, 4,
              126, 4, 8, 9, 68, 4,
              126, 4, 5, 10, 48, 4,
              126, 4, 14, 11, 72, 4,
              126, 4, 11, 12, 56, 4,
              126, 4, 10, 13, 77, 4,
              126, 4, 5, 14, 51, 4,
              126, 4, 14, 15, 80, 4,
              126, 4, 11, 16, 60, 4
            ]).map { String(Character(UnicodeScalar($0)))}.joined(),
        "P1" :
            ([49,
              126, 4, 1, 1, 46, 4,
              126, 4, 16, 2, 65, 4,
              126, 4, 9, 3, 53, 4,
              126, 4, 6, 4, 58, 4,
              126, 4, 13, 5, 61, 4,
              126, 4, 8, 6, 60, 4,
              126, 4, 1, 8, 37, 4,
              126, 4, 15, 9, 63, 4,
              126, 4, 7, 10, 44, 4,
              126, 4, 11, 12, 68, 4,
              126, 4, 13, 13, 49, 4,
              126, 4, 15, 14, 77, 4,
              126, 4, 9, 15, 56, 4,
              126, 4, 6, 16, 84, 4
            ]).map { String(Character(UnicodeScalar($0)))}.joined(),
        "P2" :
            ([49,
              126, 4, 1, 1, 46, 4,
              126, 4, 16, 2, 72, 4,
              126, 4, 8, 4, 61, 4,
              126, 4, 13, 6, 68, 4,
              126, 4, 5, 8, 80, 4,
              126, 4, 1, 9, 44, 4,
              126, 4, 7, 11, 53, 4,
              126, 4, 3, 12, 75, 4,
              126, 4, 12, 13, 60, 4,
              126, 4, 15, 15, 63, 4,
              126, 4, 7, 16, 77, 4
            ]).map { String(Character(UnicodeScalar($0)))}.joined(),
        "P3" : "0",
        "P4" : "0",
        "P5" : "0",
        "P6" : "0",
        "P7" : "0",
        "data": Data(base64Encoded:
            "AQAAAA8AAABwAGEAcgBhAG0AZQB0AGUAcgBzAEMAbABvAGMAawAAAAkAAABrAEMAbABvAGMAawBCAFAATQAAAJZCAAARAAAAawBDAGwAbwBjAGsAUwB1AGIAZABpAHYAaQBzAGkAbwBuAAAAgED/AQ4AAABwAGEAcgBhAG0AZQB0AGUAcgBzAFMAaQBuAGUAAAAAAA0AAABrAFMAaQBuAEEAbQBwAEEAdAB0AGEAYwBrAAAAoEAAAAsAAABrAFMAaQBuAEEAbQBwAEgAbwBsAGQAAAAAAAAADgAAAGsAUwBpAG4AQQBtAHAAUgBlAGwAZQBhAHMAZQAAAPpDAAAAABAAAABrAFMAaQBuAEYAaQBsAHQAZQByAEEAdAB0AGEAYwBrAAAAoEAAAAAADgAAAGsAUwBpAG4ARgBpAGwAdABlAHIASABvAGwAZAAAAAAAAAAAABEAAABrAFMAaQBuAEYAaQBsAHQAZQByAFIAZQBsAGUAYQBzAGUAAAB6QwAADQAAAGsAUwBpAG4AQgBhAG4AawBOAG8AaQBzAGUAAAAAAP8BEAAAAHAAYQByAGEAbQBlAHQAZQByAHMAUwBxAHUAYQByAGUAAAAAAA0AAABrAFMAcQByAEEAbQBwAEEAdAB0AGEAYwBrAAAAoEAAAAsAAABrAFMAcQByAEEAbQBwAEgAbwBsAGQAAAAAAAAADgAAAGsAUwBxAHIAQQBtAHAAUgBlAGwAZQBhAHMAZQAAAPpDAAAAABAAAABrAFMAcQByAEYAaQBsAHQAZQByAEEAdAB0AGEAYwBrAAAAcEEAAAAADgAAAGsAUwBxAHIARgBpAGwAdABlAHIASABvAGwAZAAAAAAAAAAAABEAAABrAFMAcQByAEYAaQBsAHQAZQByAFIAZQBsAGUAYQBzAGUAAAB6QwAADQAAAGsAUwBxAHIAQgBhAG4AawBOAG8AaQBzAGUAAAAAAP8BEgAAAHAAYQByAGEAbQBlAHQAZQByAHMAVAByAGkAYQBuAGcAbABlAAAAAAANAAAAawBUAHIAaQBBAG0AcABBAHQAdABhAGMAawAAAKBAAAALAAAAawBUAHIAaQBBAG0AcABIAG8AbABkAAAAAAAAAA4AAABrAFQAcgBpAEEAbQBwAFIAZQBsAGUAYQBzAGUAAAD6QwAAAAAQAAAAawBUAHIAaQBGAGkAbAB0AGUAcgBBAHQAdABhAGMAawAAAHBBAAAAAA4AAABrAFQAcgBpAEYAaQBsAHQAZQByAEgAbwBsAGQAAAAAAAAAAAARAAAAawBUAHIAaQBGAGkAbAB0AGUAcgBSAGUAbABlAGEAcwBlAAAAekMAAA0AAABrAFQAcgBpAEIAYQBuAGsATgBvAGkAcwBlAAAAAAD/ARIAAABwAGEAcgBhAG0AZQB0AGUAcgBzAFMAYQB3AHQAbwBvAHQAaAAAAAAADQAAAGsAUwBhAHcAQQBtAHAAQQB0AHQAYQBjAGsAAACgQAAACwAAAGsAUwBhAHcAQQBtAHAASABvAGwAZAAAAAAAAAAOAAAAawBTAGEAdwBBAG0AcABSAGUAbABlAGEAcwBlAACAO0UAAAAAEAAAAGsAUwBhAHcARgBpAGwAdABlAHIAQQB0AHQAYQBjAGsAAABwQQAAAAAOAAAAawBTAGEAdwBGAGkAbAB0AGUAcgBIAG8AbABkAAAAAAAAAAAAEQAAAGsAUwBhAHcARgBpAGwAdABlAHIAUgBlAGwAZQBhAHMAZQAAgDtFAAANAAAAawBTAGEAdwBCAGEAbgBrAE4AbwBpAHMAZQAAAAAA/wEQAAAAcABhAHIAYQBtAGUAdABlAHIAcwBGAGkAbAB0AGUAcgAAAAAAEwAAAGsAUwBpAG4ARgBpAGwAdABlAHIARgByAGUAcQB1AGUAbgBjAHkAAACAPwAAEwAAAGsAUwBpAG4ARgBpAGwAdABlAHIAUgBlAHMAbwBuAGEAbgBjAGUAbxKDOgAAEwAAAGsAVAByAGkARgBpAGwAdABlAHIARgByAGUAcQB1AGUAbgBjAHkAAACAPwAAEwAAAGsAVAByAGkARgBpAGwAdABlAHIAUgBlAHMAbwBuAGEAbgBjAGUAbxKDOgAAEwAAAGsAUwBxAHIARgBpAGwAdABlAHIARgByAGUAcQB1AGUAbgBjAHkAMzNzPwAAEwAAAGsAUwBxAHIARgBpAGwAdABlAHIAUgBlAHMAbwBuAGEAbgBjAGUAbxKDOgAAEwAAAGsAUwBhAHcARgBpAGwAdABlAHIARgByAGUAcQB1AGUAbgBjAHkAAACAPwAAEwAAAGsAUwBhAHcARgBpAGwAdABlAHIAUgBlAHMAbwBuAGEAbgBjAGUAbxKDOv8BFQAAAHAAYQByAGEAbQBlAHQAZQByAHMAUwB0AGUAcgBlAG8ARABlAGwAYQB5AAAADAAAAGsARABlAGwAYQB5AFQAbwBnAGcAbABlAAAAgD8AAAAADgAAAGsARABlAGwAYQB5AEYAZQBlAGQAYgBhAGMAawDMzMw+AAAAABEAAABrAFMAdABlAHIAZQBvAEQAZQBsAGEAeQBMAFQAaQBtAGUAAAAQQQAAEQAAAGsAUwB0AGUAcgBlAG8ARABlAGwAYQB5AFIAVABpAG0AZQAAAABBAAAJAAAAawBEAGUAbABhAHkATQBpAHgAmZmZPgAAEgAAAGsAUwB0AGUAcgBlAG8ARABlAGwAYQB5AE8AZgBmAHMAZQB0AAAAQEAAAAAAEAAAAGsARABlAGwAYQB5AE0AbwBkAHUAbABhAHQAaQBvAG4AAAAAAP8BAAARAAAAcABhAHIAYQBtAGUAdABlAHIAcwBWAGkAYgByAGEAdABvAAAADgAAAGsAVgBpAGIAcgBhAHQAbwBUAG8AZwBnAGwAZQAAAIA/AAAAAA0AAABrAFYAaQBiAHIAYQB0AG8AUwBwAGUAZQBkAAAAAEAAAA0AAABrAFYAaQBiAHIAYQB0AG8ARABlAHAAdABoAJmZGT7//w==") ?? Data()
    ]

}

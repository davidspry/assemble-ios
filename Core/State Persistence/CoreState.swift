//  Assemble
//  Created by David Spry on 7/5/20.
//  Copyright © 2020 David Spry. All rights reserved.

import Foundation

struct CoreState {
    
    static var __PatternState: [[[NoteState?]]] =
    {
        let patterns = Int(PATTERNS)
        let W = Int(Assemble.patternWidth)
        let H = Int(Assemble.patternHeight)
        
        var state: [[[NoteState?]]] = Array.init(repeating: [], count: patterns)
        for pattern in 0 ..< patterns {
           let WArray = Array<NoteState?>.init(repeating: nil, count: W)
           let HArray = Array.init(repeating: WArray, count: H)
           state[pattern] = HArray
        }

        print(state)
        return state
    }()
    
    
    
    
}

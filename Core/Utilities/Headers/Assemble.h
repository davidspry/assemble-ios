//  Assemble
//  ============================
//  Created by David Spry on 9/4/20.
//  Copyright © 2020 David Spry. All rights reserved.

#pragma once
#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

FOUNDATION_EXPORT double ASMVersionNumber;
FOUNDATION_EXPORT const unsigned char ASMVersionString[];

// AudioUnit
#import "ASAudioUnit.h"
#import "ASAudioUnitBase.h"

// Synthesiser
#import "ASCommanderDSP.hpp"
#import "ASCommanderCore.hpp"

// Language interoperability
#import "ASInteroperability.h"
#import "ASParameters.h"
#import "ASConstants.h"

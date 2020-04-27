//  Assemble
//  ============================
//  Original author: David O'Neill.
//  Copyright 2018 AudioKit. All rights reserved.
//  License: <https://github.com/AudioKit/AudioKit/blob/master/LICENSE>

#pragma once

#ifdef __OBJC__

#define AS_SWIFT_TYPE __attribute((swift_newtype(struct)))

#else

#define AS_SWIFT_TYPE

#endif

typedef void* ASDSPRef  AS_SWIFT_TYPE;

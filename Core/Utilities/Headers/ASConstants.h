//  Assemble
//  ============================
//  Created by David Spry on 10/4/20.
//  Copyright © 2020 David Spry. All rights reserved.

#ifndef ASCONSTANTS_H
#define ASCONSTANTS_H

#define PI          3.1415926535
#define TWO_PI      6.2831853071
#define LN100       4.6051701859
#define LN20E3      9.9034875525

// ASSEMBLE LIGHT (IOS)
// ====================

#ifdef LIGHT
    // Synthesiser
    #define POLYPHONY        6
    #define OSCILLATORS      4

    // Sequencer
    #define PATTERNS         3
    #define SEQUENCER_WIDTH  8
    #define SEQUENCER_HEIGHT 16

    // Effects
    #define OVERSAMPLING     8

// ASSEMBLE (IPADOS)
// =================

#else
    // Synthesiser
    #define POLYPHONY        8
    #define OSCILLATORS      4

    // Sequencer
    #define PATTERNS         8
    #define SEQUENCER_WIDTH  16
    #define SEQUENCER_HEIGHT 16

    // Effects
    #define OVERSAMPLING     16

#endif
#endif

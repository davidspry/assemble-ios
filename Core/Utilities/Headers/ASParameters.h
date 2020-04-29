//  Assemble
//  Created by David Spry on 27/4/20.
//  Copyright © 2020 David Spry. All rights reserved.

#ifndef ASPARAMETERS_H
#define ASPARAMETERS_H

// PARAMETER ADDRESSES
// ===================

// [SEQUENCER] 0xAA0[Parameter]
// ===========================================
static const int kSequencerLength         = 0xAA01;
static const int kSequencerCurrentRow     = 0xAA02;
static const int kSequencerCurrentPattern = 0xAA03;
static const int kSequencerMode           = 0xAA04;

// [CLOCK] 0xCA0[Parameter]
// ===========================================
static const int kClockBPM                = 0xCA01;
static const int kClockSubdivision        = 0xCA02;

// [FILTERS] 0xF[Filter][Osc][Parameter]
// ===========================================
// Huovilainen Lowpass Filter: 0xF0[Osc][Parameter]
static const int kFrequencyType           = 0xF000;
static const int kResonanceType           = 0xF001;

static const int kSinFilterFrequency      = 0xF010;
static const int kSinFilterResonance      = 0xF011;

static const int kTriFilterFrequency      = 0xF020;
static const int kTriFilterResonance      = 0xF021;

static const int kSqrFilterFrequency      = 0xF030;
static const int kSqrFilterResonance      = 0xF031;

static const int kSawFilterFrequency      = 0xF040;
static const int kSawFilterResonance      = 0xF041;
// ===========================================

// [ENVELOPES]
// ===========================================
// Amplitude: 0xAE[Osc][Parameter]
static const int kSinAmpAttack            = 0xAE10;
static const int kSinAmpHold              = 0xAE11;
static const int kSinAmpRelease           = 0xAE12;

static const int kTriAmpAttack            = 0xAE20;
static const int kTriAmpHold              = 0xAE21;
static const int kTriAmpRelease           = 0xAE22;

static const int kSqrAmpAttack            = 0xAE30;
static const int kSqrAmpHold              = 0xAE31;
static const int kSqrAmpRelease           = 0xAE32;

static const int kSawAmpAttack            = 0xAE40;
static const int kSawAmpHold              = 0xAE41;
static const int kSawAmpRelease           = 0xAE42;

// Filter:    0xFE[Osc][Parameter]
static const int kSinFilterAttack         = 0xFE10;
static const int kSinFilterHold           = 0xFE11;
static const int kSinFilterRelease        = 0xFE12;

static const int kTriFilterAttack         = 0xFE20;
static const int kTriFilterHold           = 0xFE21;
static const int kTriFilterRelease        = 0xFE22;

static const int kSqrFilterAttack         = 0xFE30;
static const int kSqrFilterHold           = 0xFE31;
static const int kSqrFilterRelease        = 0xFE32;

static const int kSawFilterAttack         = 0xFE40;
static const int kSawFilterHold           = 0xFE41;
static const int kSawFilterRelease        = 0xFE42;
// ===========================================

// [EFFECTS] 0xEF[Effect][Parameter
// ===========================================
// Delay Line
static const int kDelayToggle             = 0xEF10;
static const int kDelayFeedback           = 0xEF11;
static const int kDelayTimeInMs           = 0xEF12;
static const int kDelayMusicalTime        = 0xEF13;
static const int kDelayMix                = 0xEF14;

// Stereo Delay
static const int kStereoDelayLTime        = 0xEF20;
static const int kStereoDelayRTime        = 0xEF21;

// Vibrato
static const int kVibratoToggle           = 0xEF30;
static const int kVibratoSpeed            = 0xEF31;
static const int kVibratoDepth            = 0xEF32;
// ===========================================

// DISCRETE PARAMETERS
// ===================

// Delay Line: Musical Time Factors
static const float fDelayWholeNote        = 4.000F;
static const float fDelayHalfDotted       = 2.500F;
static const float fDelayHalfNote         = 2.500F;
static const float fDelayQuarterDotted    = 2.500F;
static const float fDelayQuarterNote      = 2.500F;
static const float fDelayEighthDotted     = 2.500F;
static const float fDelayEighthNote       = 2.500F;
static const float fDelaySixteenthDotted  = 2.500F;
static const float fDelaySixteenthNote    = 2.500F;

#endif

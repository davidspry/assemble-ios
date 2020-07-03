//  Assemble
//  Created by David Spry on 10/5/20.
//  Copyright © 2020 David Spry. All rights reserved.

#ifndef WAVETABLETYPE_HPP
#define WAVETABLETYPE_HPP

#include "ASSawtoothTable.h"
#include "ASTriangleTable.h"
#include "ASSquareTable.h"
#include "ASSineTable.h"

/// \brief A set of constants to be used for the purpose of constructing a
/// bandlimited wavetable oscillator, as in `BandlimitedOscillator<WaveTableType>`

enum WaveTableType { SIN, SQR, TRI, SAW };

// ===================================================== //
// =============== Template declaration ================ //
// ===================================================== //

/// \brief A collection of bandlimited wavetables to be used with a BandlimitedOscillator.

template <WaveTableType W>
struct WaveTable
{
public:
    /// \brief Return the length of the wavetable.
    
    const int length();
    
    /// \brief Return a pointer to the selected wavetable
    
    const float * table();
    
    /// \brief Select the wavetable with the greatest number of
    /// overtones that won't produce aliasing at 44.1kHz.

    void select(const float frequency)
    {
        if      (frequency > 10240.F) tableIndex = 9;
        else if (frequency > 5120.F ) tableIndex = 8;
        else if (frequency > 2560.F ) tableIndex = 7;
        else if (frequency > 1280.F ) tableIndex = 6;
        else if (frequency > 640.F  ) tableIndex = 5;
        else if (frequency > 320.F  ) tableIndex = 4;
        else if (frequency > 160.F  ) tableIndex = 3;
        else if (frequency > 80.F   ) tableIndex = 2;
        else if (frequency > 40.F   ) tableIndex = 1;
        else                          tableIndex = 0;
    }

private:
    /// \brief The currently selected wavetable index

    int tableIndex = 0;
};

// ===================================================== //
// ============== Template implementation ============== //
// ===================================================== //

template <> inline const int WaveTable<SIN>::length() { return kSineTableLength;     }
template <> inline const int WaveTable<SQR>::length() { return kSquareTableLength;   }
template <> inline const int WaveTable<TRI>::length() { return kTriangleTableLength; }
template <> inline const int WaveTable<SAW>::length() { return kSawtoothTableLength; }

template <> inline const float * WaveTable<SIN>::table() { return &(wt_sine[0]);                 }
template <> inline const float * WaveTable<SQR>::table() { return &(wt_square[tableIndex][0]);   }
template <> inline const float * WaveTable<TRI>::table() { return &(wt_triangle[tableIndex][0]); }
template <> inline const float * WaveTable<SAW>::table() { return &(wt_sawtooth[tableIndex][0]); }

#endif

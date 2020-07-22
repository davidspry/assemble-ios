//  Assemble
//  Created by David Spry on 20/4/20.
//  Copyright © 2020 David Spry. All rights reserved.

#ifndef NOTE_HPP
#define NOTE_HPP

#include "ASHeaders.h"

struct Note
{
    Note() {}
    
    /// @brief Construct a Note with the given position, pitch, and oscillator index.
    /// @param x: The x-coordinate of the Note.
    /// @param y: The x-coordinate of the Note.
    /// @param note: The MIDI note number of the Note's pitch.
    /// @param shape: The Note's oscillator index.
    
    Note(int x, int y, int note, int shape)
    {
        modify(x, y, note, shape);
    }

    /// @brief Modify the Note's properties.
    /// @param x: The x-coordinate of the Note.
    /// @param y: The x-coordinate of the Note.
    /// @param note: The MIDI note number of the Note's pitch.
    /// @param shape: The Note's oscillator index.

    void modify(int x, int y, int note, int shape)
    {
        this->x = x;
        this->y = y;
        this->note = note;
        this->shape = shape;
        this->null = false;
    }
    
    
    /// @brief Encode a Note as an ASCII string.
    /// Each representation begins with '~' and encodes each attribute as one character
    /// following the order: <number of attributes>, <x>, <y>, <note>, <shape>.
    /// The character 0 is interpreted as a null terminator, which will cause the string
    /// to terminate early when it's converted to a C string. In order to avoid this, each
    /// value begins from 1. 1 must be subtracted during the decoding phase in order to
    /// yield the correct value.
    ///
    /// @note Given that the separator character is `~`, which is equivalent to decimal 126,
    /// the range of values that can be encoded in this fashion is [0, 124].

    std::string repr()
    {
        std::string state;
        state.reserve(9);

        state += '~';
        state += static_cast<char>(4);
        state += static_cast<char>(1 + x);
        state += static_cast<char>(1 + y);
        state += static_cast<char>(1 + note);
        state += static_cast<char>(1 + shape);
        
        return state;
    }

    /// @brief The x-coordinate of the Note.
    
    int x = 0;
    
    /// @brief The y-coordinate of the Note.
    
    int y = 0;
    
    /// @brief The MIDI note number of the Note's pitch.
    
    int note  = 64;
    
    /// @brief The Note's oscillator index.
    
    int shape = 0;
    
    /// @brief Whether the Note should be treated as null or not.

    bool null = true;
};

#endif

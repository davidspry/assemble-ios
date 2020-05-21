//  Assemble
//  Created by David Spry on 20/4/20.
//  Copyright © 2020 David Spry. All rights reserved.

#ifndef NOTE_HPP
#define NOTE_HPP

#include "ASHeaders.h"

struct Note
{
    Note ()
    {
        null = true;
    }
    
    Note (int x, int y, int note, int shape)
    {
        modify(x, y, note, shape);
    }

    void modify(int x, int y, int note, int shape)
    {
        this->x = x;
        this->y = y;
        this->note = note;
        this->shape = shape;
        this->null = false;
    }
    
    
    /// \brief Encode a Note as an ASCII string.
    /// Each representation begins with '#' and encodes each attribute as one character
    /// following the order: <number of attributes>, <x>, <y>, <note>, <shape>.
    /// The character 0 is interpreted as a null terminator, which will cause the string
    /// to terminate early when it's converted to a C string. In order to avoid this, each
    /// value begins from 1. 1 must be subtracted during the decoding phase in order to
    /// yield the correct value.
    /// \note This naturally limits the capacity of each attribute to 128 values.
    /// However, decoding attributes of this size is straight-forward, and moving to a
    /// larger character set would not break prior saves.

    std::string repr()
    {
        std::string state;
        state.reserve(9);

        state += '#';
        state += static_cast<char>(4);
        state += static_cast<char>(1 + x);
        state += static_cast<char>(1 + y);
        state += static_cast<char>(1 + note);
        state += static_cast<char>(1 + shape);

        return state;
    }

    int x, y;
    int note;
    int shape;
    bool null;
};

#endif

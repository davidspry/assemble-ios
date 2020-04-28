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
    
    int x, y;
    int note;
    int shape;

    bool null;
};

#endif

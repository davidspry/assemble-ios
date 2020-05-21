//  Assemble
//  Created by David Spry on 20/4/20.
//  Copyright © 2020 David Spry. All rights reserved.

#include "Pattern.hpp"

void Pattern::setTimeSignature(const int value, const bool beats)
{
    if (value < 1 || value > 7) { return; }
    
    if (beats)
    {
        this->h     = value * ticks;
        this->beats = value;
    }
    
    else
    {
        this->h     = value * this->beats;
        this->ticks = value;
    }
}

typedef std::vector<Note>::iterator iterator;
std::pair<int, iterator&> Pattern::window(int x, int y)
{
    auto window = pattern.window(x, y);
    auto length = pattern.lengthOfRow(y);
    
    return {length, window};
}

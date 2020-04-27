//  Assemble
//  Created by David Spry on 20/4/20.
//  Copyright © 2020 David Spry. All rights reserved.

#include "Pattern.hpp"

Pattern::Pattern()
{
    w = SEQUENCER_WIDTH;
    h = SEQUENCER_WIDTH;
    beats = 4;
    ticks = 4;
    active = false;
}

void Pattern::setTimeSignature(int beats, int subdivision)
{
    if (beats < 1 || beats > 7) { return; }
    if (subdivision < 1 || subdivision > 7) { return; }
    
    this->h = beats * subdivision;
    this->beats = beats;
    this->ticks = subdivision;
}

void Pattern::erase(int x, int y)
{
    pattern.erase(x, y);
}

typedef std::vector<Note>::iterator iterator;
std::pair<int, iterator&> Pattern::window(int x, int y)
{
    auto window = pattern.window(x, y);
    auto length = pattern.lengthOfRow(y);
    
    return {length, window};
}

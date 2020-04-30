//  Assemble
//  Created by David Spry on 20/4/20.
//  Copyright © 2020 David Spry. All rights reserved.

#ifndef PATTERN_HPP
#define PATTERN_HPP

#include "Note.hpp"
#include "Matrix.hpp"
#include "ASHeaders.h"
#include "ASConstants.h"

class Pattern
{
public:
    Pattern() {};

public:
    int width()  { return w; }
    int length() { return h; }
    void setTimeSignature(int, int);
    std::pair<int,int> getTimeSignature() { return {beats, ticks}; }

public:
    inline const bool toggle()   { return (active = !active); }
    inline const bool isActive() { return active; }
    
public:
    void erase(int, int);
    template <typename ...N>
    void make(int x, int y, N... note)
    {
        pattern.include(x, y, note...);
    }
    
public:
    typedef std::vector<Note>::iterator iterator;
    std::pair<int, iterator&> window(int, int);

private:
    Matrix <SEQUENCER_WIDTH, SEQUENCER_WIDTH> pattern;

private:
    int h = SEQUENCER_WIDTH;
    int w = SEQUENCER_WIDTH;
    int beats = 4;
    int ticks = 4;
    bool active = true;
};

#endif

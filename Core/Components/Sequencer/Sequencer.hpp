//  Assemble
//  Created by David Spry on 20/4/20.
//  Copyright © 2020 David Spry. All rights reserved.

#ifndef SEQUENCER_HPP
#define SEQUENCER_HPP

#include "ASParameters.h"
#include "ASHeaders.h"
#include "Pattern.hpp"

class Sequencer
{
public:
    Sequencer();

public:
    const float get(uint64_t parameter);
    
public:
    template <typename ...N>
    void addOrModify(int x, int y, N... note)
    {
        patterns.at(pattern).make(x, y, note...);
    }

    void erase(const int x, const int y) { patterns.at(pattern).erase(x, y); }

public:
    void reset()   { row =  0; }
    void prepare() { row = -1; }
    void toggle()  { mode = !mode; }
    std::pair<int,int> state() { return {row, pattern}; }

public:
    int length() { return patternLength; }
    int currentRow() { return row; }
    int currentPattern() { return pattern; }

public:
    typedef std::vector<Note>::iterator iterator;
    std::pair<int, iterator&> nextRow();
    void selectNextActivePattern();
    void selectPattern(const int);
    
private:
    std::vector<Pattern> patterns;
    
private:
    int row = 0;
    int pattern = 0;
    int patternLength;
    int activePatterns = 1;
    bool mode = 0;
};

#endif

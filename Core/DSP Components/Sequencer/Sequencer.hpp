//  Assemble
//  Created by David Spry on 20/4/20.
//  Copyright © 2020 David Spry. All rights reserved.

#ifndef SEQUENCER_HPP
#define SEQUENCER_HPP

#include "ASParameters.h"
#include "ASUtilities.h"
#include "ASHeaders.h"
#include "Pattern.hpp"

class Sequencer
{
public:
    Sequencer();

public:
    /// \brief Set a parameter value. If the parameter does not exist, nothing will happen.
    /// \param parameter The address of the parameter to set
    /// \param value The value to be set
    void set(uint64_t parameter, float value);

    /// \brief Return a parameter value. If the parameter does not exist, 0 will be returned.
    /// \param parameter The address of the parameter whose parameter should be returned.
    const float get(uint64_t parameter);

public:
    template <typename ...N>
    void addOrModify(int x, int y, N... note)
    {
        patterns.at(pattern).make(x, y, note...);
    }

    template <typename ...N>
    void addOrModifyNonCurrent(const int pattern, N... note)
    {
        patterns.at(pattern).make(note...);
    }

    void erase(const int x, const int y) { patterns.at(pattern).erase(x, y); }

public:
    void reset() { row =  0; }
    void prepare();
    void hardReset();
    void hardReset(const int pattern)
    {
        const auto active = patterns.at(pattern).isActive();
        patterns.at(pattern).clear();
        activePatterns = activePatterns - (active ? 1 : 0);
    }
    
    const bool toggle() { return (mode = !mode); }
    std::pair<int,int> state() { return {row, pattern}; }

public:
    int length() { return patternLength; }
    int currentRow() { return row; }
    int currentPattern() { return pattern; }

public:
    typedef std::vector<Note>::iterator iterator;
    std::pair<int, iterator&> nextRow();
    
private:
    int  findAndSelectFirstActivePattern();
    void selectNextActivePattern();
    void selectPattern(const int);
    
private:
    std::vector<Pattern> patterns;
    
private:
    int row = 0;
    int pattern = 0;
    int nextPattern = 0;
    int patternLength;
    int activePatterns = 1;
    bool mode = 1;
    
friend class ASCommanderCore;
};

#endif

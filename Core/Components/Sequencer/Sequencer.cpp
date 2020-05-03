//  Assemble
//  Created by David Spry on 20/4/20.
//  Copyright © 2020 David Spry. All rights reserved.

#include "Sequencer.hpp"

Sequencer::Sequencer()
{
    patterns.resize(PATTERNS);
    
    auto &firstPattern = patterns[pattern];
    patternLength = firstPattern.length();
    activePatterns = static_cast<int>(firstPattern.toggle() == true);
}

/// \brief Set a value for a Sequencer parameter
/// \param parameter The hexadecimal address of the parameter to set
/// \param value The value to be set

void Sequencer::set(uint64_t parameter, float value)
{
    switch (parameter)
    {
        case kSequencerMode:
        {
            mode = static_cast<bool>(value);
            return;
        }

        case kSequencerCurrentPattern:
        {
            const int pattern = Assemble::Utilities::bound(value, 0, PATTERNS - 1);
            selectPattern(pattern);
            return;
        }
            
        case kSequencerPatternState:
        {
            const int pattern = Assemble::Utilities::bound(value, 0, PATTERNS - 1);
            const bool active = patterns.at(pattern).toggle();
            activePatterns = activePatterns + (active ? 1 : -1);
            printf("Active patterns: %d\n", activePatterns);
            return;
        }

        default: return;
    }
}

/// \brief Get a parameter value from the Sequencer
/// \param parameter The hexadecimal address of the desired parameter

const float Sequencer::get(uint64_t parameter)
{
    switch (parameter)
    {
        case kSequencerMode: return (float) mode;
        case kSequencerLength: return (float) patternLength;
        case kSequencerCurrentRow: return (float) row;
        case kSequencerCurrentPattern: return (float) pattern;
        case kSequencerPatternState: return (float) patterns.at(pattern).isActive();
        default: return 0.F;
    }
}

typedef std::vector<Note>::iterator iterator;
std::pair<int, iterator&> Sequencer::nextRow()
{
    row = std::min(row, patternLength - 1);

    if (mode && (row + 1) == patternLength)
    {
        selectNextActivePattern();
        printf("Selected Pattern %d\n", pattern);
        row = 0;
    }

    else   row = (row + 1) % patternLength;
    
    return patterns.at(pattern).window(0, row);
}

void Sequencer::prepare()
{
    if (mode && !patterns[pattern].isActive())
        selectNextActivePattern();

    row = -1;
}

void Sequencer::selectPattern(const int pattern) noexcept(false)
{
    if (pattern < 0 || pattern >= PATTERNS)
        throw "Invalid Pattern index";
    
    this->pattern = pattern;
    this->patternLength = patterns.at(pattern).length();
}

void Sequencer::selectNextActivePattern()
{
    if (activePatterns == 0)
        return toggle();
    
    int p = pattern;
    for (int i = 0; i < PATTERNS; ++i)
    {
        p = (p + 1) % PATTERNS;
        if (patterns.at(p).isActive()) break;
    }

    selectPattern(p);
}

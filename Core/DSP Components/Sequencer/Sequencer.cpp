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

void Sequencer::hardReset()
{
    row = 0;
    pattern = 0;
    activePatterns = 0;
    for (size_t i = 0; i < PATTERNS; ++i)
        patterns.at(i).clear();
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

        case kSequencerNextPattern:
        {
            const int pattern = Assemble::Utilities::bound(value, 0, PATTERNS - 1);
            nextPattern = pattern;
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
            
        case kSequencerTicks: return patterns.at(pattern).setTimeSignature(value, static_cast<bool>(0));
        case kSequencerBeats: return patterns.at(pattern).setTimeSignature(value, static_cast<bool>(1));
        default: return;
    }
}

/// \brief Get a parameter value from the Sequencer
/// \param parameter The hexadecimal address of the desired parameter

const float Sequencer::get(uint64_t parameter)
{
    switch (parameter)
    {
        case kSequencerMode:           return (float) mode;
        case kSequencerLength:         return (float) patternLength;
        case kSequencerCurrentRow:     return (float) row;
        case kSequencerCurrentPattern: return (float) pattern;
        case kSequencerFirstActive:    return (float) findAndSelectFirstActivePattern();
        case kSequencerNextPattern:    return (float) nextPattern;
        case kSequencerPatternState:   return (float) patterns.at(pattern).isActive();
        case kSequencerBeats:          return (float) patterns.at(pattern).getTimeSignature().first;
        case kSequencerTicks:          return (float) patterns.at(pattern).getTimeSignature().second;
        default: return 0.F;
    }
}

/// \brief Move to the next row, which may be on another Pattern,
/// and return the next row of notes.
/// \returns A std::pair containing the number of notes in the current row
/// and a reference to an iterator over the next row of notes.

std::pair<int, iterator> Sequencer::nextRow()
{
    row = std::min(row, patternLength - 1);
    
    if ((row + 1) == patternLength)
    {
        row = 0;
        if (mode && pattern == nextPattern)
            selectNextActivePattern();

        else
            selectPattern(nextPattern);
    }

    else   row = (row + 1) % patternLength;
    
    return patterns.at(pattern).window(0, row);
}

/// \brief Prepare the sequencer to play
/// \note  If the sequencer is in song mode but the current
/// pattern isn't active, then the next active pattern should be selected.
/// If there are no active patterns, pattern mode should be enabled.

void Sequencer::prepare()
{
    if (mode && !patterns[pattern].isActive())
        selectNextActivePattern();

    row = -1;
}

/// \brief Select a pattern immediately.
/// \note This method will throw in the case where an invalid pattern index is given.

void Sequencer::selectPattern(const int pattern) noexcept(false)
{
    if (this->pattern == pattern) return;

    if (pattern < 0 || pattern >= PATTERNS)
        throw "Invalid Pattern index";

    this->pattern = pattern;
    this->nextPattern = pattern;
    this->patternLength = patterns.at(pattern).length();
}

/// \brief Select the first active pattern then return the pattern index.

int Sequencer::findAndSelectFirstActivePattern()
{
    selectNextActivePattern();
    
    return pattern;
}

/// \brief Select the next active pattern.
/// Beginning from the current pattern, search each of the sequencer's
/// patterns linearly until an active pattern has been found.
/// If no other active patterns are found, then the current pattern
/// will be selected again. If there are no active patterns, then
/// pattern mode will be selected.

void Sequencer::selectNextActivePattern()
{
    if (activePatterns == 0) { toggle(); return; }

    int p = pattern;
    for (int i = 0; i < PATTERNS; ++i)
    {
        p = (p + 1) % PATTERNS;
        if (patterns.at(p).isActive()) break;
    }

    selectPattern(p);
}

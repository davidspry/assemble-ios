//  Assemble
//  Created by David Spry on 20/4/20.
//  Copyright © 2020 David Spry. All rights reserved.

#include "Sequencer.hpp"

void Sequencer::set(uint64_t parameter, float value)
{
    switch (parameter)
    {
        case kSequencerMode:
        {
            isSongMode = static_cast<bool>(value);
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
            printf("[Sequencer] Active patterns: %d\n", activePatterns);
            return;
        }
            
        case kSequencerTicks: return patterns.at(pattern).setTimeSignature(value, static_cast<bool>(0));
        case kSequencerBeats: return patterns.at(pattern).setTimeSignature(value, static_cast<bool>(1));
        default: return;
    }
}

const float Sequencer::get(uint64_t parameter)
{
    switch (parameter)
    {
        case kSequencerMode:           return (float) isSongMode;
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

std::pair<int, iterator> Sequencer::nextRow()
{
    row = std::min(row, patternLength - 1);

    if ((row + 1) == patternLength)
    {
        row = 0;
        if (isSongMode && pattern == nextPattern && patterns.at(pattern).advance())
            selectNextActivePattern();

        else if (pattern != nextPattern)
        {
            selectPattern(nextPattern);
            patterns.at(pattern).resetRepeatCounter();
        }
    }

    else   row = (row + 1) % patternLength;

    return patterns.at(pattern).window(0, row);
}

void Sequencer::selectPattern(const int pattern) noexcept(false)
{
    if (this->pattern == pattern) return;

    if (pattern < 0 || pattern >= PATTERNS)
        throw "[Sequencer] Invalid pattern index.";

    this->pattern = pattern;
    this->nextPattern = pattern;
    this->patternLength = patterns.at(pattern).length();
}

void Sequencer::selectNextActivePattern()
{
    if (activePatterns == 0) { toggleMode(); return; }

    int p = pattern;
    for (size_t i = 0; i < PATTERNS; ++i)
    {
        p = (p + 1) % PATTERNS;
        if (patterns.at(p).isActive()) break;
    }

    selectPattern(p);
}

void Sequencer::copy(const int source, const int target)
{
    Pattern& s = patterns.at(source);
    Pattern& t = patterns.at(target);

    t.clear();
    t.setTimeSignature(s.getTimeSignature());
    
    for (size_t k = 0; k < s.length(); ++k)
    {
        const auto row = s.window(0, (int) k);
        std::vector<Note>::iterator notes = row.second;
        for (size_t i = 0; i < row.first; ++i)
        {
            const Note& note = *notes;
            t.include(note.x, note.y, note.note, note.shape);
            std::advance(notes, 1);
        }
    }
}

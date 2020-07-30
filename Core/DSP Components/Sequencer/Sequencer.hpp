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
    /// @brief Construct a sequencer and activate its first pattern.

    Sequencer()
    {
        patterns.resize((size_t) PATTERNS);
        Pattern & firstPattern = patterns[pattern];
        patternLength  = firstPattern.length();
        activePatterns = static_cast<int>(firstPattern.toggle() == true);
    }

    /// @brief Set a parameter value. If the parameter does not exist, nothing will happen.
    /// @param parameter The address of the parameter to set
    /// @param value The value to be set

    void set(uint64_t parameter, float value);

    /// @brief Return a parameter value. If the parameter does not exist, 0 will be returned.
    /// @param parameter The address of the parameter whose parameter should be returned.
    
    const float get(uint64_t parameter);

    /// @brief Prepare the sequencer to begin playback immediately.
    /// @note  If the current pattern is inactive, the next active pattern will be selected.
    ///        If no active pattern can be found, then pattern mode will be selected.

    inline void prepare()
    {
        if (isSongMode && !patterns[pattern].isActive())
            selectNextActivePattern();

        row = -1;
    }
    
    /// @brief Reset the sequencer's playhead position to 0.

    inline void reset()
    {
        row =  0;
    }

    /// @brief Clear and deactivate each pattern and reset the sequencer to its initial state.
    
    inline void hardReset()
    {
        row = 0;
        pattern = 0;
        activePatterns = 0;
        deleteCopiedPattern();
        for (size_t i = 0; i < PATTERNS; ++i)
            patterns.at(i).clear();
    }
    
    /// @brief Clear and deactivate the pattern with the given pattern index .
    /// @param pattern The index of the pattern to be cleared.
    
    inline void hardReset(const int pattern)
    {
        const bool active = patterns.at(pattern).isActive();
        activePatterns = activePatterns - (active ? 1 : 0);
        patterns.at(pattern).clear();
    }

    /// @brief Delete the Sequencer's copied pattern and set its pointer to nullptr.

    inline void deleteCopiedPattern()
    {
        delete copiedPattern;
        copiedPattern = nullptr;
    }
    
    /// @brief Set the Note at the given location to have the given properties.
    /// @param x The x-coordinate of the selected location
    /// @param y The y-coordinate of the selected location
    /// @param note A parameter pack containing the properties used to construct a new Note.
    
    template <typename ...N>
    inline void addOrModify(const int x, const int y, N... note)
    {
        patterns.at(pattern).include(x, y, note...);
    }

    /// @brief Set the Note at the given location to have the given properties.
    /// @param pattern The index of the pattern that should include the given Note.
    /// @param note A parameter pack containing the properties used to construct a new Note, including its location.

    template <typename ...N>
    inline void addOrModifyToPattern(const int pattern, N... note)
    {
        patterns.at(pattern).include(note...);
    }
    
    /// @brief Copy the state of the given source pattern into the Sequencer's spare Pattern.
    /// @param source The index of the pattern that should be copied.

    void copy(const int source);
    
    /// @brief Copy a previously copied Pattern state into the Pattern with the given index.
    /// @param target The index of the pattern whose state should be replaced with the previously copied state.
    /// @pre   A previously copied state exists. This can be ascertained using the method `copiedStateExists`.
    
    void paste(const int target);
    
    /// @brief Indicate whether a copied Pattern state exists and is accessible by the Sequencer.

    inline const bool copiedStateExists()
    {
        return copiedPattern != nullptr;
    }

    /// @brief Erase the contents of the given position, (x, y).
    /// @param x The x-coordinate of the position whose contents should be erased.
    /// @param y The y-coordinate of the position whose contents should be erased.

    inline void erase(const int x, const int y)
    {
        patterns.at(pattern).erase(x, y);
    }
    
    /// @brief Toggle between the sequencer's modes.

    const bool toggleMode()
    {
        return (isSongMode = !(isSongMode));
    }

    /// @brief Return a pair containing the current row and the current pattern index.

    inline std::pair<int, int> state()
    {
        return {row, pattern};
    }

    /// @brief Return the current pattern's length.

    inline const int length()
    {
        return patternLength;
    }
    
    /// @brief Return the sequencer's current row.

    inline const int currentRow()
    {
        return row;
    }
    
    /// @brief Return the index of the current pattern.
    
    inline const int currentPattern()
    {
        return pattern;
    }

    typedef std::vector<Note>::iterator iterator;
    
    /// @brief Move to the next row, which may be on another Pattern,
    /// and return the next row of notes.
    ///
    /// @returns A std::pair containing the number of notes in the current row
    /// and a reference to an iterator over the next row of notes.

    std::pair<int, iterator> nextRow();
    
private:

    /// @brief Select the first active pattern then return the pattern index.
    
    inline const int findAndSelectFirstActivePattern()
    {
        selectNextActivePattern();
        return pattern;
    }

    /// @brief Select the next active pattern.
    /// Beginning from the current pattern, search each of the sequencer's patterns linearly until an active pattern has been found.
    /// If no other active patterns are found, then the current pattern will be selected again. If there are no active patterns, then
    /// pattern mode will be selected.

    void selectNextActivePattern();
    
    /// \brief Select a pattern immediately.
    /// \note This method will throw in the case where an invalid pattern index is given.

    inline void selectPattern(const int pattern) noexcept(false);
    
private:
    std::vector<Pattern> patterns;
    Pattern*        copiedPattern;
    
private:
    int  row            = 0;
    int  pattern        = 0;
    int  nextPattern    = 0;
    int  patternLength  = 0;
    int  activePatterns = 1;
    bool isSongMode  = true;
    
friend class ASCommanderCore;
};

#endif

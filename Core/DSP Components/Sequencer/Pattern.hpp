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
    /// @brief Return the width of the Pattern
    
    inline const int width() noexcept
    {
        return W;
    }
    
    /// @brief Return the length of the Pattern
    
    inline const int length() noexcept
    {
        return H;
    }
    
    /// @brief Set the time signature of the pattern.
    /// @param beats The number of beats per bar.
    /// @param ticks The number of ticks per beat.

    inline void setTimeSignature(const int beats, const int ticks)
    {
        this->beats = beats;
        this->ticks = ticks;
        this->H     = beats * ticks;
    }
    
    /// @brief Set the time signature of the pattern.
    /// @param signature A std::pair containing the desired number of beats and ticks in that order.

    inline void setTimeSignature(const std::pair<int, int> signature)
    {
        this->beats = signature.first;
        this->ticks = signature.second;
        this->H     = beats * ticks;
    }

    /// @brief Return the time signature, (beats, ticks), as a std::pair

    inline std::pair<int,int> getTimeSignature() { return {beats, ticks}; }

public:
    /// @brief Toggle the on-off state of the Pattern
    /// @return The state of the Pattern after toggling
    
    inline const bool toggle()
    {
        return (active = !active);
    }
    
    /// @brief Return the on-off state of the Pattern
    
    inline const bool isActive()
    {
        return active;
    }
    
    /// @brief  Advance the pattern's counter and indicate whether it has repeated the specified number of times.
    /// @return `true` if the pattern has repeated the specified number of times, and `false` otherwise.

    inline const bool advance()
    {
        counter = counter + 1;
        counter = static_cast<int>(counter < repeats) * counter;

        return counter == 0;
    }
    
    /// @brief Reset the pattern's repeat counter.

    inline void resetRepeatCounter()
    {
        counter = 0;
    }
    
    /// @brief Set the on-off state of the Pattern explicitly.
    /// @param state The target state of the Pattern.

    inline void set(const bool state)
    {
        active = state;
    }

public:
    /// @brief Erase the contents of the underlying Matrix at position (x, y)
    /// @param x The x-coordinate of the target position
    /// @param y The y-coordinate of the target position

    inline void erase(int x, int y) { pattern.erase(x, y); }
    
    /// @brief Reset the Pattern to its initial state

    void clear()
    {
        active = false;
        pattern.reset();
        beats = ticks = 4;
    }
    
public:
    template <typename ...N>
    inline void include(int x, int y, N... note) {
        pattern.include(x, y, note...);
    }

private:
    /// @brief Return a reference to the Pattern's underlying std::vector<Note> for persistence purposes.
    /// This is intended for use exclusively by ASCommanderCore, which is a friend class.
    
    inline const std::vector<Note>& state()
    {
        return pattern.state();
    }
    
public:
    typedef std::vector<Note>::iterator iterator;

    /// @brief Return a "window" onto the Matrix at position (x, y), as well as
    /// the number of non-null Notes on the row `y`.
    /// @param x The x-coordinate of the desired position
    /// @param y The y-coordinate of the desired position
    /// @returns A std::pair containing the number of notes in the row
    /// and an iterator pointing to position (x, y).
    /// @note In order to retrieve a row in total, `x` should be 0.

    inline std::pair<int, iterator> window(const int x, const int y)
    {
        iterator  window = pattern.window(x, y);
        const int length = pattern.lengthOfRow(y);

        return {length, window};
    }

private:
    Matrix<SEQUENCER_WIDTH, SEQUENCER_WIDTH> pattern;

private:
    int W       = SEQUENCER_WIDTH;
    int H       = SEQUENCER_WIDTH;
    int beats   = 4;
    int ticks   = 4;
    int counter = 0;
    int repeats = 1;
    bool active = false;
    
friend class ASCommanderCore;
};

#endif

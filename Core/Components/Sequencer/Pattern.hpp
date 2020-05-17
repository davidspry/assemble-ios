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
    /// \brief Return the width of the Pattern
    
    inline int width() noexcept { return w; }
    
    /// \brief Return the length of the Pattern
    
    inline int length() noexcept { return h; }
    
    /// \brief Set the time signature of the pattern
    /// \param value The value to be set
    /// \param beats Whether the value represents the number of beats or the number of ticks per beat

    void setTimeSignature(const int value, const bool beats);

    /// \brief Return the time signature, (beats, ticks), as a std::pair

    inline std::pair<int,int> getTimeSignature() { return {beats, ticks}; }

public:
    /// \brief Toggle the on-off state of the Pattern
    /// \return The state of the Pattern after toggling
    
    inline const bool toggle()   { return (active = !active); }
    
    /// \brief Return the on-off state of the Pattern
    
    inline const bool isActive() { return active; }
    
    /// \brief Set the on-off state of the Pattern explicitly.
    /// \param state The target state of the Pattern.

    inline void set(const bool state)
    {
        active = state;
    }

public:
    /// \brief Erase the contents of the underlying Matrix at position (x, y)
    /// \param x The x-coordinate of the target position
    /// \param y The y-coordinate of the target position

    inline void erase(int x, int y) { pattern.erase(x, y); }
    
    /// \brief Reset the Pattern to its initial state

    void clear()
    {
        active = false;
        pattern.reset();
        beats = ticks = 4;
    }
    
public:
    template <typename ...N>
    inline void make(int x, int y, N... note) {
        pattern.include(x, y, note...);
    }

private:
    /// \brief Return a reference to the Pattern's underlying std::vector<Note> for persistence purposes.
    /// This is intended for use exclusively by ASCommanderCore, which is a friend class.
    
    inline const std::vector<Note>& state()
    {
        return pattern.state();
    }
    
public:
    typedef std::vector<Note>::iterator iterator;

    /// \brief Return a "window" onto the Matrix at position (x, y), as well as
    /// the number of non-null Notes on the row `y`.
    /// \param x The x-coordinate of the desired position
    /// \param y The y-coordinate of the desired position
    /// \returns A std::pair containing the number of notes in the row
    /// and an iterator pointing to position (x, y).
    /// \note In order to retrieve a row in total, `x` should be 0.

    std::pair<int, iterator&> window(int x, int y);

private:
    Matrix <SEQUENCER_WIDTH, SEQUENCER_WIDTH> pattern;

private:
    int h = SEQUENCER_WIDTH;
    int w = SEQUENCER_WIDTH;
    int beats = 4;
    int ticks = 4;
    bool active = false;
    
friend class ASCommanderCore;
};

#endif

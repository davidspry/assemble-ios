//  Assemble
//  ============================
//  Created by David Spry on 20/4/20.
//  Copyright © 2020 David Spry. All rights reserved.

#ifndef MATRIX_HPP
#define MATRIX_HPP

#include "ASHeaders.h"

/// \brief This structure represents an NxM matrix of Notes.
/// Notes can be pushed onto a row or erased from a row.

typedef std::vector<Note>::iterator iterator;

template <int N, int M>
class Matrix
{
public:
    Matrix()
    {
        length.assign(M, 0);
        vector.assign(N * M, Note());
    }

public:
    /// \brief Return a pointer to the Note at position (x, y) or nullptr if the note does not exist.
    /// The returned pointer should be treated as read-only.
    /// All modifications should be performed using the provided methods.
    /// \pre   A Note exists at position (x, y).
    /// \param x The column to lookup.
    /// \param y The row to lookup.

    const Note* at(int x, int y) const
    {
        if (!(exists(x, y)))
            return nullptr;
        
        return &(vector[find(x, y)]);
    }

    /// \brief Compute the underlying 1-D array index for the abstract 2-D matrix position, (x, y).
    /// \param x The column to lookup.
    /// \param y The row to lookup.
    
    inline int index(int x, int y) const
    {
        while (x < 0) x += w;
        while (y < 0) y += h;
        
        if (x > w || y > h)
            throw "[Matrix] (x,y) is beyond the bounds of the Matrix.";
        
        return x + y * w;
    }
    
    /// \brief Return the number of Notes at row y.
    /// \param y The row to lookup.

    const int lengthOfRow(int y) noexcept(false)
    {
        if (y > h) throw "[Matrix] Invalid row index.";
        
        while (y < 0) y += h;
        
        return length[y];
    }

    /// \brief Find the 1-D array index of the Note at the given position, (x, y).
    /// \param x The x-coordinate of the desired Note
    /// \param y The y-coordinate of the desired Note
    /// \return The index of the desired Note if it exists or -1 otherwise.

    const int find(const int x, const int y) const
    {
        const int length = this->length[y];
        if (length == 0) return -1;

        int index = this->index(0, y);
        for (int i = 0; i < length; ++i)
            if (vector[index].x == x &&
                vector[index].null == false)
                return index;
            else
                index = index + 1;

        return -1;
    }

    /// \brief Indicate whether an active Note exists at the given position, (x, y).
    /// \param x The x-coordinate of the position to check
    /// \param y The y-coordinate of the position to check

    const bool exists(const int x, const int y) const
    {
        const int length = this->length[y];
        if (length == 0) return false;
        
        int index = this->index(0, y);
        for (int i = 0; i < length; ++i)
            if (vector[index++].x == x)
                return true;
        
        return false;
    }

    /// \brief Set each Note on the given row to null and reset the length value for the given row.
    /// \param row The index of the row to be cleared

    inline void clearRow(const int row)
    {
        for (size_t i = 0; i < length[row]; ++i)
            vector[i].null = true;

        length[row] = 0;
    }
    
    /// \brief Reset the Matrix to its initial state with length[r] = 0 for each row, r.
    
    inline void reset()
    {
        for (int i = 0; i < M; ++i)
            clearRow(i);
    }

    /// \brief Include the Note defined by the given parameter pack at the given position, (x, y).
    /// \param x The x-coordinate of the position where the new Note should be added.
    /// \param y The y-coordinate of the position where the new Note should be added.
    /// \param arguments A variadic parameter pack defining the Note to be included.

    template <typename ...A>
    void include(int x, int y, A... arguments) noexcept(false)
    {
        if (y < 0 || y > M)  throw "[Matrix] Invalid row";
        if (length[y] >= N) throw "[Matrix] Row is full";
        
        int position = find(x, y);
        if (position == -1) {
            position = index(length[y], y);
            length[y] += 1;
        }

        vector[position].modify(x, y, arguments...);
    }

    /// \brief Erase the Note at the given position and decrement the length of its row.
    /// \param x The x-coordinate of the Note to be erased.
    /// \param y The y-coordinate of the Note to be erased.

    void erase(const int x, const int y)
    {
        const int row = index(0, y);
        const int note = find(x, y);
        const int length = this->length[y];
        if (note != -1) {
            vector.at(note).null = true;
            swap(note, row + length - 1);
            this->length[y] -= 1;
        }
    }

    /// \brief Return an iterator at position (x, y). This is useful for reading a row.
    /// \param x The column of the window
    /// \param y The row of the window
    
    iterator window(int x, int y)
    {
        return vector.begin() + index(x, y);
    }

    /// \brief Return a const reference to the underlying vector.
    /// This is useful for persisting data from a higher layer.
    
    const std::vector<Note>& state()
    {
        return vector;
    }

private:
    /// \brief Swap the contents of the underlying vector at the given indices, a & b.
    ///        i.e., vector[b] = vector[a] and vector[a] = vector[b]
    /// \param a The index of the first element
    /// \param b The index of the second element

    void swap(const int a, const int b)
    {
        Note T = vector[a];
        vector[a] = vector[b];
        vector[b] = T;
    }

private:
    std::vector<Note> vector;
    std::vector<int>  length;

public:
    int w = N;
    int h = M;
};

#endif

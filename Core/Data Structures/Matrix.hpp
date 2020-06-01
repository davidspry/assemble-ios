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
        vector.assign(N * M, Note());
        lengths.assign(N, 0);
    }

public:
    /// \brief Return a reference to the Note at position (x, y).
    /// The returned reference should be treated as read-only.
    /// All modifications should be performed using the provided methods.
    /// \param x The column to lookup.
    /// \param y The row to lookup.

    const Note& at(int x, int y) const
    {
        return vector[find(x, y)];
    }
    
    /// \brief Compute the underlying 1-D array index for the abstract 2-D matrix position, (x, y).
    /// \param x The column to lookup.
    /// \param y The row to lookup.
    
    inline int index(int x, int y) const
    {
        while (x < 0) x += w;
        while (y < 0) y += h;
        
        if (x > w || y > h)
            throw "(x,y) is beyond the bounds of the Matrix.";
        
        return x + y * w;
    }
    
    /// \brief Return the number of Notes at row y.
    /// \param y The row to lookup.

    int lengthOfRow(int y) noexcept(false)
    {
        if (y > h) throw "Invalid row index.";
        
        while (y < 0) y += h;
        
        return lengths[y];
    }

    int find(const int x, const int y) const
    {
        const int length = lengths[y];
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

    bool exists(const int x, const int y)
    {
        const int length = lengths[y];
        if (length == 0) return false;
        
        int index = this->index(0, y);
        for (int i = 0; i < length; ++i)
            if (vector[index++].x == x)
                return true;
        
        return false;
    }

    void clearRow(const int row)
    {
        for (size_t i = 0; i < lengths[row]; ++i)
            vector[i].null = true;

        lengths[row] = 0;
    }
    
    void reset()
    {
        vector.assign(N * M, Note());
        for (int i = 0; i < N; ++i)
            lengths[i] = 0;
    }

    template <typename ...A>
    void include(int x, int y, A... arguments) noexcept(false)
    {
        if (y < 0 || y > M)  throw "[Matrix] Invalid row";
        if (lengths[y] >= M) throw "[Matrix] Row is full";
        
        int position = find(x, y);
        if (position == -1) {
            position = index(lengths[y], y);
            lengths[y] += 1;
        }

        vector[position].modify(x, y, arguments...);
    }

    void erase(const int x, const int y)
    {
        const int row = index(0, y);
        const int note = find(x, y);
        const int length = lengths[y];
        if (note != -1) {
            vector.at(note).null = true;
            swap(note, row + length - 1);
            lengths[y] -= 1;
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
    void swap(const int a, const int b)
    {
        Note T = vector[a];
        vector[a] = vector[b];
        vector[b] = T;
    }

private:
    std::vector<Note> vector;
    std::vector<int> lengths;

public:
    int w = N;
    int h = M;
};

#endif

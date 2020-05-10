//  Assemble
//  ============================
//  Created by David Spry on 20/4/20.
//  Copyright © 2020 David Spry. All rights reserved.

#ifndef MATRIX_HPP
#define MATRIX_HPP

#include "ASHeaders.h"

// ===================================================== //
// =============== Template declaration ================ //
// ===================================================== //

/// \brief This structure represents an NxM matrix of Notes.
/// Notes can be pushed onto a row or erased from a row.

typedef std::vector<Note>::iterator iterator;

template <int N, int M>
class Matrix
{
public:
    Matrix();

public:
    /// \brief Return a const reference to the Note at position (x, y).
    /// The returned reference should be treated as read-only.
    /// All modifications should be performed using the provided methods.
    /// \param x The column to lookup.
    /// \param y The row to lookup.
    const Note& at(int x, int y) const;
    
    /// \brief Compute the underlying 1-D array index for the abstract 2-D matrix position, (x, y).
    /// \param x The column to lookup.
    /// \param y The row to lookup.
    inline int index(int x, int y) const;
    
    /// \brief Return the number of Notes at row y.
    /// \param y The row to lookup.
    int lengthOfRow(int y) noexcept(false);
    
    
    int find(int, int);
    
    
    bool exists(int, int);
    
    
    void clearRow(int);

    
    void reset();
    
public:
    template <typename ...A>
    void include(int, int, A...) noexcept(false);
    void erase(int, int);
    
public:
    /// \brief Return an iterator at position (x, y). This is useful for reading a row.
    /// \param x The column of the window
    /// \param y The row of the window
    iterator window(int x, int y);

    /// \brief Return a const reference to the underlying vector.
    /// This is useful for persisting data from a higher layer.
    const std::vector<Note>& state() { return vector; }

private:
    void swap(int, int);

private:
    std::vector<Note> vector;
    std::vector<int> lengths;

public:
    int w = N;
    int h = M;
};

// ===================================================== //
// ============== Template implementation ============== //
// ===================================================== //

template <int N, int M>
Matrix<N,M>::Matrix()
{
    vector.assign(N*M, Note());
    lengths.assign(N, 0);
}

template <int N, int M>
const Note& Matrix<N,M>::at(int x, int y) const
{
    return vector[index(x,y)];
}

template <int N, int M>
int Matrix<N,M>::index(int x, int y) const
{
    while (x < 0) x += w;
    while (y < 0) y += h;
    
    if (x > w || y > h)
        throw "(x,y) is beyond the bounds of the Matrix.";
    
    return x + y * w;
}

template <int N, int M>
int Matrix<N,M>::lengthOfRow(int y) noexcept(false)
{
    if (y > h) throw "Invalid row index.";
    
    while (y < 0) y += h;
    
    return lengths[y];
}

template <int N, int M>
int Matrix<N,M>::find(int x, int y)
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

template <int N, int M>
bool Matrix<N,M>::exists(int x, int y)
{
    const int length = lengths[y];
    if (length == 0) return false;
    
    int index = this->index(0, y);
    for (int i = 0; i < length; ++i)
        if (vector[index++].x == x)
            return true;
    
    return false;
}

template <int N,  int M>
template <typename ...A>
void Matrix<N,M>::include(int x, int y, A... arguments) noexcept(false)
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

template <int N, int M>
void Matrix<N,M>::swap(int a, int b)
{
    Note T = vector[a];
    vector[a] = vector[b];
    vector[b] = T;
}

template <int N, int M>
void Matrix<N,M>::erase(int x, int y)
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

template <int N, int M>
void Matrix<N,M>::clearRow(int row)
{
    for (size_t i = 0; i < lengths[row]; ++i)
        vector[i].null = true;

    lengths[row] = 0;
}

template <int N, int M>
void Matrix<N,M>::reset()
{
    vector.assign(N*M, Note());
    for (int i = 0; i < N; ++i)
        lengths[i] = 0;
}

template <int N, int M>
iterator Matrix<N,M>::window(int x, int y)
{
    return vector.begin() + index(x, y);
}

#endif

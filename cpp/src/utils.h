/*
 * This code is distributed under the GNU Affero General Public License
 * Version 3 - the same as MIRACL. See the included file LICENSE in the root
 * directory.
 */

#ifndef UTILS_H
#define UTILS_H

#include <cmath>
#include <cstdlib>

template <class T>
T fmax(T *elems, size_t count)
{
    if (count == 0)
        return 0;

    T max = elems[0];
    for (int i = 1; i < count; i++) {
        if (elems[i] > max)
            max = elems[i];
    }

    return max;
}

template <class T>
T fmin(T *elems, size_t count)
{
    if (count == 0)
        return 0;

    T min = elems[0];
    for (int i = 1; i < count; i++) {
        if (elems[i] < min)
            min = elems[i];
    }

    return min;
}

template <class T>
T favg(T *elems, size_t count)
{
    if (count == 0)
        return 0;

    T s = 0;

    for (int i = 0; i < count; i++) {
        s += elems[i];
    }

    return s / count;
}

template <class T>
T fstd(T *elems, size_t count)
{
    if (count == 0)
        return 0;

    T mean = favg(elems, count);
    T s = 0;

    for (int i = 0; i < count; i++) {
        s += (elems[i] - mean) * (elems[i] - mean);
    }

    return sqrt(s / count);
}

#endif // UTILS_H

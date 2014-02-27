/*
 * This code is distributed under the GNU Affero General Public License
 * Version 3 - the same as MIRACL. See the included file LICENSE in the root
 * directory.
 */


#include <cstdlib>
#include <iostream>
#include <cstring>
#include "utils.h"

int pcl(unsigned int n, float *times, size_t nruns);
int kdk(unsigned int n, float *times, size_t nruns);

typedef int (*protocol_fn)(unsigned int, float *, size_t);

int main(int argc, char *argv[])
{
    if (argc < 4) {
        std::cerr << "usage: run <protocol> <n> <number of runs>" << std::endl;
        exit(-1);
    }

    protocol_fn protf;

    if (!strcmp(argv[1], "pcl"))
        protf = pcl;
        
    else if (!strcmp(argv[1], "kdk"))
        protf = kdk;
    else {
        std::cerr << "unknown protocol" << std::endl;
        exit(-1);
    }

    int n = atoi(argv[2]);
    if (n <= 0) {
        std::cerr << "n must be positive" << std::endl;
        exit(-1);
    }

    int nruns = atoi(argv[3]);
    if (nruns <= 0) {
        std::cerr << "number of runs must be positive" << std::endl;
        exit(-1);
    }

    float *times = new float[nruns];

    protf((unsigned int)n, times, (size_t)nruns);
    
    std::cout << n << "\t" << favg(times, nruns) << "\t" << fmax(times, nruns) 
              << "\t" << fmin(times, nruns) << "\t" << fstd(times, nruns)
              << std::endl;


    delete[] times;
}

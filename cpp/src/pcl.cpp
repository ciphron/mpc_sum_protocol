/*
 * This code is distributed under the GNU Affero General Public License
 * Version 3 - the same as MIRACL. See the included file LICENSE in the root
 * directory.
 */


#include <iostream>
#include <ctime>
#include <sys/time.h>

/* Based on hibe.cpp included with MIRACL */

#define MR_PAIRING_BN
#define AES_SECURITY 128

#include "pairing_3.h"
#include <vector>

using std::vector;



class PCL {
public:

    PCL(unsigned int n) : pfc(AES_SECURITY) {
        time_t seed;

        time(&seed);
        irand((long)seed);

        this->n = n;
        pfc.random(g);

        pub_keys = new G1[n];
        priv_keys = new Big[n];

        // Initialize keys
        for (int i = 0; i < n; i++) {
            pfc.random(priv_keys[i]);
            pub_keys[i] = pfc.mult(g, priv_keys[i]);
            //pfc.precomp_for_mult(pub_keys[i]);
        }
        
        Ms = new vector<G1>[n];
    }

    ~PCL() {
        delete[] Ms;
        delete[] pub_keys;
        delete[] priv_keys;
    }

    void run_player(unsigned int player_index, unsigned int input_val) {
        unsigned int round_num = Ms[player_index].size();
        Big *row = new Big[n];

        gen_skew_sym_row(row, player_index, round_num);
        G1 s;
        s.g.clear();
        for (int i = 0; i < n; i++)
            s = s + pfc.mult(pub_keys[i], row[i]);
        s = pfc.mult(s, priv_keys[player_index]);
        s = s + pfc.mult(g, input_val);
        
        Ms[player_index].push_back(s);

        delete[] row;
    }


protected:
    void gen_skew_sym_row(Big *row, unsigned int player_index,
                          unsigned int round_num) {
        row[player_index] = 0;
        char buf[128];

        for (int j = 0; j < player_index; j++) {
            sprintf(buf, "08x,08x,08x", round_num, j, player_index); 
            row[player_index] =  -pfc.hash_to_group(buf);
        }

        for (int j = player_index + 1; j < n; j++) {
            sprintf(buf, "08x,08x,08x", round_num, player_index, j); 
            row[player_index] =  pfc.hash_to_group(buf);
        }
    }


    PFC pfc;
    G1 g;
    G1 *pub_keys;
    Big *priv_keys;
    unsigned int n;
    vector<G1> *Ms;

};


int pcl(unsigned int n, float *times, size_t nruns)
{
    for (size_t r = 0; r < nruns; r++) {
        PCL prot(n);
        int player_index = rand(Big(n)).get(0) % n;

        // Start timing round
        struct timeval start_time;
        struct timeval end_time;
        gettimeofday(&start_time, NULL);

        prot.run_player(player_index, 10);
        // End round

        gettimeofday(&end_time, NULL);
        float diff_usec = ((end_time.tv_sec * 1000000.0) + end_time.tv_usec) -
            ((start_time.tv_sec * 1000000.0) + start_time.tv_usec);

        float diff_ms = diff_usec / 1000.0;
        times[r] = diff_ms;

        #ifdef VERBOSE
        std::cout << "Done round " << r << std::endl;
        #endif
    }

    return 0;
}




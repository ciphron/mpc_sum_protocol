/*
 * This code is distributed under the GNU Affero General Public License
 * Version 3 - the same as MIRACL. See the included file LICENSE in the root
 * directory.
 */

#include <iostream>
#include <ctime>
#include <sys/time.h>

/* Based on hibe.cpp included with MIRACL */

#define MR_PAIRING_BN    // AES-128 or AES-192 security
#define AES_SECURITY 128

#include "pairing_3.h"
#include <vector>

using std::vector;


void derive_G2_round_elem(G2 &w, PFC &pfc, unsigned int round)
{
    char buf[9]; // Num chars to encode 32-bit number in hex + null terminator

    sprintf(buf, "08x", round);
    pfc.hash_and_map(w, buf);

    pfc.precomp_for_pairing(w);
}



int kdk(unsigned int n, float *times, size_t nruns)
{   
	PFC pfc(AES_SECURITY);  // initialise pairing-friendly curve
        G1 pub_keys[n];
        Big priv_keys[n];
        G2 h;
        GT res;
        GT g;
        G1 g1;
        G2 g2;

	time_t seed;

	time(&seed);
    irand((long)seed);

    for (size_t r = 0; r < nruns; r++) {
        int player_index = rand(Big(n)).get(0) % n;
	pfc.random(g1);
	pfc.random(g2);
        g = pfc.pairing(g2, g1);

        // Initialize keys
        for (int i = 0; i < n; i++) {
            pfc.random(priv_keys[i]);
            pub_keys[i] = pfc.mult(g1, priv_keys[i]);
        }

        for (int i = 0; i < player_index; i++) {
            pub_keys[i] = pfc.mult(pub_keys[i], -1);
        }

        // Start timing round
        struct timeval start_time;
        struct timeval end_time;
        gettimeofday(&start_time, NULL);
        derive_G2_round_elem(h, pfc, 0);
        res = 1;
        for (int i = 0; i < player_index; i++)
            res = res * pfc.pairing(h, pub_keys[i]);

        for (int i = player_index + 1; i < n; i++)
            res = res * pfc.pairing(h, pub_keys[i]);


        res = pfc.power(res, priv_keys[player_index]);
        res = res * pfc.power(g, 10); // message is 10
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

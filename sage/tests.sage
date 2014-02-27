# This code is released under the GNU Affero General Public License version 3
# (see LICENSE file)

load utils.sage

import time
import hashlib
import random
import os


def test_protocol(prot, nrounds=1):
    n = prot.n
    for r in range(nrounds):
        values = [randint(0, 100) for i in range(n)]
        s = sum(values)
        for i in range(n):
            prot.run_player(i, values[i])
        v = prot.compute_sum(r, 100*n)
        if s != v:
            return False

    return True

def time_single_player(prot):
    val = randint(0, 100)
    index = randint(0, prot.n - 1)
    stime = time.time()
    prot.run_player(index, val)
    etime = time.time()
    return etime - stime

def time_pollards_lambda(nruns, G, min_val, max_val):
    times = []
    for i in range(nruns):
        r = randint(min_val, max_val)
        stime = time.time()
        discrete_log_lambda(G.pow(G.gen, r), G.gen, (0, max_val + 1), operation=G.operation)
        etime = time.time()
        times.append((etime - stime) * 1000.0) # to ms
        #print "Done run ", i
    return times

def stats(times):
    funcs = [mean, min, max, std]
    s = ""
    for f in funcs:
        s += str(f(times)) + "\t"
    return s.strip()
    
def pollards_lambda_exper_G1(bits, nruns=1):
    min_val = 2^(bits - 2)
    max_val = 2^bits
    G = mk_EC_group()
    print max_val, stats(time_pollards_lambda(nruns, G, min_val, max_val))

def pollards_lambda_exper_GT(bits, nruns=1):
    min_val = 2^(bits - 2)
    max_val = 2^bits
    G = mk_pairing_target_group()
    print bits, stats(time_pollards_lambda(nruns, G, min_val, max_val))


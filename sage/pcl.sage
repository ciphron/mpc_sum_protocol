# This code is released under the GNU Affero General Public License version 3
# (see LICENSE file)

import time
import hashlib
import random
import os

class PCLProtocol:
    def __init__(self, n, G, t=None):
        assert is_prime(G.order)

        if t is None:
            self.t = n // 3
        else:
            assert t < n
            self.t = t
        self.seed = randint(0, 2^256 - 1)
        self.G = G
        self.n = n
        self.keys = gen_keys(G, n)
        self.Ms = [[] for i in range(n)]
    
    def run_player(self, player_index, input_val):
        assert player_index < self.n
        round_num = len(self.Ms[player_index])
        assert round_num < (self.n - self.t) / 2
        
        coeffs = self._gen_skew_sym_row(round_num, player_index)
        
        gy = self.G.one
        for i in range(self.n):
            v = self.G.pow(self.keys[i][0], coeffs[i])
            gy = self.G.mul(gy, v)

        M1 = self.G.pow(gy, self.keys[player_index][1])
        M2 = self.G.pow(self.G.gen, input_val)
        M = self.G.mul(M1, M2)
        self.Ms[player_index].append(M)
        return True

    def compute_sum(self, round_num, max_val=1000):
        assert round_num >= 0 and \
            all(map(lambda x: len(x) > round_num, self.Ms))

        return compute_sum(self.G, map(lambda x: x[round_num], self.Ms),
                           max_val)


    def _H(self, round_num, row, col):
        """Hash a seed s with run number i, row and column"""

        h = hashlib.sha256()
        h.update(str(self.seed))
        h.update("%d, %d, %d" % (round_num, row, col))
        p = self.G.order
        return random.Random(long(h.hexdigest(), 16)).randint(0, p - 1)

    def _gen_skew_sym_row(self, round_num, i):
        elems = [0] * self.n
        for j in range(i):
            elems[j] = -self._H(round_num, j, i)
        for j in range(i + 1, self.n):
            elems[j] = self._H(round_num, i, j)
        return elems



        


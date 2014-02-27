# This code is released under the GNU Affero General Public License version 3
# (see LICENSE file)

import time
import hashlib
import random
import os

# For original KDK protocol, instantiate as KDKProtocol(n, G) where G is some
# cyclic group of prime order. For multi-round KDK protocol (i.e. with
# bilinear pairings), use KDKProtocol(n, G1, G2, GT, e) for some bilinear
# pairing e defined over cyclic groups G1 and G2 that map to G3, all having
# the same prime order.
class KDKProtocol:
    def __init__(self, n, G1, G2=None, GT=None, e=None):
        assert is_prime(G1.order)

        if G2 is not None and GT is not None and e is not None:
            assert G1.order == G2.order and G2.order == GT.order
            self.e = e # pairing
            self.GT = GT
            self.multi_round = True
        else:
            self.e = lambda x, y: x # dummy "pairing"
            self.GT = G1
            self.multi_round = False
        self.G1 = G1
        self.G2 = G2
        self.n = n
        self.keys = gen_keys(G1, n)

        self.Ms = [[] for i in range(n)]
        self._hashes = {}
    
    def run_player(self, player_index, input_val):
        assert player_index < self.n
        round_num = len(self.Ms[player_index])
        h = None
        if self.multi_round:
            h = self._derive_round_G2_elem(round_num)
        else:
            assert round_num == 0 # only 1 round allowed for non-multi-round

        gy = self.GT.one
        for i in range(player_index):
            v = self.e(self.keys[i][0], h) # do pairing
            gy = self.GT.mul(gy, self.GT.pow(v, -1))

        for i in range(player_index + 1, self.n):
            v = self.e(self.keys[i][0], h) # do pairing
            gy = self.GT.mul(gy, v)

        M1 = (self.GT.pow(gy, self.keys[player_index][1]))
        M2 = self.GT.pow(self.GT.gen, input_val)
        M = self.GT.mul(M1, M2)
        self.Ms[player_index].append(M)
        return True

    def compute_sum(self, round_num, max_val=1000):
        assert round_num >= 0 and \
            all(map(lambda x: len(x) > round_num, self.Ms))

        return compute_sum(self.GT, map(lambda x: x[round_num], self.Ms),
                           max_val)

    def _derive_round_G2_elem(self, round_num):
        # let this behave like a random oracle since we currently have not
        # implemented a hash function to map to G2
        if round_num not in self._hashes:
            r = randint(0, self.G2.order - 1)
            self._hashes[round_num] = self.G2.pow(self.G2.gen, r)
        return self._hashes[round_num]


        


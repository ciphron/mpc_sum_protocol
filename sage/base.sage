# This code is released under the GNU Affero General Public License version 3
# (see LICENSE file)

import time
import hashlib
import random
import os


# A container class for cyclic groups to be treated multiplicatively.
class CyclicGroup:
    def __init__(self, gen, order, operation='*'):
        if operation == '+':
            self.pow = operator.mul
            self.mul = operator.add
        elif operation == '*':
            self.pow = operator.pow
            self.mul = operator.mul
        else:
            raise ValueError('Unknown operation')

        self.operation = operation
        self.gen = gen
        self.order = order
        self.one = self.pow(self.gen, 0)


def gen_keys(G, n):
    keys = []
    for i in range(n):
        x = randint(0, G.order - 1)
        keys.append((G.pow(G.gen, x), x))
    return keys

def compute_sum(G, contribs, max_val):
    z = reduce(G.mul, contribs)
    return discrete_log_lambda(z, G.gen, (0, max_val),
                               operation=G.operation)


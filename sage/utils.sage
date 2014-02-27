# This code is released under the GNU Affero General Public License version 3
# (see LICENSE file)

# Utils

load base.sage
load kdk.sage
load pcl.sage


def pf(u):
    return 36*u^4 + 36*u^3 + 24*u^2 + 6*u + 1 

def nf(u):
    return 36*u^4 + 36*u^3 + 18*u^2 + 6*u + 1

def make_BN():
    u = (2^62 + 2^55 + 1) * -1
    p = pf(u)
    n = nf(u)
    A = 0
    B = 2
    E = EllipticCurve(GF(p), [A, B])
    return (E, p, n, 12) # embedding degree is 12

def mk_EC_group():
    (E, p, n, k) = make_BN()
    G = CyclicGroup(E(-1, 1), n, operation='+')
    return G

def mk_pairing_target_group():
    (E, p, n, k) = make_BN()
    F = GF(p)
    K.<a> = GF(p^k)
    EK = E.base_extend(K)
    P = EK(-1, 1)
    h = ZZ(EK.order() / (n^2)) # cofactor
    Q = EK.random_point() * h # get random point of order n
    def e(P1, P2):
        return P1.tate_pairing(P2, n, k)

    g = e(P, Q)
    GT = CyclicGroup(g, n, operation='*')
    return GT
    
    
def create_KDK_protocol_EC_multiround(nplayers):
    (E, p, n, k) = make_BN()
    F = GF(p)
    K.<a> = GF(p^k)
    EK = E.base_extend(K)
    P = EK(-1, 1)
    h = ZZ(EK.order() / (n^2)) # cofactor
    Q = EK.random_point() * h # get random point of order n
    
    G1 = CyclicGroup(P, n, operation='+')
    G2 = CyclicGroup(Q, n, operation='+')
    def e(P1, P2):
        return P1.tate_pairing(P2, n, k)
    
    g = e(P, Q)
    GT = CyclicGroup(g, n, operation='*')
    
    # in the above code, n refers to the order of the elliptic curve E
    # instead of the number of parties as it does elsewhere
    return KDKProtocol(nplayers, G1, G2, GT, e)

def create_KDK_protocol_EC(nplayers):
    return KDKProtocol(nplayers, mk_EC_group())

def create_PCL_protocol_EC(nplayers, tolerance):
    return PCLProtocol(nplayers, mk_EC_group(), t=tolerance)


# Multiplicative subgroups of finite fields
# This is a VERY naive algorithm to generate such primes
def gen_strong_prime(bits):
    lb = 2^(bits - 1)
    ub = 2*lb
    q = 2 * random_prime(ub, lbound=lb) + 1
    while not is_prime(q):
        q = 2 * random_prime(ub, lbound=lb) + 1
    return q

def mk_Fq_group(q):
    assert is_prime(q)
    i = 3
    p = ZZ((q - 1) / 2)
    while not is_prime(p):
        p = ZZ(p / i)
        if p % i != 0:
            i = next_prime(i)
    Fq = GF(q)
    g = Fq.random_element()
    while g.multiplicative_order() != p:
        g = Fq.random_element()
    return CyclicGroup(g, p, operation='*')

def create_KDK_protocol_Fq(nplayers, q):
    return KDKProtocol(nplayers, mk_Fq_group(q))

def create_PCL_protocol_Fq(nplayers, tolerance, q):
    return PCLProtocol(nplayers, mk_Fq_group(q), t=tolerance)

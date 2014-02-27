# This code is released under the GNU Affero General Public License version 3
# (see LICENSE file)

# An example of using the code to run one of the tests

load utils.sage
load tests.sage

NUM_PLAYERS = 10

protocol = create_PCL_protocol_EC(nplayers=NUM_PLAYERS, \
                                  tolerance=floor(NUM_PLAYERS / 2))
print 'Correctness test passed: ', test_protocol(protocol)

# Quick and dirty
# compiling separately into objects as usual failed to work...

CC=g++
CFLAGS=-m64 -O2 -DVERBOSE
SOURCES=main.cpp kdk.cpp pcl.cpp bn_pair.cpp zzn12a.cpp ecn2.cpp zzn4.cpp zzn2.cpp big.cpp zzn.cpp ecn.cpp
EXECUTABLE=run
LIBS=miracl.a


all:
	g++ $(CFLAGS) $(SOURCES) $(LIBS) -o $(EXECUTABLE)


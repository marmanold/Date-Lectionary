perl Makefile.PL
make
make test TEST_VERBOSE=1
make manifest
make distdir
make disttest
make dist
make tardist

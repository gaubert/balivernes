#=============================================================================
# File: Makefile for GribAssert
# author: guillaume.aubert@ctbto.org
#=============================================================================

INCDIR=../include
SRC=.
INST=../inst/bin

LIBGRIBAPIDIR=/home/aubert/dev/src-reps/balivernes/gribapi/perl/swig/etc/inst/libs
LIBDIRS = -L$(LIBGRIBAPIDIR)

GCCOPTS = -pedantic -Wall   -g -O2

all: compile install

compile: 
	gcc -I$(INCDIR) -c $(SRC)/grib_extractor.c
	gcc -pedantic -Wall   -g -O2   -o grib_extractor grib_extractor.o $(LIBDIRS) -lgrib_api -lm -ljasper 

install:
	cp $(SRC)/grib_extractor $(INST)

clean:
	cd $(SRC); rm *.o; rm grib_extractor;

cleaninstall:
	cd $(INST); rm grib_extractor;
    



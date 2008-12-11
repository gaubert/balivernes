#=============================================================================
# File: Makefile for grib_extractor
# author: guillaume.aubert@ctbto.org
#=============================================================================

BASEDIR=../..
INC=$(BASEDIR)/srcs/include
SRC=$(BASEDIR)/srcs/src
BIN=$(BASEDIR)/bin
ETC=$(BASEDIR)/etc
LIBGRIBAPI=$(BASEDIR)/srcs/libs
VERSION=0.5

DIST=grib_extractor-$(VERSION)
LIBS = -L$(LIBGRIBAPI)

GCCOPTS = -pedantic -Wall -g -O2 

all: compile install

compile: 
	gcc -I$(INC) -c $(SRC)/grib_extractor.c
	gcc $(GCCOPTS)  -o grib_extractor grib_extractor.o $(LIBS) -lgrib_api -lm -ljasper 

install:
	cp $(SRC)/grib_extractor $(BIN)

dist: clean
	rm -Rf /tmp/$(DIST)
	mkdir -p /tmp/$(DIST)
	cp -R $(BIN) /tmp/$(DIST)
	cp -R $(ETC) /tmp/$(DIST)
	cp -R $(BASEDIR)/srcs /tmp/$(DIST)/srcs
	tar zcvf $(DIST).tar.gz -C /tmp ./$(DIST)

test-hash:
	gcc -I$(INC) -c $(SRC)/test.c
	gcc $(GCCOPTS)  -o test_hash test.o $(LIBS) 

clean:
	cd $(SRC); rm -f *.o; rm -f *.tar.gz ; rm -f grib_extractor;

cleaninstall:
	cd $(INST)/bin; rm -f grib_extractor;
    



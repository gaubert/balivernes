#=============================================================================
# File: Makefile for GribAssert
# author: guillaume.aubert@ctbto.org
#=============================================================================

BASEDIR=/home/aubert/dev/src-reps/balivernes/gribapi/perl/swig/etc/inst
PERL5INC=/usr/lib/perl/5.8/CORE
INCDIR=/usr/include
SRC=$(BASEDIR)/src
INSTDIR=$(BASEDIR)/../../libs/perl

LIBGRIBAPIDIR=$(BASEDIR)/libs
LIBDIRS = -L$(LIBGRIBAPIDIR)

all: compile link install

swig: 
	swig -perl5 $(SRC)/grib_api.i    
	cp $(SRC)/grib4perl.pm $(INSTDIR)

compile: 
	gcc -c $(SRC)/grib_api_helper.c -o $(SRC)/grib_api_helper.o
	gcc -c $(SRC)/grib_api_wrap.c -I$(INCDIR) -I$(PERL5INC) -D_GNU_SOURCE  -Dbool=char -o $(SRC)/grib_api_wrap.o

link: 
	gcc -shared $(LIBDIRS) -Wl,-soname,libgrib4perl.so.1 -o $(SRC)/grib4perl.so $(SRC)/grib_api_helper.o $(SRC)/grib_api_wrap.o -lgrib_api -lc -ljasper

install:
	cp $(SRC)/grib4perl.so $(INSTDIR)

clean-swig:
	rm -f grib_api_wrap.*;

clean:
	cd $(SRC); rm *.o;
    



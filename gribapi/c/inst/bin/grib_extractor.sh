#!/bin/bash

GRIB_EXTRACTOR_HOME=/home/aubert/dev/src-reps/balivernes/gribapi/c/inst

export GRIB_DEFINITION_PATH=$GRIB_EXTRACTOR_HOME/etc/definitions

$GRIB_EXTRACTOR_HOME/bin/grib_extractor $*





#!/bin/bash

GRIB_EXTRACTOR_HOME=..

export GRIB_DEFINITION_PATH=$GRIB_EXTRACTOR_HOME/etc/definitions

$GRIB_EXTRACTOR_HOME/bin/grib_extractor $*





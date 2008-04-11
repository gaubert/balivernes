#!/bin/sh

# Point to the GRIBAPI HOME
GRIBAPI_HOME=/home/aubert/dev/c/grib_api-1.4.0b/inst

# directory that will contain the converted files
CONVERTED_DIR=/tmp/test
# directory of the files to convert
TO_CONVERT=/tmp/gribs

#################################
## build absolute path
#################################
D=`dirname "$CONVERTED_DIR"`
B=`basename "$CONVERTED_DIR"`
CONVERTED_DIR="`cd \"$D\" 2>/dev/null && pwd || echo \"$D\"`/$B"

## get all grib2 to convert
for grib1File in `ls $CONVERTED_DIR/*.grib1`; do
  cnvName=`basename "$grib1File" .grib1`
  echo "Start comparing $grib1File with $TO_CONVERT/$cnvName.grib1"
  $GRIBAPI_HOME/bin/grib_compare $grib1File $TO_CONVERT/$cnvName.grib1 > /tmp/test/comp-$cnvName.txt
  echo "grib1 compared"
done

#!/bin/sh

# Point to the GRIBAPI HOME
GRIBAPI_HOME=/home/aubert/dev/c/grib_api-1.4.0b/inst

# directory that will contain the converted files
CONVERTED_DIR=/tmp/test
# directory of the files to convert
TO_CONVERT=/tmp/gribs
# Path to the conversion rules' file
RULES=/home/aubert/public/NCEPGrib2ToGrib1280108.rules


#################################
## build absolute path
#################################
D=`dirname "$CONVERTED_DIR"`
B=`basename "$CONVERTED_DIR"`
CONVERTED_DIR="`cd \"$D\" 2>/dev/null && pwd || echo \"$D\"`/$B"

echo "file of rules used: $RULES"

## get all grib2 to convert
for grib2File in `ls $TO_CONVERT/*.grib2`; do
  cnvName=`basename "$grib2File" .grib2`
  echo "Start conversion of $grib2File in $CONVERTED_DIR/$cnvName.grib1"
  $GRIBAPI_HOME/bin/grib_convert $RULES $grib2File $CONVERTED_DIR/$cnvName.grib1
  echo "conversion done"
done

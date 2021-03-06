#!/bin/bash
set -x

GRIB_EXTRACTOR_HOME=..

export LD_LIBRARY_PATH=../srcs/libs/lib64:$LD_LIBRARY_PATH

export GRIB_DEFINITION_PATH=$GRIB_EXTRACTOR_HOME/etc/definitions

GRIB_DIR="/tmp/test-set"

STATION_LIST_1="I01AR:-40.7,-70.6/I02AR:-55.0,-68.0/I03AU:-68.4,77.6/I04AU:-32.9,117.2/I05AU:-42.1,147.2/I06AU:-12.3,97.0/I07AU:-19.9,134.3/I08BO:-16.3,-68.1/I09BR:-15.6,-48.0/I10CA:50.2,-95.9/I11CV:16.0,-24.0/I12CAR:5.2,18.4/I13CHL:-27.0,-109.2/I14CHL:-33.8,-80.7/I15CHN:40.0,116.0/I16CHN:25.0,102.8/I17CI:6.7,-4.9/I18DK:76.5,-68.7/I19DJ:11.3,43.5"

STATION_LIST_2="I20EC:0.0,-91.7/I21FR:-10,-140/I22FR:-22.1,166.3/I23FR:-49.2,69.1/I24FR:-17.6,-149.6/I25FR:5.2,-52.7/I26DE:48.85,13.72/I27DE:-70.6,-8.40/I29IR:35.7,51.4/I30JP:36.0,140.1/I31KZ:50.408,58.034/I32KN:1.3,36.813/I33MA:-18.8,47.5/I34MN:48.0,106.8/I35NA:19.1,17.413/I36NZ:-44.0,-176.5/I37NW:69.5,25.5/I38PAK:28.2,70.3/I39PAL:7.5,134.5/I40PAP:-4.1,152.1/I41PAR:26.3,-57.3/I42PO:37.8,I43RU:-25.5/I44RU:56.7,37.3/I44RU:53.1,158.8/I45RU:43.7,131.9/I46RU:53.9,84.8/I47RSA:28.6,25.4/I48TN:35.6,8.7/I49UK:37.0,-12.3/I50UK:-8.0,-14.3"

STATION_LIST_3="I51UK:32.0,-64.5/I52UK:-5.0,72.0/I53US:64.8,-146.9/I54US:-75.5,-83.6/I55US:-77.5,161.8/I56US:48.3,-117.1/I57US:33.6,-116.5/I58US:28.1,-177.2/I59US:19.6,-155.3/I60US:19.3,166.6/FLERS:48.76,-0.48/IGADE:53.26,8.69/HUFE:52.70,9.55/JAMTON:65.86,22.50/UPPSALA:59.85,17.61/LYCKSELE:64.61,18.75/KIRUNA:67.86,20.42/DIA:52.06,5.88/DBN:52.19,5.18/EXL:52.91,6.87"
STATION_LIST_3="I51UK:32.0,-64.5/I52UK:-5.0,72.0/I58US:28.1,-177.2"

# prepare special extract
echo "First batch of stations"
#$GRIB_EXTRACTOR_HOME/bin/grib_extractor -c $STATION_LIST_1 -d /tmp/generated-test $GRIB_DIR//EN??????{00,03,06,09,12,15,18,21}
echo "second batch of stations"
#$GRIB_EXTRACTOR_HOME/bin/grib_extractor -d /tmp/generated-test -c $STATION_LIST_2 $GRIB_DIR/EN??????{00,03,06,09,12,15,18,21}
echo "third batch of stations"
$GRIB_EXTRACTOR_HOME/bin/grib_extractor -c $STATION_LIST_3 -d . $GRIB_DIR/EN080820*

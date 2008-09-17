/**
* Copyright 2005-2007 ECMWF
* 
* Licensed under the GNU Lesser General Public License which
* incorporates the terms and conditions of version 3 of the GNU
* General Public License.
* See LICENSE and gpl-3.0.txt for details.
*/

/*
 * C Implementation: keys_iterator
 *
 * Description:
 * Example on how to use keys_iterator functions and the
 * grib_keys_iterator structure to get all the available
 * keys in a message.
 *
 * Author: Guillaume Aubert <guillaume.aubert@ctbto.org>
 *
 *
 */

#include <assert.h>
#include <stdlib.h>
#include <stdio.h>
#include <unistd.h>
#include <string.h>


#include "grib_api.h"

#define MAX_KEY_LEN  255
#define MAX_VAL_LEN  1024

static void usage(char* progname);

static int read_grib(FILE* f,char * filename);

static void usage(char* prog) {
  printf("Usage: %s grib_file grib_file ...\n",prog);
  exit(1);
}

int main(int argc, char *argv[])
{
  int    i = 0;
  size_t nfiles;
  FILE* f;

  if (argc < 2) usage(argv[0]);

  nfiles=argc-1;
  for (i=0;i<nfiles;i++)
  {
    f = fopen(argv[i+1],"r");
    if(!f) 
    {
       perror(argv[i+1]);
       exit(1);
    }

    printf("--------------------------------------------------------------------------\n");
    printf("---------------------------- Filename: %s---------------------------\n",argv[i+1]);
    printf("--------------------------------------------------------------------------\n");
    
    read_grib(f,argv[i+1]);

  }

  return 0;
}

static int read_grib(FILE* f,char * filename)
{
  grib_handle* h=NULL;
  int err=0;
  int grib_count=0;

  char short_name[MAX_VAL_LEN];
  size_t snlen=MAX_VAL_LEN;
  char level[MAX_VAL_LEN];
  size_t levlen=MAX_VAL_LEN;
  char date[MAX_VAL_LEN];
  size_t datelen=MAX_VAL_LEN;
  char time[MAX_VAL_LEN];
  size_t timelen=MAX_VAL_LEN;

  size_t size=4;
  double lat=-40,lon=15;
  int mode=0;
  grib_nearest* nearest=NULL;
  double lats[4]={0,};
  double lons[4]={0,};
  double values[4]={0,};
  double distances[4]={0,};
  size_t indexes[4]={0,};

  while((h = grib_handle_new_from_file(0,f,&err)) != NULL) 
  {

    grib_count++;
    if(!h) 
    {
      printf("ERROR: Unable to create grib handle\n");
      exit(1);
    }

    /* get grib param or short_name */
    snlen=MAX_VAL_LEN;
    GRIB_CHECK(grib_get_string(h,"short_name",short_name,&snlen),short_name);
    /* printf("short_name = %s\n",short_name); */

    if ( (strncmp(short_name,"U",snlen)==0) || (strncmp(short_name,"V",snlen)==0) || (strncmp(short_name,"T",snlen)==0))
    {
       /* get level */
       GRIB_CHECK(grib_get_string(h,"lev",level,&levlen),level);
       levlen = MAX_VAL_LEN;

       /* get date */
       GRIB_CHECK(grib_get_string(h,"date",date,&datelen),date);
       datelen = MAX_VAL_LEN;

       /* get time */
       GRIB_CHECK(grib_get_string(h,"time",time,&timelen),date);
       timelen = MAX_VAL_LEN;

       /* get nearest value from nearest grib point */
       mode=GRIB_NEAREST_SAME_GRID |  GRIB_NEAREST_SAME_POINT;

       /* create nearest structure */
       if (!nearest) nearest=grib_nearest_new(h,&err);
       GRIB_CHECK(err,0);

       GRIB_CHECK(grib_nearest_find(nearest,h,lat,lon,mode,lats,lons,values,distances,indexes,&size),0);

       /*for (i=0;i<4;i++) 
       {        
         printf("%d %.2f %.2f %g %g - ", (int)indexes[i],lats[i],lons[i],distances[i],values[i]);
         printf("\n");
       }
       */
       printf("-- GRIB N. %d --: date=%s, time=%s, param=%s, lev=%s, lat=%.2f, lon=%.2f, distance=%g, values=%g - \n",grib_count,date,time,short_name,level ,lats[0],lons[0],distances[0],values[0]);
    }

    if (nearest)
    { 
       grib_nearest_delete(nearest);       
       nearest = NULL;
    }

    /* reinit snlen as it is a inout param */
    snlen = MAX_VAL_LEN;

  }


  if (h) grib_handle_delete(h);

  return 0;

}

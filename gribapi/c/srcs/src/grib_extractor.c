/**
* Copyright 2005-2007 ECMWF
* 
* Licensed under the GNU Lesser General Public License which
* incorporates the terms and conditions of version 3 of the GNU
* General Public License.
* See LICENSE and gpl-3.0.txt for details.
*/

/*
 * C Implementation: grib_extractor
 *
 * Description:
 *
 * Author: Guillaume Aubert <guillaume.aubert@ctbto.org>
 *
 *
 */

#include <assert.h>
#include <stdlib.h>
#include <stdio.h>
#include <sys/stat.h>
#include <unistd.h>
#include <string.h>
#include <getopt.h>


#include "grib_api.h"

#define MAX_KEY_LEN  255
#define MAX_VAL_LEN  1024

static char  version_number[] = "0.5";
static char  default_dir[]    = "/tmp";

static void usage(int status);

static int read_grib(FILE* gribfile,char* directory,char * grib_filename,double *lats,double *lons,int nbCoords);

/**
*  @brief  Check if the necessary directories can be created
*          To follow the other functions I return 1 if correct or 0 if err but I don't like it
*  @param sPath          The directory
*
*  @return   1 if file can be parser, 0 otherwise
*
*  @author   guillaume.aubert@ctbto.org
*/
int create_directories(char *sPath)
{

  /* check if the directory already exists if not then try to create it */
  char opath[1024];
  char *p;
  size_t len;
  char errMsg[256];

  strncpy(opath, sPath, sizeof(opath));
  len = strlen(opath);

  if(opath[len - 1] == '/')
  {
    opath[len - 1] = '\0';
  }

  for(p = opath; *p; p++)
  {
     if(*p == '/') 
     {
        *p = '\0';
        if( access(opath, F_OK) && (strlen(opath) > 0) )
        {
		   
           if (mkdir(opath, S_IRWXU) == -1)
		   {
              /* error get its string value with perror */
			  sprintf(errMsg,"Error when creating directory %s",opath);
			  perror(errMsg);

			  exit(EXIT_FAILURE);

		   }
           else
		   {
	          fprintf(stdout,"Create directory: %s\n", opath);
		   }

        }
        *p = '/';
     }
  }

  /* last component of the path /home/a/b */
  if(access(opath, F_OK) && (strlen(opath) > 0))         /* if path is not terminated with / */
  {
    if (mkdir(opath, S_IRWXU) == -1)
	{
	   /* error get its string value with perror */
	   sprintf(errMsg,"Error when creating directory %s ",opath);
	   perror(errMsg);

	   exit(EXIT_FAILURE);
	}
	else
	{
	  fprintf(stdout,"Create directory: %s", opath);
	}
  }

  return EXIT_SUCCESS;
}

static int parse_coordinates(char * strCoords,double* lats, double* lons, int * nbCoord)
{
  char * field = NULL;
  char * theRest = NULL;
  int    n     = 0;
  char f[256];
  f[0] = '\0'; 

  double  lat = -1;
  double  lon = -1;
  int     res = -1;

  *nbCoord = 0;

  printf("Coords %s\n",strCoords);

  while (sscanf(strCoords, "%256[^/]%n", f, &n) == 1)
  {
     printf("field = \"%s\"\nn = %d\n", f,n);

     /* try to parse coordinates */
     if ( (res = sscanf(f,"%lf,%lf",&lat,&lon)) == 2)
     {
        printf("point: lat(%g), lon(%g)\n",lat,lon);
        lats[*nbCoord] = lat;
        lons[*nbCoord] = lon;
        (*nbCoord)++;
     }     
     else
     {
        printf("Error. Non valid coordinates string : %s\n",strCoords);
        return EXIT_FAILURE;
     }

     printf("res = %d\n",res);

     strCoords += n; /* advance the pointer by the number of characters read */
     if ( *strCoords != '/' )
     {
       return EXIT_SUCCESS;
     }
     ++strCoords; /* skip the delimiter */
  }

  return EXIT_FAILURE;
}

/**
 *  @brief  print usage
 */
static void usage(int status)
{
  fprintf(stderr,"\nUsage: grib_extractor -c lat,lon/lat/lon GRIBFILES .\n Mandatory arguments:\n -c      (--coordinates)  list of coordinates (format: lat,lon/lat,lon ...) . For example -c 40,-15/60,-20.\n \n\n");
  exit(status);
}

int main(int argc, char *argv[])
{
  int    i = 0;
  size_t nfiles;
  FILE* f;

  /* vars for parameter processing */
  static int help_flag    = -1;
  static int version_flag = -1;
  int optc;
  int option_index = 0;
  char * coordinates = NULL;
  char * directory   = NULL;
  double lats[100];
  double lons[100];
  int nbCoords = 0;

  while (1)
  { 
     static struct option long_options[] =
     {
         /* These options don't set a flag.
            We distinguish them by their indices. */
		 {"help",        no_argument, &help_flag,1},
		 {"version",     no_argument, &version_flag,1},
         {"coordinates", required_argument, 0, 'c'},
         {"directory"  , required_argument, 0, 'd'},
         {0, 0, 0, 0}
     };

     /* getopt_long stores the option index here. */
     
     optc = getopt_long (argc, argv, "vhc:d:", long_options, &option_index);
     
     /* Detect the end of the options. */
     if (optc == -1)
       break;
     
     switch (optc)
     {
       case 0:
         /* If this option set a flag, do nothing else now. */
         if (long_options[option_index].flag != 0)
            break;
            printf ("option %s", long_options[option_index].name);
         if (optarg)
          printf (" with arg %s", optarg);
          printf ("\n");
          break;
     
          case 'c':
			coordinates = optarg;
            printf("Coordinates = %s \n",coordinates);
            parse_coordinates(coordinates,lats,lons,&nbCoords);
            printf("Nb Coords %d\n",nbCoords);
            break;

          case 'd':
			directory = optarg;
            break;
     
          case 'h':
		    help_flag = 1;
			break;

          case 'v':
			version_flag = 1;
			break;
     
          case '?':
            if (optopt == 'c')
              fprintf (stderr, "Option -%c requires an argument.\n", optopt);
            else if (isprint (optopt))
              fprintf (stderr, "Unknown option `-%c'.\n", optopt);
            else
              fprintf (stderr, "Unknown option character `\\x%x'.\n", optopt);
			  usage(EXIT_FAILURE);

           default:
             abort ();
     }
   }

   if (version_flag == 1)
   {
      fprintf(stderr,"version %s\n",version_number);
	  exit(0);
   }

   if (help_flag == 1)
   {
	   usage(0);
   }

   if (option_index == argc)
   { 
      fprintf (stderr, "Error. too few arguments. Need grib files path \n");
      usage(EXIT_FAILURE);
   }

   if (coordinates == NULL)
   {
      fprintf (stderr, "Error. Need stations coordinates \n");
      usage(EXIT_FAILURE);
   }

   if (directory == NULL)
   {
      directory = default_dir;
   }

   fprintf (stdout, "generate results in %s\n",directory);

   /* create dir if it doesn't exist */
   create_directories(directory);
   

   for (; optind < argc; ++optind)
   {
     int fail = 0;

     char* filename = argv[optind];

     f = fopen(filename,"r");
     if(!f) 
     {
        perror(filename);
        exit(EXIT_FAILURE);
     }
     printf("--------------------------------------------------------------------------\n");
     printf("----------------------Process Filename: %s---------------------------\n",filename);
     printf("--------------------------------------------------------------------------\n");
    
     read_grib(f,directory,filename,lats,lons,nbCoords);
   } 

  return EXIT_SUCCESS;
}

static int read_grib(FILE* gribfile,char* directory,char * grib_filename,double *lats,double *lons,int nbCoords)
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
  int mode=0;
  grib_nearest* nearest=NULL;
  double nearest_lats[4]={0,};
  double nearest_lons[4]={0,};
  double values[4]={0,};
  double distances[4]={0,};
  size_t indexes[4]={0,};
  FILE*  fds[100] = {NULL,};
  char   tempfilename[512];
  int    i = 0;
  int    j = 0;

  if ( (h = grib_handle_new_from_file(0,gribfile,&err)) != NULL)
  {
    /* get date and time to use it in filename */

    /* get date */
    GRIB_CHECK(grib_get_string(h,"date",date,&datelen),date);
  
    /* get time */
    GRIB_CHECK(grib_get_string(h,"time",time,&timelen),date);

    /* Open files one per coordinate */
    for (i=0; i < nbCoords; i++)
    {
      sprintf(tempfilename,"%s/gextract_%s%s_[%g,%g].data",directory,date,time,lats[i],lons[i]);
      fds[i] = fopen(tempfilename,"w");
      if(!fds[i])
      {
        perror(tempfilename);
        exit(EXIT_FAILURE);
      }
    }

    do
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
  
         /* For each of the coordinates */
         for (j=0; j < nbCoords; j++)
         {
  
            /* get nearest value from nearest grib point */
            mode=GRIB_NEAREST_SAME_GRID |  GRIB_NEAREST_SAME_POINT;
  
            /* create nearest structure */
            if (!nearest) nearest=grib_nearest_new(h,&err);
              GRIB_CHECK(err,0);
  
            GRIB_CHECK(grib_nearest_find(nearest,h,lats[j],lons[j],mode,nearest_lats,nearest_lons,values,distances,indexes,&size),0);
  
            fprintf(fds[j],"-- GRIB N. %d --: date=%s, time=%s, param=%s, lev=%s, lat=%.2f, lon=%.2f, distance=%g, values=%g - \n",grib_count,date,time,short_name,level ,nearest_lats[0],nearest_lons[0],distances[0],values[0]);
          
            if (nearest)
            { 
               grib_nearest_delete(nearest);       
               nearest = NULL;
            }
            /*for (i=0;i<4;i++) 
            {        
              printf("%d %.2f %.2f %g %g - ", (int)indexes[i],lats[i],lons[i],distances[i],values[i]);
              printf("\n");
            }
            */
         }
      }


      /* reinit snlen as it is a inout param */
      snlen = MAX_VAL_LEN;

    }
    while( (h = grib_handle_new_from_file(0,gribfile,&err)) != NULL);
  }

  if (h) grib_handle_delete(h);

  /* Open files one per coordinate */
  for (i=0; i < nbCoords; i++)
  {
     if (fclose(fds[i]) !=0)
     {
        perror("closing data files");
     }
  }

  return 0;

}

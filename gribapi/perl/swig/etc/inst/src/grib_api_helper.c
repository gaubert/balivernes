/*  File : gribApi_Helper.c
 *  Author: guillaume.aubert@ctbto.org
 *  Desc: contain helper function in c to smooth the integration of grib_api in perl
 */

#include <stdio.h>

void print_doubleArray(double* x,size_t len) {
   int i;
   for (i = 0; i < len; i++) {
      printf("[%d] = %g\n", i, x[i]);
   }
}

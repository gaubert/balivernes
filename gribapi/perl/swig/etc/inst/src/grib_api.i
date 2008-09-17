/* File: grib_api.i */
%module grib4perl
%{
#include "grib_api.h"
%}


#define GRIB_KEYS_ITERATOR_ALL_KEYS 0
#define MAX_KEY_LEN  255
#define MAX_VAL_LEN  1024

%include typemaps.i
%include carrays.i
%array_functions(double, doubleArray);
%array_functions(long, longArray);

/* $target = IoIFP(sv_2io($source)); */
%typemap(in) FILE * {
   $1 = PerlIO_findFILE(IoIFP(sv_2io($input)));
}

typedef grib_handle*        GRIBHANDLE;
typedef grib_context*       GRIBCONTEXT;
typedef grib_iterator*      GRIBITERATOR;
typedef grib_keys_iterator* GRIBKEYSITERATOR;

/* extern void print_doubleArray(double* x,size_t len); */

extern     grib_handle* grib_handle_new_from_file(grib_context* REFERENCE, FILE * file, int* OUTPUT);
extern int grib_handle_delete(grib_handle* h);

/* Return an array containing a the result of the function and the value  */
extern int grib_get_double(grib_handle* INPUT, const char* INPUT, double* OUTPUT);
/* Return an array containing a the result of the function and the value  */
extern int grib_get_long(grib_handle* INPUT, const char* INPUT, long* OUTPUT);
/* Return an array containing a the result of the function and the len  */
extern int grib_get_size(grib_handle* INPUT, const char* INPUT,size_t* OUTPUT);

/* TODO: the user should not have to allocate and free the array of values.
Instead, he should pass the size of the array to allocate and the array should be allocated in a wrapper.
What about the release. It should be handled a a perl array: C arr dynamically allocated and read values recopied into the
the perl array
 */


/* get elements from array such as data values  */
extern int grib_get_double_array(grib_handle* INPUT, const char* INPUT, double* INOUT,size_t* INOUT);
extern int grib_get_long_array(grib_handle* INPUT, const char* INPUT, long* INOUT,size_t * INOUT);
extern int grib_get_double_element(grib_handle* INPUT, const char* INPUT, size_t INPUT, double* OUTPUT);

/* To have a char * value returned in a perl string and handle by the perl ref counting */

/* Use a temporary array for the result */
%typemap(in,numinputs=0) char* STRVAL (char temp[MAX_VAL_LEN]) {
        $1 = temp;
}

/* Copy the output into a new Perl scalar */
%typemap(argout) char* STRVAL {

      if (argvi >= items) {
         EXTEND(sp,1);
      }
      $result = sv_newmortal();
      sv_setpv($result,$1);
      argvi++;
}
/* End char * value handling  */
/* Ignore the third parameter of grib_get_string STRSIZE as the size of the length is read from the value itself in perl */
%typemap(in,numinputs=0) size_t* STRSIZE (int size = MAX_VAL_LEN) {
        $1 = &size;
}

extern int grib_get_string(grib_handle* INPUT, const char* INPUT, char*  STRVAL,size_t * STRSIZE);

/* iterators */
extern grib_iterator* grib_iterator_new(grib_handle* INPUT, unsigned long INPUT,int* OUTPUT);
extern int grib_iterator_next(grib_iterator * INPUT, double* lat,double* lon,double* value);
extern int grib_iterator_previous(grib_iterator * INPUT, double* lat,double* lon,double* value);
extern int grib_iterator_has_next(grib_iterator * INPUT);
extern int grib_iterator_reset(grib_iterator * INPUT);
extern int grib_iterator_delete(grib_iterator * INPUT);

extern grib_keys_iterator* grib_keys_iterator_new(grib_handle*  INPUT,unsigned long  INPUT, char* name_space);
extern int grib_keys_iterator_next(grib_keys_iterator* INPUT);
extern const char* grib_keys_iterator_get_name(grib_keys_iterator* INPUT);
extern int grib_keys_iterator_delete(grib_keys_iterator*  INPUT);
extern int grib_keys_iterator_rewind(grib_keys_iterator*  INPUT);
extern int grib_keys_iterator_set_flags(grib_keys_iterator * INPUT,unsigned long flags);


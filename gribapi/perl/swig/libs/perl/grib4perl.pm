# This file was automatically generated by SWIG (http://www.swig.org).
# Version 1.3.31
#
# Don't modify this file, modify the SWIG interface instead.

package grib4perl;
require Exporter;
require DynaLoader;
@ISA = qw(Exporter DynaLoader);
package grib4perlc;
bootstrap grib4perl;
package grib4perl;
@EXPORT = qw( );

# ---------- BASE METHODS -------------

package grib4perl;

sub TIEHASH {
    my ($classname,$obj) = @_;
    return bless $obj, $classname;
}

sub CLEAR { }

sub FIRSTKEY { }

sub NEXTKEY { }

sub FETCH {
    my ($self,$field) = @_;
    my $member_func = "swig_${field}_get";
    $self->$member_func();
}

sub STORE {
    my ($self,$field,$newval) = @_;
    my $member_func = "swig_${field}_set";
    $self->$member_func($newval);
}

sub this {
    my $ptr = shift;
    return tied(%$ptr);
}


# ------- FUNCTION WRAPPERS --------

package grib4perl;

*new_doubleArray = *grib4perlc::new_doubleArray;
*delete_doubleArray = *grib4perlc::delete_doubleArray;
*doubleArray_getitem = *grib4perlc::doubleArray_getitem;
*doubleArray_setitem = *grib4perlc::doubleArray_setitem;
*new_longArray = *grib4perlc::new_longArray;
*delete_longArray = *grib4perlc::delete_longArray;
*longArray_getitem = *grib4perlc::longArray_getitem;
*longArray_setitem = *grib4perlc::longArray_setitem;
*grib_handle_new_from_file = *grib4perlc::grib_handle_new_from_file;
*grib_handle_delete = *grib4perlc::grib_handle_delete;
*grib_get_double = *grib4perlc::grib_get_double;
*grib_get_long = *grib4perlc::grib_get_long;
*grib_get_size = *grib4perlc::grib_get_size;
*grib_get_double_array = *grib4perlc::grib_get_double_array;
*grib_get_long_array = *grib4perlc::grib_get_long_array;
*grib_get_double_element = *grib4perlc::grib_get_double_element;
*grib_get_string = *grib4perlc::grib_get_string;
*grib_iterator_new = *grib4perlc::grib_iterator_new;
*grib_iterator_next = *grib4perlc::grib_iterator_next;
*grib_iterator_previous = *grib4perlc::grib_iterator_previous;
*grib_iterator_has_next = *grib4perlc::grib_iterator_has_next;
*grib_iterator_reset = *grib4perlc::grib_iterator_reset;
*grib_iterator_delete = *grib4perlc::grib_iterator_delete;
*grib_keys_iterator_new = *grib4perlc::grib_keys_iterator_new;
*grib_keys_iterator_next = *grib4perlc::grib_keys_iterator_next;
*grib_keys_iterator_get_name = *grib4perlc::grib_keys_iterator_get_name;
*grib_keys_iterator_delete = *grib4perlc::grib_keys_iterator_delete;
*grib_keys_iterator_rewind = *grib4perlc::grib_keys_iterator_rewind;
*grib_keys_iterator_set_flags = *grib4perlc::grib_keys_iterator_set_flags;

# ------- VARIABLE STUBS --------

package grib4perl;

*GRIB_KEYS_ITERATOR_ALL_KEYS = *grib4perlc::GRIB_KEYS_ITERATOR_ALL_KEYS;
*MAX_KEY_LEN = *grib4perlc::MAX_KEY_LEN;
*MAX_VAL_LEN = *grib4perlc::MAX_VAL_LEN;
1;

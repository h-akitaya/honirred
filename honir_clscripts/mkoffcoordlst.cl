#
#  mkoffcoordlst.cl
#   make offset coordinate list
#
#     Ver 1.00  2013/07/11  H. Akitaya
#

procedure mkoffcoordlst( coord_template, x_obj, y_obj, list_fn )

string coord_template {prompt = "template coordinate file"}
real x_obj {prompt = "object x"}
real y_obj {prompt = "object y"}
string list_fn {prompt = "output list file name"}
bool override=yes

begin

string coord_template_, list_fn_
real x_obj_, y_obj_
real x_tmpl, y_tmpl, x_off, y_off, dx, dy
bool flag_first=yes

coord_template_ = coord_template
x_obj_ = x_obj
y_obj_ = y_obj
list_fn_ = list_fn

if( access( list_fn_ ) ) {
    if ( override == yes ) {
        delete( list_fn, ver- )
    }else{
        error(1, "# Old list file "//list_fn_//" exists. Aborted." )
    }
}

if( !access( coord_template_ ) ) {
    error(1, "# Coordinate template file "//coord_template_//" not found. Aborted." )
}

list = coord_template_
while( fscan( list, x_tmpl, y_tmpl ) != EOF ){
    if( flag_first == yes ){
        dx = x_obj_ - x_tmpl
        dy = y_obj_ - y_tmpl
	flag_first = no
    }
    x_off = x_tmpl + dx 
    y_off = y_tmpl + dy 
    printf("%7.2f %7.2f\n", x_off, y_off, >> list_fn )
}

# output
#printf( "# Done.\n" )

bye

end

#end


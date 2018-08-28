#
# getimcur.cl
# Ver 1.0 2013/02/27 H. Akitaya
#

procedure getimcur

#string data_fn { prompt = "Data file name"}
#int x_0 {prompt = "x0" }
#int y_0 {prompt = "y0" }
#int width {prompt = "search width" }

begin

real x_cur, y_cur
string data_fn
data_fn = mktemp( "_tmp_getimcur_" )


print( imcur, > data_fn )
type( data_fn )
#=fscan( imcur, x_cur, y_cur)
#printf("%f %f\n", x_cur, y_cur )

delete( data_fn, ver- )

end

#end of the script

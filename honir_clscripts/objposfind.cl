#
# objposfind
# Ver 1.0 2011/12/26 H. Akitaya
#

procedure objposfind( in_image, x_0, y_0, width )

string in_image { prompt = "Input image"}
int x_0 {prompt = "x0" }
int y_0 {prompt = "y0" }
int width {prompt = "search width" }

begin

real x_c, y_c
string dummy1, dummy2, dummy3

imcntr( in_image, x_0, y_0, cboxsize=width ) | scanf( "%s %s %f %s %f", dummy1, dummy2, x_c, dummy3, y_c )
printf("%6.1f %6.1f %6.1f %6.1f\n", x_c, y_c, x_0, y_0 )

end

#end of the script

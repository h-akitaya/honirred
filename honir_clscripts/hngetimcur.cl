#
# hngetimcur.cl
# 
# Ver 1.0 2014/07/17 H. Akitaya
#

procedure hngetimcur

begin

int x,y
int wcs
struct command

i=fscan( imcur, x, y, wcs, command)
printf("%9.0f %9.0f\n", x, y )

end

#end of the script

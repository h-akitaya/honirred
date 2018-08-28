#
# getregion.cl
# 
# Ver 1.0 2014/07/17 H. Akitaya
#

procedure getregion

begin

int x1,y1,x2,y2,buf
int wcs
struct command

i=fscan( imcur, x1, y1, wcs, command)
i=fscan( imcur, x2, y2, wcs, command)
if( x1>x2 ){
    buf=x2
    x2=x1
    x1=buf
}
if( y1>y2 ){
    buf=y2
    y2=y1
    y1=buf
}
printf("[%d:%d,%d:%d]\n", x1, x2, y1, y2 )

end

#end of the script

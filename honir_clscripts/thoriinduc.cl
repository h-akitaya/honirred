#
# thoriinduc
# Ver 1.0 2011/12/26 H. Akitaya
#


procedure thoriinduc
#procedure thoriinduc( in_image )

#string in_image { prompt = "Input image"}

begin

string in_image
real x_c, y_c
string dummy1, dummy2, dummy3, date, subdir, header, nimagestr
string basedir="/home/messia/messia20110302/local/"
string prefixfile ="prefix.txt"
int nimage, nsample, hwidth
int x_0 = 320
int y_0 = 535
int width = 25

head( basedir//prefixfile, nlines=1 ) | scanf("%2s%6s%2s", dummy1, date, dummy2 )
subdir = "20"//date//"/"
logfile= basedir//subdir//"HN20"//date//".log"
printf( "logfile: %s\n", logfile )

tail( logfile, nlines=1 ) | scanf("%s %s %s %i %i", header, dummy1, dummy1, nsample, nimage )

nimage-=1
nimagestr=substr( "0"//str(nimage), 1, 2 )

in_image = basedir//subdir//header//"ira"//nimagestr//".fits"
printf("image file: %s\n", in_image)

#printf("%s\n", width )
imcntr( in_image, x_0, y_0, cboxsize=width )
imcntr( in_image, x_0, y_0, cboxsize=width ) | scanf( "%s %s %f %s %f", dummy1, dummy2, x_c, dummy3, y_c )

#printf("virgoinduc %6.1f %6.1f %6.1f %6.1f\n", x_c, y_c, x_0, y_0 )
printf("/home/messia/bin/virgoinduc.sh %6.1f %6.1f %6.1f %6.1f\n", x_c, y_c, x_0, y_0 )
printf("/home/messia/bin/virgoinduc.sh %6.1f %6.1f %6.1f %6.1f\n", x_c, y_c, x_0, y_0 ) | sh

end

#end of the script

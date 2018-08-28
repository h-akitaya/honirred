#
#  vgntest.cl
#  HONIR Virgo noise examination
#
#           Ver 0.10 2012.10.19 H.Akitaya
#
#  vgntest (file(s)) (port; 0 = all)
#
procedure vgntest ( _in_images, _port )

string _in_images { prompt = "Image Name or list"}
int _port { prompt = "port No." }
bool ver = no

struct *imglist

begin
     string imgfiles, in_images, img, reg
     int reg_x1[5], i, port, xw, reg_x2,reg_y1, reg_y2
     real stddev

     in_images = _in_images
     port = _port

     xw=50
     reg_y1=1801
     reg_y2=1820
     reg_x1[1]=201
     reg_x1[2]=701
     reg_x1[3]=1201
     reg_x1[4]=1701

     if (ver == yes ) print("# vgntest.cl Ver 0.10" )

     imgfiles = mktemp ( "tmp$_hntrim_tmp5" )
     sections( in_images, option="fullname", > imgfiles )

     imglist = imgfiles
     while( fscan( imglist, img ) != EOF ){
        if( port ==0 ) printf( "%s ", img)
	for(i=1; i<=4; i+=1){
	   reg_x2 = reg_x1[i]+xw-1	
           reg = "["//reg_x1[i]//":"//reg_x2//","//reg_y1//":"//reg_y2//"]"
	   if (port == 0 || port == i ){
	     imstat( img//reg, format-, field="stddev" ) | scanf("%f", stddev)
	     printf("%8.2f ", stddev )
           }
        }
	printf("\n")
     }

     delete( imgfiles, ver-, >& "dev$null" )
     if (ver == yes ) print("# Done. (vgntest.cl)" ) 

end

# end of the script

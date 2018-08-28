#
#   hnoediv.cl
#
#   (from lpoediv.cl
#     LIPS : divide the spectrum into o-ray and e-ray
#           Ver 1.00 2005. 8.16 H.Akitaya )
#
#      2014/03/30 Ver 1.00 H. Akiyaya
#
#  input : ( file(s) or @list-file )
#
#  need environment variable:
#     num_apertures
#

procedure lpoediv ( in_images )

string in_images="@obj_all.lst" { prompt = "Image Name"}
string se_in { ".dc" }
string se_out { ".dc" }
string mainext { ".fits" }
struct *imglist
bool override = no

begin
     string imgfiles, img, fn_in, fn_out, str_comment, str_tmp, fn_root
     string ext_pol[2], ap_str[2]
     int i
     int num_apertures = 2
     
     ext_pol[1]="o"
     ext_pol[2]="e"
     
     print("# lpoediv.cl Ver 1.00" )

#     num_apertures = int( envget( "num_apertures" ) )
     if ( num_apertures <= 0 )
         error(1, "# Fatal error !!" )
     if( mod( num_apertures, 2 ) != 0 )
         print("# WARNING!!!! number of o-ray and e-ray differs !!" )
	 
     print( "# aperture number : "//num_apertures )
     apstr( num_apertures, "odd" )  | scanf("%s", str_tmp)
     ap_str[1]= str_tmp
     apstr( num_apertures, "even" ) | scanf("%s", str_tmp)
     ap_str[2]=str_tmp
         
     imgfiles = mktemp ( "tmp$tmp_hnoediv" )
     
     sections( in_images, option="fullname", > imgfiles )

     imglist = imgfiles
     while( fscan( imglist, img ) != EOF ){
     
         # get rid of the extentions
         extsrm( img, mainext, se_in ) | scanf( "%s", fn_root )
	   
         #make file list
#         fn_in = fn_root//se_in//mainext
	  fn_in = img

	 for( i=1; i <=2; i+=1 ){
	     fn_out = fn_root//"_"//ext_pol[i]//se_out//mainext
	     str_comment = ""
	     if( access( fn_out ) && override == no ){
	         str_comment = "(old result exists. Skip.)"
	     }else{
	         if( access( fn_out ) ){
	             imdelete( fn_out, ver- )
	             str_comment = "(Override.)"
	         }
		 scopy( fn_in, fn_out, apertures=ap_str[i], beams="", \
                        renumber+, verbose- )
		 hedit( fn_out, "POLMODE", ext_pol[i], add+, ver- )
	     }
             printf("# %15s %15s %s %s\n", fn_in, fn_out, ap_str[i], str_comment )
	 }
     }

     # check result
     
     delete( imgfiles, ver-, >& "dev$null" )
     
     print("# Done. (hnoediv.cl)" )

end

# end of the script

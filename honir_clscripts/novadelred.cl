#
#  novadelred.cl
#
#  input : file(s) or @list-file
#

procedure novadelred.cl ( in_images )

string in_images { prompt = "Image Name"}

struct *imglist

begin
     string in_images_,img_root, fn_in, fn_out, img, imgfiles

     in_images_ =in_images
#     mainext="fits"
     
     #read area
#     real wl1 = 6400
#     real wl2 = 6750
     

     imgfiles = mktemp ( "tmp$_novadelred_tmp1" )
     sections( in_images_, option="fullname", > imgfiles )

     imglist = imgfiles
     while( fscan( imglist, img ) != EOF ){
     
        # get rid of the extentions
        extsrm( img, "fits", "" ) | scanf( "%s", img_root )

	# make file names 
	fn_in = img
	fn_out = img_root//"xy"
	listpix( fn_in, wcs="world", > fn_out )
     }

     delete( imgfiles, ver-, >& "dev$null" )
     print("# Done. " )

end

# end of the script

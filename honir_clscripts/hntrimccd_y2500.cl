#
#  hntrimccd.cl
#  HONIR overscan region subtraction & trimming for CCD
#                 y:1-2500 version
#
#           Ver 0.01 2011. 9. 30 H.Akitaya
#                    2011.10. 21 H.Akitaya; renamed task name
#           Ver 0.01-v2500-1 2012. 9.24 H. Akitaya : for Y=1-2500 image
#           Ver 0.01-v2500-2 2014/03/03 H. Akitaya
#
#  input : file(s) or @list-file
#

procedure hntrimccd_y2500 ( in_images )

string in_images { prompt = "Image Name"}
string se_in = ""
string se_out = "_bt"
string mainext = ".fits"

struct *imglist

begin
     string imgfiles, img, fn_in, fn_out
     string area1, area2, area3, area4
     string image1, image2, image3, image4
     string tmp_area1, tmp_area2, tmp_area3, tmp_area4
     string tmp_image1, tmp_image2, tmp_image3, tmp_image4, tmp_joinlist
     int i,j, n_mainext
     real biasval
     
     #read area
     int area1_x1 = 1
     int area1_x2 = 536
     int area2_x1 = 537
     int area2_x2 = 1072
     int area3_x1 = 1073
     int area3_x2 = 1608
     int area4_x1 = 1609
     int area4_x2 = 2144
     int area_y1 = 1
     int area_y2 = 2500

     #image area
     int image1_x1 = 9
     int image1_x2 = 520
     int image2_x1 = 17
     int image2_x2 = 528
     int image3_x1 = 9
     int image3_x2 = 520
     int image4_x1 = 17 
     int image4_x2 = 528
     int image_y1 = 3
     int image_y2 = 2500

     #pre-/over-scan region
     int pre1_x1 = 1
     int pre1_x2 = 8
     int over1_x1 = 521
     int over1_x2 = 536
     int pre2_x1 = 1
     int pre2_x2 = 16
     int over2_x1 = 529
     int over2_x2 = 536
     int pre3_x1 = 1
     int pre3_x2 = 8
     int over3_x1 = 521
     int over3_x2 = 536
     int pre4_x1 = 1
     int pre4_x2 = 16
     int over4_x1 = 529
     int over4_x2 = 536

     print("# hntrimccd_y2500.cl Ver 0.01" )

     area1 = "["//area1_x1//":"//area1_x2//","//area_y1//":"//area_y2//"]"
     area2 = "["//area2_x1//":"//area2_x2//","//area_y1//":"//area_y2//"]"
     area3 = "["//area3_x1//":"//area3_x2//","//area_y1//":"//area_y2//"]"
     area4 = "["//area4_x1//":"//area4_x2//","//area_y1//":"//area_y2//"]"
     image1 = "["//image1_x1//":"//image1_x2//","//image_y1//":"//image_y2//"]"
     image2 = "["//image2_x1//":"//image2_x2//","//image_y1//":"//image_y2//"]"
     image3 = "["//image3_x1//":"//image3_x2//","//image_y1//":"//image_y2//"]"
     image4 = "["//image4_x1//":"//image4_x2//","//image_y1//":"//image_y2//"]"
#     printf("# area1: %s\n", area1 )
#     printf("# area2: %s\n", area2 )
#     printf("# area3: %s\n", area3 )
#     printf("# area4: %s\n", area4 )
     
     imgfiles = mktemp ( "tmp$_hntrim_tmp5" )
     sections( in_images, option="fullname", > imgfiles )

     imglist = imgfiles
     while( fscan( imglist, img ) != EOF ){
     
        tmp_area1 = mktemp ( "tmp$_hntrim_ccd_area_tmp1" )
        tmp_area2 = mktemp ( "tmp$_hntrim_ccd_area_tmp2" )
        tmp_area3 = mktemp ( "tmp$_hntrim_ccd_area_tmp3" )
        tmp_area4 = mktemp ( "tmp$_hntrim_ccd_area_tmp4" )
        tmp_image1 = mktemp ( "tmp$_hntrim_ccd_image_tmp1" )
        tmp_image2 = mktemp ( "tmp$_hntrim_ccd_image_tmp2" )
        tmp_image3 = mktemp ( "tmp$_hntrim_ccd_image_tmp3" )
        tmp_image4 = mktemp ( "tmp$_hntrim_ccd_image_tmp4" )

        # get rid of the extentions
        extsrm( img, mainext, se_in ) | scanf( "%s", img )

	# make file names 
	fn_in = img//se_in//mainext
	fn_out = img//se_out//mainext

	# extract four channel areas
	imcopy( fn_in//area1, tmp_area1, ver- )
	imcopy( fn_in//area2, tmp_area2, ver- )
	imcopy( fn_in//area3, tmp_area3, ver- )
	imcopy( fn_in//area4, tmp_area4, ver- )

	chpixtype( tmp_area1, tmp_area1, newpixtype="real", ver- )
	chpixtype( tmp_area2, tmp_area2, newpixtype="real", ver- )
	chpixtype( tmp_area3, tmp_area3, newpixtype="real", ver- )
	chpixtype( tmp_area4, tmp_area4, newpixtype="real", ver- )

	# bias subtraction
	printf( "Bias subtaction." )
		
        background( tmp_area1, tmp_area1, axis=1,\
                sample=pre1_x1//":"//pre1_x2//","//over1_x1//":"//over1_x2, \
		naverage=1, function="legendre", order=1, low_reject=2.5,\
                high_reject=1.0, niterate=3, interactive- )
	
        background( tmp_area2, tmp_area2, axis=1,\
                sample=pre2_x1//":"//pre2_x2//","//over2_x1//":"//over2_x2, \
		naverage=1, function="legendre", order=1, low_reject=2.5,\
                high_reject=1.0, niterate=3, interactive- )
	
        background( tmp_area3, tmp_area3, axis=1,\
                sample=pre3_x1//":"//pre3_x2//","//over3_x1//":"//over3_x2, \
		naverage=1, function="legendre", order=1, low_reject=2.5,\
                high_reject=1.0, niterate=3, interactive- )
	
        background( tmp_area4, tmp_area4, axis=1,\
                sample=pre4_x1//":"//pre4_x2//","//over4_x1//":"//over4_x2, \
		naverage=1, function="legendre", order=1, low_reject=2.5,\
                high_reject=1.0, niterate=3, interactive- )

	# extract four image areas
	imcopy( tmp_area1//image1, tmp_image1, ver- )
	imcopy( tmp_area2//image2, tmp_image2, ver- )
	imcopy( tmp_area3//image3, tmp_image3, ver- )
	imcopy( tmp_area4//image4, tmp_image4, ver- )

	tmp_joinlist = mktemp("tmp$_tmp_hnbtrim_ccd_joinlist")
	print(tmp_image1, > tmp_joinlist)
	print(tmp_image2, >> tmp_joinlist)
	print(tmp_image3, >> tmp_joinlist)
	print(tmp_image4, >> tmp_joinlist)

	# bias subtraction
	if( ! access( fn_out ) ){
	    imjoin( input="@"//tmp_joinlist, output=fn_out, join_dimension=1, verbose- )
	    printf("# %s -> %s\n", fn_in, fn_out )
	}else{
	    printf("# Error: output file %s exists.\n", fn_out )
	}
     	# clean up
    	imdelete( tmp_area1, ver-, >& "dev$null" )
     	imdelete( tmp_area2, ver-, >& "dev$null" )
     	imdelete( tmp_area3, ver-, >& "dev$null" )
     	imdelete( tmp_area4, ver-, >& "dev$null" )
     	imdelete( tmp_image1, ver-, >& "dev$null" )
     	imdelete( tmp_image2, ver-, >& "dev$null" )
     	imdelete( tmp_image3, ver-, >& "dev$null" )
     	imdelete( tmp_image4, ver-, >& "dev$null" )
     	delete( tmp_joinlist, ver-, >& "dev$null" )
     }

     delete( imgfiles, ver-, >& "dev$null" )
     print("# Done. (hntrimccd.cl)" )

end

# end of the script

#
#  hntrimccd.cl
#  HONIR overscan region subtraction & trimming for CCD
#
#           Ver 0.01 2011. 9. 30 H.Akitaya
#                    2011.10. 21 H.Akitaya; renamed task name
#           Ver 0.10 2012.10. 19 H.Akitaya; trivial modifications
#           Ver 0.20 2013/07/29  H.Akitaya; override option, etc.
#           Ver 1.00 2014/03/03  H.Akitaya
#           Ver 1.10 2014/03/12  H.Akitaya: dealing with partial read mode
#           Ver 1.11 2014/03/18  H.Akitaya: clean option
#           Ver 1.12 2014.04.07 H.Akitaya
#               check already processed or not, ira image
#           Ver 1.13 2014.04.14 H.Akitaya : bug-fix for y2 treatment
#
#  input : file(s) or @list-file
#

procedure hntrimccd ( images )

string images { prompt = "Image Name"}
string se_in = ""
string se_out = "_bt"
string mainext = ".fits"
string outlist = ""
bool override = no
bool clean = no
struct *imglist

begin
     string imgfiles, img, fn_in, fn_out, img_root
     string area1, area2, area3, area4
     string image1, image2, image3, image4, in_images
     string tmp_area1, tmp_area2, tmp_area3, tmp_area4
     string tmp_image1, tmp_image2, tmp_image3, tmp_image4, tmp_joinlist
     string hnarm, processed
     int i,j, n_mainext, tmp_y
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
     int area_y2_full = 4240
     int area_y2

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
     int image_y2_full = 4225
     int image_y2

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

     in_images = images

     print("# hntrimccd.cl" )

     if( outlist != "" && access( outlist ) ){
       printf("# output list file %s exists.\n", outlist )
       if( override == yes ){
         printf("# Delete old list file.\n" )
	 delete( outlist, ver- )
       }else{
         error(1, "# Abort.")
       }
     }
     
     imgfiles = mktemp ( "tmp$_hntrim_tmp5" )
     sections( in_images, option="fullname", > imgfiles )

     imglist = imgfiles
     while( fscan( imglist, img ) != EOF ){
     
        # get rid of the extentions
        extsrm( img, mainext, se_in ) | scanf( "%s", img_root )

	# make file names 
#	fn_in = img_root//se_in//mainext
	fn_in = img
	fn_out = img_root//se_out//mainext

	if( !access( fn_in ) ){
	    printf("##### Error!! Input file %s does not exists. #####\n", img )
	    next
	}

        hselect( fn_in, "HN-ARM", yes ) | scan( hnarm )
	if( hnarm != "opt" ){
	    printf("%s is not an CCD image !\n", fn_in )
	    next
	}
	processed="no"
        hselect( fn_in, "HNTRIMC", yes, missing=no ) | scan( processed )
	if( processed == "yes" ){
	    printf("%s has been already processed by hntrimccd.\n", fn_in )
	    next
	}
	
	# removing overscan region
	if( outlist != "" )
	  printf("%s\n", fn_out, >> outlist )
	if( access( fn_out ) ){
	    printf("##### Output file %s exists. ####\n", fn_out )
	    if ( override == no ) {
	        printf("# Skip.\n" )
		next
            } else {
	        printf("##### Delete old file. ####\n" )
  		imdelete( fn_out, ver- )
            }
        }
	imgets( fn_in, "i_naxis2")
	tmp_y = int( imgets.value )
	if ( tmp_y != area_y2_full ){
	  printf("#partial read image (Y=1-%d)\n", tmp_y ) 
	  area_y2 = tmp_y
  	  image_y2 = tmp_y
        }else{
	  area_y2 = area_y2_full
  	  image_y2 = image_y2_full
	}

        area1 = "["//area1_x1//":"//area1_x2//","//area_y1//":"//area_y2//"]"
        area2 = "["//area2_x1//":"//area2_x2//","//area_y1//":"//area_y2//"]"
        area3 = "["//area3_x1//":"//area3_x2//","//area_y1//":"//area_y2//"]"
        area4 = "["//area4_x1//":"//area4_x2//","//area_y1//":"//area_y2//"]"
        image1 = "["//image1_x1//":"//image1_x2//","//image_y1//":"//image_y2//"]"
        image2 = "["//image2_x1//":"//image2_x2//","//image_y1//":"//image_y2//"]"
        image3 = "["//image3_x1//":"//image3_x2//","//image_y1//":"//image_y2//"]"
        image4 = "["//image4_x1//":"//image4_x2//","//image_y1//":"//image_y2//"]"

        tmp_area1 = mktemp ( "tmp$_hntrim_ccd_area_tmp1" )
        tmp_area2 = mktemp ( "tmp$_hntrim_ccd_area_tmp2" )
        tmp_area3 = mktemp ( "tmp$_hntrim_ccd_area_tmp3" )
        tmp_area4 = mktemp ( "tmp$_hntrim_ccd_area_tmp4" )
        tmp_image1 = mktemp ( "tmp$_hntrim_ccd_image_tmp1" )
        tmp_image2 = mktemp ( "tmp$_hntrim_ccd_image_tmp2" )
        tmp_image3 = mktemp ( "tmp$_hntrim_ccd_image_tmp3" )
        tmp_image4 = mktemp ( "tmp$_hntrim_ccd_image_tmp4" )

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
	printf( "# Removing and trimming overscan region.\n" )
		
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
        imjoin( input="@"//tmp_joinlist, output=fn_out, join_dimension=1, verbose- )
        hedit( fn_out, "HNTRIMC", yes, add+, verify- )
        printf("# %s -> %s\n", fn_in, fn_out )

	# delete original file ( if clean+)
	if( access( fn_out ) && clean == yes )	imdelete( fn_in, ver- )

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

#
#  hntrimvirgo_old.cl
#  HONIR Virgo image trimming
#     for images with wrong ref. pix. 
#
#           Ver 0.01 2011. 8.10(?) H.Akitaya
#           Ver 0.02 2011.10.21 H.Akitaya
#                    2012/10/19 H. Akitaya
#            renamed from hntrimvirgo.cl to hntrimvirgo_old.cl
#
#
#  input : file(s) or @list-file
#

procedure hntrimvirgo_old ( _in_images )

string _in_images { prompt = "Image Name"}
string subext_in = ""
string subext_out = "_bt"
string mainext = ".fits"

struct *imglist

begin
     string imgfiles, img, fn_in, fn_out
     string region1, region2, region3, region4
     string tmp_region1, tmp_region2, tmp_region3, tmp_region4, tmp_joinlist
     int i,j, n_mainext
     real biasval
     string in_images
     in_images = _in_images

     int region1_x1 = 6
     int region1_x2 = 517
     int region2_x1 = 524
     int region2_x2 = 1035
     int region3_x1 = 1042
     int region3_x2 = 1553
     int region4_x1 = 1560
     int region4_x2 = 2071
     int region_y1 = 2
     int region_y2 = 2049

     print("# hntrimvirgo.cl Ver 0.02" )

     region1 = "["//region1_x1//":"//region1_x2//","//region_y1//":"//region_y2//"]"
     region2 = "["//region2_x1//":"//region2_x2//","//region_y1//":"//region_y2//"]"
     region3 = "["//region3_x1//":"//region3_x2//","//region_y1//":"//region_y2//"]"
     region4 = "["//region4_x1//":"//region4_x2//","//region_y1//":"//region_y2//"]"
     printf("# region1: %s\n", region1 )
     printf("# region2: %s\n", region2 )
     printf("# region3: %s\n", region3 )
     printf("# region4: %s\n", region4 )
     
     imgfiles = mktemp ( "tmp$_hntrim_tmp5" )
     sections( in_images, option="fullname", > imgfiles )

     imglist = imgfiles
     while( fscan( imglist, img ) != EOF ){
     
        tmp_region1 = mktemp ( "tmp$_hntrim_virgo_tmp1" )
        tmp_region2 = mktemp ( "tmp$_hntrim_virgo_tmp2" )
        tmp_region3 = mktemp ( "tmp$_hntrim_virgo_tmp3" )
        tmp_region4 = mktemp ( "tmp$_hntrim_virgo_tmp4" )
        # get rid of the extentions
        extsrm( img, mainext, subext_in ) | scanf( "%s", img )

	# make file names 
	fn_in = img//subext_in//mainext
	fn_out = img//subext_out//mainext

	# measure overscan-region bias value
	imcopy( fn_in//region1, tmp_region1, ver- )
	imcopy( fn_in//region2, tmp_region2, ver- )
	imcopy( fn_in//region3, tmp_region3, ver- )
	imcopy( fn_in//region4, tmp_region4, ver- )
        chpixtype( tmp_region1, tmp_region1, newpixtype="real", ver- )
        chpixtype( tmp_region2, tmp_region2, newpixtype="real", ver- )
        chpixtype( tmp_region3, tmp_region3, newpixtype="real", ver- )
        chpixtype( tmp_region4, tmp_region4, newpixtype="real", ver- )

	tmp_joinlist = mktemp("tmp$_tmp_hnbtrim_virgo_joinlist")
	print(tmp_region1, > tmp_joinlist)
	print(tmp_region2, >> tmp_joinlist)
	print(tmp_region3, >> tmp_joinlist)
	print(tmp_region4, >> tmp_joinlist)

	# bias subtraction
	if( ! access( fn_out ) ){
	    imjoin( input="@"//tmp_joinlist, output=fn_out, join_dimension=1, verbose- )
	    printf("# %s -> %s\n", fn_in, fn_out )
	}else{
	    printf("# Error: output file %s exists.\n", fn_out )
	}
     # clean up
     delete( tmp_region1, ver-, >& "dev$null" )
     delete( tmp_region2, ver-, >& "dev$null" )
     delete( tmp_region3, ver-, >& "dev$null" )
     delete( tmp_region4, ver-, >& "dev$null" )
     delete( tmp_joinlist, ver-, >& "dev$null" )
     
     }

     delete( imgfiles, ver-, >& "dev$null" )
     print("# Done. (hntrimvirgo.cl)" )

end

# end of the script

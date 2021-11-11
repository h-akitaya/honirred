#
#  hnbtrimvirgo.cl
#  HONIR Virgo image trimming
#
#           Ver 0.01 2011. 8.10(?) H.Akitaya
#           Ver 0.02 2011.10.21 H.Akitaya
#           Ver 0.10 2012.10.21 H.Akitaya
#		for correct ref. pix. distribution
#           Ver 0.11 2012.10.31 H.Akitaya
#           Ver 0.12 2013.01.27 H.Akitaya
#               check image size
#           Ver 0.13 2013.05. 7 H.Akitaya
#               bug fix (deleting temporary files)
#           Ver 1.00 2014.02. 8 H.Akitaya
#               variable names modification
#           Ver 1.01 2014.02.10 H.Akitaya
#               output list function
#           Ver 1.02 2014.02.12 H.Akitaya
#               cleaning mode
#           Ver 1.10 2014.03.03 H.Akitaya
#               subext_ -> se_
#           Ver 1.11 2014.04.07 H.Akitaya
#               check already processed or not, ira image
#           
#
#  input : file(s) or @list-file
#

procedure hnbtrim_virgo ( in_images )

string in_images { prompt = "Image Name" }
string se_in = ""
string se_out = "_bt"
string mainext = ".fits"
string outlist = ""
bool override = no
bool clean = no

struct *imglist

begin
     string imgfiles, img, fn_in, fn_out, img_root, images
     string reg1, reg2, reg3, reg4
     string tmp_reg1, tmp_reg2, tmp_reg3, tmp_reg4, tmp_joinlist, hnarm
     int i,j, n_mainext
     int size_x, size_y
     real biasval
     string processed

     int reg1_x1 = 3
     int reg1_x2 = 514
     int reg2_x1 = 521
     int reg2_x2 = 1032
     int reg3_x1 = 1039
     int reg3_x2 = 1550
     int reg4_x1 = 1557
     int reg4_x2 = 2068
     int reg_y1 = 2
     int reg_y2 = 2049

     images = in_images
	
     print("# hntrimvirgo.cl" )
	
     reg1 = "["//reg1_x1//":"//reg1_x2//","//reg_y1//":"//reg_y2//"]"
     reg2 = "["//reg2_x1//":"//reg2_x2//","//reg_y1//":"//reg_y2//"]"
     reg3 = "["//reg3_x1//":"//reg3_x2//","//reg_y1//":"//reg_y2//"]"
     reg4 = "["//reg4_x1//":"//reg4_x2//","//reg_y1//":"//reg_y2//"]"
#     printf("# region1: %s\n", reg1 )
#     printf("# region2: %s\n", reg2 )
#     printf("# region3: %s\n", reg3 )
#     printf("# region4: %s\n", reg4 )
     
     imgfiles = mktemp ( "tmp$_hntrim_tmp5" )
     sections( images, option="fullname", > imgfiles )
     if( outlist != "" ){
	if( access( outlist ) ){
	    printf("# Old output list %s exists. Deleting.\n", outlist )
            delete( outlist, ver- )
        }
     }

     imglist = imgfiles
     while( fscan( imglist, img ) != EOF ){
     
        # get rid of the extentions
        extsrm( img, mainext, se_in ) | scanf( "%s", img_root )

	# make file names 
	fn_in = img
#	fn_in = img//se_in//mainext
	fn_out = img_root//se_out//mainext

	if( !access( img ) ){
	    printf("##### Error!! Input file %s does not exists. #####\n", img )
	    next
	}

        hselect( fn_in, "HN-ARM", yes ) | scan( hnarm )
	if( hnarm != "ira" ){
	    printf("%s is not an IRA VIRGO image !\n", fn_in )
	    next
	}
	processed="no"
        hselect( fn_in, "HNTRIMV", yes, missing=no ) | scan( processed )
	if( processed == "yes" ){
	    printf("%s has been already processed by hntrimvirgo.\n", fn_in )
	    next
	}
        hselect( fn_in, "i_naxis1", yes ) | scan( size_x )
        hselect( fn_in, "i_naxis2", yes ) | scan( size_y )

	if( size_x < reg4_x2 || size_y < reg_y2 ){
            printf("##### Error!! Wrong image size ! #####\n" )
	    next
        }
	if( outlist != "" )
             printf("%s\n", fn_out, >> outlist )

	if( override == no && access( fn_out ) ){
	    printf("# Output file %s exists. Skip.\n", fn_out )
	    next
	}

        tmp_reg1 = mktemp ( "tmp$_hntrim_virgo_tmp1" )
        tmp_reg2 = mktemp ( "tmp$_hntrim_virgo_tmp2" )
        tmp_reg3 = mktemp ( "tmp$_hntrim_virgo_tmp3" )
        tmp_reg4 = mktemp ( "tmp$_hntrim_virgo_tmp4" )

	imcopy( fn_in//reg1, tmp_reg1, ver- )
	imcopy( fn_in//reg2, tmp_reg2, ver- )
	imcopy( fn_in//reg3, tmp_reg3, ver- )
	imcopy( fn_in//reg4, tmp_reg4, ver- )
        chpixtype( tmp_reg1, tmp_reg1, newpixtype="real", ver- )
        chpixtype( tmp_reg2, tmp_reg2, newpixtype="real", ver- )
        chpixtype( tmp_reg3, tmp_reg3, newpixtype="real", ver- )
        chpixtype( tmp_reg4, tmp_reg4, newpixtype="real", ver- )

	tmp_joinlist = mktemp("tmp$_tmp_hnbtrim_virgo_joinlist")
	print(tmp_reg1, > tmp_joinlist)
	print(tmp_reg2, >> tmp_joinlist)
	print(tmp_reg3, >> tmp_joinlist)
	print(tmp_reg4, >> tmp_joinlist)

	if( access( fn_out ) ){
	    printf("# Deleting old file %s.\n", fn_out )
	    imdelete( fn_out, ver- )
	}
        imjoin( input="@"//tmp_joinlist, output=fn_out, \
  	     	       join_dimension=1, verbose- )
        hedit( fn_out, "HNTRIMV", yes, add+, verify- )
        printf("# %s -> %s\n", fn_in, fn_out )
	if( clean == yes ){
	  printf("# Deleting original file (%s).\n", fn_in )
	  imdelete( fn_in, ver- )
       }

        # clean up
        imdelete( tmp_reg1, ver-, >& "dev$null" )
        imdelete( tmp_reg2, ver-, >& "dev$null" )
        imdelete( tmp_reg3, ver-, >& "dev$null" )
        imdelete( tmp_reg4, ver-, >& "dev$null" )
        delete( tmp_joinlist, ver-, >& "dev$null" )
     
     }

     delete( imgfiles, ver-, >& "dev$null" )
     print("# Done. (hntrimvirgo.cl)" )

end

# end of the script

#
#  hnflatten.cl
#  HONIR VIRGO image flattening
# 
#
#           Ver 1.00 2013/01/17 H.Akitaya
#           Ver 1.10 2013/07/11 H.Akitaya
#           Ver 2.00 2014/02/08 H.Akitaya
#                 selection mode, renamed from hnflattenvirgo.cl
#
#  usage: hnflatten (images/list) flatfn="(flat file name)"
#
#

procedure hnflatten( in_images )

string in_images { prompt = "Image Name"}
bool objsel = no
string object = ""
bool fltrsel = no
string filter = ""
string flatfn = ""
string subext_in = "_ds"
string subext_out = "_fl"
string mainext = ".fits"
string outlist=""

struct *imglist

begin
     string imgfiles, img, fn_in, fn_out, images, img_root
     string taskname
     string tmp_reg1, tmp_reg2, tmp_reg3, tmp_reg4, tmp_joinlist
     string header_obj, header_arm, header_fil
     int i,j, n_mainext
     real biasval

     images = in_images
     if( !access( flatfn ) ){
        error(1, "# Flat file "//flatfn//" not found. Aborted." )
     }
     if( outlist !="" ) {
        if( access( outlist ) ){
           error(1, "# Old list file "//outlist//" exists. Aborted." )
        }
     }

     taskname="hnflattenvirgo.cl"
     version="1.10"
     print("# "//taskname//" Ver."//version )

     imgfiles = mktemp ( "tmp$_hntrim_tmp5" )
     sections( images, option="fullname", > imgfiles )

     imglist = imgfiles
     while( fscan( imglist, img ) != EOF ){
     
        # get rid of the extentions
        extsrm( img, mainext, subext_in ) | scanf( "%s", img_root )

	# make file names 
#	fn_in = img
	fn_in = img_root//subext_in//mainext
	fn_out = img_root//subext_out//mainext

	if( objsel == yes ){
	    hselect( fn_in, "OBJECT", yes ) | scanf( "%s", header_obj )
	    if ( object != header_val1 )
                next
        }
        hselect( fn_in, "HN-ARM", yes ) | scanf( "%s", header_arm )
	if( fltrsel == yes ){
            if( header_arm == "ira" )
	       hselect( fn_in, "WH_IRAF2", yes ) | scanf( "%s", header_filter )
	    else
               hselect( fn_in, "WH_OPTF2", yes ) | scanf( "%s", header_filter )
	    if ( filter != header_filter )
                next
        }

	if( access( fn_out ) ){
	    printf("##### Error!! output file %s exists. #####\n", fn_out )
	    next
	}
	imarith( fn_in, "/", flatfn, fn_out, ver- )
	printf("%s -> %s (%3s %4s %s)\n", fn_in, fn_out, \
	header_arm, header_filter, header_obj )
	printf("%s\n", fn_out, >> outlist )
     }

     # clean up
     delete( imgfiles, ver-, >& "dev$null" )
     printf("# list file : %s\n", outlist )
     print("# Done. ("//taskname//")" )

end

# end of the script

#
#  hnflattenvirgo.cl
#  HONIR Dark image subtraction
#
#           Ver 1.00 2013/07/11 H.Akitaya
#
#  usage: hndsubvirgo (images/list) darkfn="(dark file name)"
#

procedure hndsubvirgo( in_images )

string in_images { prompt = "Image Name"}
string darkfn = ""
string subext_in = "_bt"
string subext_out = "_ds"
string mainext = ".fits"
string outlist=""

struct *imglist

begin
     string imgfiles, img, fn_in, fn_out, in_images_, img_root
     string taskname
     string tmp_reg1, tmp_reg2, tmp_reg3, tmp_reg4, tmp_joinlist
     int i,j, n_mainext
     real biasval

     in_images_ = in_images
     if( !access( darkfn ) ){
        error(1, "# Dark file "//darkfn//" not found. Aborted." )
     }
     if( outlist !="" ) {
        if( access( outlist ) ){
           error(1, "# Old list file "//outlist//" exists. Aborted." )
        }
     }

     taskname="hndsubvirgo.cl"
     version="1.00"
     print("# "//taskname//" Ver."//version )

     imgfiles = mktemp ( "tmp$_hntrim_tmp5" )
     sections( in_images_, option="fullname", > imgfiles )

     imglist = imgfiles
     while( fscan( imglist, img ) != EOF ){
     
        # get rid of the extentions
        extsrm( img, mainext, subext_in ) | scanf( "%s", img_root )

	# make file names
	fn_in = img_root//subext_in//mainext
	fn_out = img_root//subext_out//mainext

	if( access( fn_out ) ){
	    printf("##### Error!! output file %s exists. #####\n", fn_out )
	    next
	}
	imarith( fn_in, "-", darkfn, fn_out, ver- )
	printf("%s - %s -> %s\n", fn_in, darkfn, fn_out )
	printf("%s\n", fn_out, >> outlist )
     }

     # clean up
     delete( imgfiles, ver-, >& "dev$null" )
     printf("# list file : %s\n", outlist )
     print("# Done. ("//taskname//")" )

end

# end of the script

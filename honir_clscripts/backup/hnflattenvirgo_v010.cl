#
#  hnflattenvirgo.cl
#  HONIR Virgo image flattening
#
#           Ver 1.00 2013/01/17 H.Akitaya
#
#  usage: hnflattenvirgo (images/list) flatfn="(flat file name)"
#

procedure hnflattenvirgo( _in_images )

string _in_images { prompt = "Image Name"}
string flatfn = ""
string subext_in = "_bt"
string subext_out = "_fl"
string mainext = ".fits"

struct *imglist

begin
     string imgfiles, img, fn_in, fn_out, in_images, img_root
     string taskname
     string tmp_reg1, tmp_reg2, tmp_reg3, tmp_reg4, tmp_joinlist
     int i,j, n_mainext
     real biasval

     in_images = _in_images
     if( !access( flatfn ) ){
        error(1, "# Flat file "//flatfn//" not found. Aborted." )
     }

     taskname="hnflattenvirgo.cl"
     version="1.00"
     print("# "//taskname//" Ver."//version )

     imgfiles = mktemp ( "tmp$_hntrim_tmp5" )
     sections( in_images, option="fullname", > imgfiles )

     imglist = imgfiles
     while( fscan( imglist, img ) != EOF ){
     
        # get rid of the extentions
        extsrm( img, mainext, subext_in ) | scanf( "%s", img_root )

	# make file names 
	fn_in = img
#	fn_in = img//subext_in//mainext
	fn_out = img_root//subext_out//mainext

	if( access( fn_out ) ){
	    printf("##### Error!! output file %s exists. #####\n", fn_out )
	    next
	}
	imarith( fn_in, "/", flatfn, fn_out, ver- )
	printf("%s / %s -> %s\n", fn_in, flatfn, fn_out )
     }

     # clean up
     delete( imgfiles, ver-, >& "dev$null" )
     print("# Done. ("//taskname//")" )

end

# end of the script

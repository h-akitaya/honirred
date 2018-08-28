#
#  hnflattenvirgo.cl
#  HONIR Dark image subtraction
#
#           Ver 1.00 2013/07/11 H.Akitaya
#           Ver 1.10 2013/07/18 H.Akitaya
#           Ver 1.20 2014/02/08 H.Akitaya
#           Ver 1.21 2014/03/03 H.Akitaya
#           Ver 1.22 2014/03/30 H.Akitaya; clean mode
#
#  usage: hndsubvirgo (images/list) darkfn="(dark file name)"
#

procedure hndsubvirgo( in_images )

string in_images { prompt = "Image Name"}
string darkfn = ""
string darklst = ""
#bool objsel = no
string object = ""
string se_in = "_bt"
string se_out = "_ds"
string mainext = ".fits"
string outlist=""
bool override=no
bool clean=no

struct *imglist

begin
     string imgfiles, img, fn_in, fn_out, img_root, images
     string taskname
     string tmp_reg1, tmp_reg2, tmp_reg3, tmp_reg4, tmp_joinlist
     string header_obj
     int i,j, n_mainext, n_darklst
     string darklst_fn[99]
     real darklst_expt[99]
     real biasval, exptime0
     bool objsel = no

     images = in_images
     n_darklst=0
     if( access( darklst ) ){
         list=darklst
         while( fscan( list, img) != EOF ){
	     n_darklst += 1
	     if( access( img ) ){
		 imgets( img, "EXPTIME0" )
	         darklst_fn[n_darklst] = img
		 darklst_expt[n_darklst] = real( imgets.value )
	     }
	 }
     }
     if( !access( darkfn ) && n_darklst == 0 ){
        error(1, "# Dark file "//darkfn//" not found. Aborted." )
     }
     if( outlist !="" ) {
        if( access( outlist ) ){
           print("# Old list file "//outlist//" exists." )
	   if( override == no ){
	       error(1, "Abort." )
	   } else {
	       delete( outlist, ver-)
               print("# Deleting." )
	   }
        }
     }
     if( object != "" )
       objsel = yes

     taskname="hndsubvirgo.cl"
     print("# "//taskname )

     imgfiles = mktemp ( "tmp$_hntrim_tmp5" )
     sections( images, option="fullname", > imgfiles )

     imglist = imgfiles
     while( fscan( imglist, img ) != EOF ){
     
        # get rid of the extentions
        extsrm( img, mainext, se_in ) | scanf( "%s", img_root )

	# make file names
#	fn_in = img_root//se_in//mainext
	fn_in = img
	fn_out = img_root//se_out//mainext

        hselect( fn_in, "OBJECT", yes ) | scanf( "%s", header_obj )
	if( objsel == yes && object != header_obj )
            next

	if( n_darklst != 0 ) {
	    imgets( fn_in, "EXPTIME0" )
	    exptime0 = real( imgets.value )
	    printf("# exposure time %6.3f\n", exptime0 )
	    darkfn=""
	    for( i=1; i <= n_darklst; i+=1 ){
	        if( darklst_expt[i] == exptime0 ){
		    darkfn=darklst_fn[i]
		    printf("# Dark file : %s\n", darkfn )
		}
	    }
	    if( !access( darkfn ) ){
	      printf("# Appropriate dark frame not found\n" )
	      next
	    }
	}

	if( access( fn_out ) ){
	    printf("# Output file %s exists. #####\n", fn_out )
	    if( override == no ) {
	    	print( "# Skip.")
	        next
            } else {
	       delete( fn_out, ver-)
               print("# Deleting." )
	    }
	}
	imarith( fn_in, "-", darkfn, fn_out, ver- )
	printf("%s - %s -> %s (%s)\n", fn_in, darkfn, fn_out, header_obj )
	if( outlist != "" ){
  	    printf("%s\n", fn_out, >> outlist )
        }
	if( clean == yes ){
	  printf("Deteling original file: %s\n", fn_in )
	  imdelete( fn_in, ver- )
	}
     }

     # clean up
     delete( imgfiles, ver-, >& "dev$null" )
     printf("# list file : %s\n", outlist )
     print("# Done. ("//taskname//")" )

end

# end of the script

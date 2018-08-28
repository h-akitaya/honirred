#
#  hnskysubvirgo.cl
#  HONIR VIRGO grouping sky subtraction
#
#           Ver 1.00 2013/07/13 H.Akitaya
#
#  usage: hngrbskysub (images/list) 
#

procedure hngrbskysub( imglist, skyimglist )

string imglist { prompt = "Image list file" }
string skyimglist { prompt = "Sky image list file" }
#string skyfn = ""
#string subext_in = "_fl"
#string subext_out = "_sk"
#string mainext = ".fits"
#string outlist=""
#bool override = yes

begin

string imglist_fn, skyimglist_fn
string 
imglist_fn=imglist
skyimglist_fn=skyimglist

if( !access( imglist_fn ) ){
   error(1, "# Image list file "//imglist_fn//" not found. Aborted." )
}
if( !access( skyimglist_fn ) ){
   error(1, "# Image list file "//skyimglist_fn//" not found. Aborted." )
}


string imgfiles, img, fn_in, fn_out, in_images_, img_root
string taskname
real biasval
in_images_ = in_images
}
if( outlist !="" ) {
   if( access( outlist ) ){
	   printf("# Old list file %s exists.\n", outlist )
 if( override== no ){
error(1, "# Abort." )
	   }else{
	  printf("# Delete old list file %s\n", outlist )
	  delete( outlist, ver- )
 }
   }
}

taskname="hngrbskysub.cl"
version="1.00"
print("# "//taskname//" Ver."//version )

imgfiles = mktemp ( "tmp$_hngrbskysub_tmp_1" )
sections( in_images_, option="fullname", > imgfiles )

imglist = imgfiles
while( fscan( imglist, img ) != EOF ){

   # get rid of the extentions
   extsrm( img, mainext, subext_in ) | scanf( "%s", img_root )

	# make file names 
	fn_in = img_root//subext_in//mainext
	fn_out = img_root//subext_out//mainext

	if( access( fn_out ) ){
	    printf("##### output file %s exists. #####\n", fn_out )
	    if ( override==yes ){
	   printf("#Delete old file %s.\n", fn_out )
		imdelete( fn_out, ver- )
	    }else{
	   printf("#Skip.\n", fn_out )
  	   next
  }
	}
	imarith( fn_in, "-", skyfn, fn_out, ver- )
	printf("%s / %s -> %s\n", fn_in, skyfn, fn_out )
	printf("%s\n", fn_out, >> outlist )
}

# clean up
delete( imgfiles, ver-, >& "dev$null" )
printf("# list file : %s\n", outlist )
print("# Done. ("//taskname//")" )


bye
end

# end of the script

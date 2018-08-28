#
#  hnskysub.cl
#  HONIR VIRGO sky subtraction
#
#           Ver 1.00 2013/07/11 H.Akitaya
#           Ver 1.10 2013/07/13 H.Akitaya : group sky function
#           Ver 1.20 2014/02/07 H.Akitaya : scaling sky subtraction etc.
#           Ver 2.00 2014/02/08 H.Akitaya : renamed from hnskysubvirgo.cl
#                       filter, object matching mode
#           Ver 2.01 2014/03/04 H.Akitaya 
#           Ver 2.02 2014/07/29 H.Akitaya 
#           Ver 2.03  2014/03/04  H. Akitaya
#                temporary file name changed
#
#  usage: hnskysub (images/list) 
#

procedure hnskysub( in_images )

string in_images { prompt = "Image Name" }
string skyfn = ""          # sky template file name
string rootskyfn= ""
#bool objsel = no
string object = ""
#bool fltrsel = no
string filter = ""
string se_in = "_fl"
string se_out = "_sk"
string mainext = ".fits"
string outlist=""          # file name of the result file list
bool override = yes        # override results?
bool skygrp = no
bool scaling = yes         # subtract sky after scaling ?
string region ="[1001:1100,1001:1100]" # sky sampling region

struct *imglist

begin
     string imgfiles, img, fn_in, fn_out, in_images_, img_root
     string taskname, buf1, sky_temp
     real sky_object, sky_template, sky_scale
     string header_obj, header_arm, header_filter
     int grpno
     bool objsel = no
     bool fltrsel = no

     in_images_ = in_images

     # welcome message
     taskname="hnskysub.cl"
     print("# "//taskname )

     if ( object != "" )
        objsel = yes
    if ( filter != "" )
        fltrsel = yes

     # checking required files
     if( skygrp == no ) {
        if( !access( skyfn ) ){
           error(1, "# Sky file "//skyfn//" not found. Aborted." )
        }
     }
     if( outlist !="" ) {
        if( access( outlist ) ){
	   printf("# Old list file %s exists.\n", outlist )
           if( override== no ){
               error(1, "# Abort." )
	   }else{
	       printf("# Deleting old list file %s\n", outlist )
	       delete( outlist, ver- )
           }
        }
     }

     # analyzing the input file names or list
     imgfiles = mktemp ( "tmp$hnskysubvirgo_tmp_1_" )
     sections( in_images_, option="fullname", > imgfiles )
     imglist = imgfiles

     # main loop (for each file)
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
        hselect( fn_in, "HN-ARM", yes ) | scanf( "%s", header_arm )
        if( header_arm == "ira" )
            hselect( fn_in, "WH_IRAF2", yes ) | scanf( "%s", header_filter )
        else
            hselect( fn_in, "WH_OPTF2", yes ) | scanf( "%s", header_filter )
        if ( fltrsel == yes && filter != header_filter )
                next
	

	if( access( fn_out ) ){
	    printf("##### output file %s exists. #####\n", fn_out )
	    if ( override == yes ){
	        printf("#Deleting old file %s.\n", fn_out )
		imdelete( fn_out, ver- )
	    }else{
	        printf("#Skip.\n", fn_out )
  	        next
            }
	}
	if( skygrp == yes ){
	    hselect( fn_in, "HNSKYGRP", yes ) | scanf("%s", buf1)
	    if( buf1 == "" ) {
	        print("# Sky group header HNSKYGRP not found. Skip")
		next
            }
	    grpno = int( buf1 )
#	    print( grpno )
	    printf( "%s%03d%s\n", rootskyfn, grpno, mainext ) | scanf( "%s", skyfn )
	}
	if (scaling == no ){
	  printf("# subracting sky %s (without scaled)", skyfn )
	  imarith( fn_in, "-", skyfn, fn_out, ver- )
	} else {
          imstat( fn_in//region, format-, field="midpt" ) | scanf("%f", sky_object)
          imstat( skyfn//region, format-, field="midpt" ) | scanf("%f", sky_template)
	  sky_scale = sky_object / sky_template
	  sky_temp =  mktemp ( "tmp$hnskysubvirgo_tmp_2_" )//".fits"
	  imarith( skyfn, "*", sky_scale, sky_temp )
	  printf("# subracting sky %s (scaled by %7.4f) (%s %s)\n",\
	   skyfn, sky_scale, header_filter, header_obj )
	  imarith( fn_in, "-", sky_temp, fn_out, ver- )
	  imdelete( sky_temp, ver- )
        }
	  	  
	printf("%s / %s -> %s\n", fn_in, skyfn, fn_out )
	if( outlist !="" ) printf("%s\n", fn_out, >> outlist )
     }

     # clean up
     delete( imgfiles, ver-, >& "dev$null" )
     printf("# list file : %s\n", outlist )
     print("# Done. ("//taskname//")" )

bye
end

# end of the script

#
#  hnquickspecpol
#  HONIR quick spectropolarimetry reduction
#
#           Ver 1.00 2014/02/12 H.Akitaya
#
#  usage: hnquickspecpol 
#

procedure hnquickspecpol( spec000_in, spec225_in, spec450_in, spec675_in, out_fn_in )

string spec000_in { prompt = "HWP  0.0 deg (or Cas   0 deg) spectrum" }
string spec225_in { prompt = "HWP 22.5 deg (or Cas  45 deg) spectrum" }
string spec450_in { prompt = "HWP 45.0 deg (or Cas  90 deg) spectrum" }
string spec675_in { prompt = "HWP 67.5 deg (or Cas 135 deg) spectrum" }
string out_fn_in { prompt = "Output spectrum file name" }

bool override = yes        # override results?

#struct *imglist

begin
    string spec000, spec225, spec450, spec675, out_fn
    spec000 = spec000_in
    spec225 = spec225_in
    spec450 = spec450_in
    spec675 = spec675_in
    out_fn = out_fn_in
    strig taskname, taskversion
    taskname="hnquickspecpol.cl"
    taskversion="1.00"

     print("# "//taskname//" Ver."//version )

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
     imgfiles = mktemp ( "tmp$_hnskysubvirgo_tmp_1" )
     sections( in_images_, option="fullname", > imgfiles )
     imglist = imgfiles

     # main loop (for each file)
     while( fscan( imglist, img ) != EOF ){
     
        # get rid of the extentions
        extsrm( img, mainext, subext_in ) | scanf( "%s", img_root )

	# make file names 
	fn_in = img_root//subext_in//mainext
	fn_out = img_root//subext_out//mainext

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
	  sky_temp =  mktemp ( "tmp$_hnskysubvirgo_tmp_" )
	  imarith( skyfn, "*", sky_scale, sky_temp )
	  printf("# subracting sky %s (scaled by %7.4f) (%s %s)\n",\
	   skyfn, sky_scale, header_filter, header_obj )
	  imarith( fn_in, "-", sky_temp, fn_out, ver- )
	  imdelete( sky_temp )
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

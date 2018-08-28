#
#  hnflatten.cl
#  HONIR VIRGO image flattening
# 
#
#           Ver 1.00 2013/01/17 H.Akitaya
#           Ver 1.10 2013/07/11 H.Akitaya
#           Ver 2.00 2014/02/08 H.Akitaya
#                 selection mode, renamed from hnflattenvirgo.cl
#           Ver 2.01 2014/03/03 H.Akitaya
#           Ver 2.10 2014/03/30 H.Akitaya
#
#  usage: hnflatten (images/list) flatfn="(flat file name)"
#
#

procedure hnflatten( in_images )

string in_images { prompt = "Image Name"}
#bool objsel = no
string object = ""
#bool fltrsel = no
string filter = ""
string flatfn = ""
string grism = "" { prompt = "irs|irl|opt"}
string se_in = "_ds"
string se_out = "_fl"
string mainext = ".fits"
string outlist=""
bool override = no
bool clean = no

struct *imglist

begin
     string imgfiles, img, fn_in, fn_out, images, img_root
     string taskname
     string tmp_reg1, tmp_reg2, tmp_reg3, tmp_reg4, tmp_joinlist
     string header_obj, header_arm, header_filter, header_grism, dummy
     int i,j, n_mainext
     real biasval
     bool objsel = no
     bool fltrsel = no
     bool grismsel = no

     taskname="hnflatten.cl"

     images = in_images
     if( !access( flatfn ) ){
        error(1, "# Flat file "//flatfn//" not found. Aborted." )
     }
     if( outlist !="" ) {
        if( access( outlist ) ){
           error(1, "# Old list file "//outlist//" exists. Aborted." )
        }
     }
     if ( object != "" )
       objsel = yes
     if ( filter != "" )
       fltrsel = yes
     if ( grism != "" )
       grismsel = yes

     print("# "//taskname )

     imgfiles = mktemp ( "tmp$_hntrim_tmp5" )
     sections( images, option="fullname", > imgfiles )

     imglist = imgfiles
     while( fscan( imglist, img ) != EOF ){
     
        # get rid of the extentions
        extsrm( img, mainext, se_in ) | scanf( "%s", img_root )

	# make file names 
	fn_in = img
#	fn_in = img_root//se_in//mainext
	fn_out = img_root//se_out//mainext

	hselect( fn_in, "OBJECT", yes ) | scanf( "%s", header_obj )
 	if( objsel == yes && object != header_obj )
                next
        hselect( fn_in, "HN-ARM", yes ) | scanf( "%s", header_arm )
        if( header_arm == "ira" )
            hselect( fn_in, "WH_IRAF2", yes ) | scanf( "%s", header_filter )
        else if ( header_arm == "opt" )
            hselect( fn_in, "WH_OPTF2", yes ) | scanf( "%s", header_filter )
        else
            hselect( fn_in, "WH_IRAF2", yes ) | scanf( "%s", header_filter )
        if ( fltrsel == yes && filter != header_filter )
                next
        if( grismsel == yes ){
          if( header_arm == "ira" )
            hselect( fn_in, "WH_IRAF1", yes ) | scanf( "%s %s", dummy, header_grism )
          else if ( header_arm == "opt" )
            hselect( fn_in, "WH_OPTF1", yes ) | scanf( "%s %s", dummy, header_grism )
          else
            hselect( fn_in, "WH_OPTF1", yes ) | scanf( "%s %s", dummy, header_grism )
	  printf("%s %s\n", fn_in, header_grism )
          if( grism == "irs" && header_grism != "IRshort\"" )
	    next
          else if( grism == "irl" && header_grism != "IRlong\"" )
	    next
	  else if( grism == "opt" && header_grism != "Opt\"" )
	    next
        }

	if( access( fn_out ) ){
	    if( override == no ) {
	       printf("##### Error!! output file %s exists. #####\n", fn_out )
	       next
            } else {
	       printf("# Output file %s exists. Override.\n", fn_out )
	       imdelete( fn_out, ver- )
	    }
	}
	imarith( fn_in, "/", flatfn, fn_out, ver- )
	printf("%s -> %s (%3s %4s %s)\n", fn_in, fn_out, \
  	    header_arm, header_filter, header_obj )
	if( outlist != "" )
	  printf("%s\n", fn_out, >> outlist )
	if( clean == yes ){
          printf("# Deleting origianl file: %s\n", fn_in )
	  imdelete( fn_in, ver- )
        }
     }

     # clean up
     delete( imgfiles, ver-, >& "dev$null" )
     printf("# list file : %s\n", outlist )
     print("# Done. ("//taskname//")" )

end

# end of the script

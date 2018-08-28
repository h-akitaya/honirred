#
#  hnbpfixvirgo.cl
#  HONIR VIRGO image flattening
# 
#
#           Ver 1.00 2014/02/10 H.Akitaya
#           Ver 2.00 2014/03/03 H.Akitaya
#                SFITSIO sffixpix included
#           Ver 2.01 2014/07/17 H.Akitaya
#                iraf variable pass converison
#
#  usage: hnbpfixvirgo (in_images)
#

procedure hnbpfixvirgo( in_images )

string in_images { prompt = "Image Name"}

bool sffixpix = yes # use SFITSIO version fixpix (sffixpix)
bool calbp = yes  # use standard calibration bad pixel mask
bool calds = yes  # use standard calibration dark spot mask
bool dsall = no   # use all dark spot mask for dark spot correction
string bpmask=""
string dsmask=""
bool objsel = no
string object = ""
bool fltrsel = no
string filter = ""
string se_in = "_fl"
string se_out = "_fl"
string mainext = ".fits"
string outlist=""
bool override = no

struct *imglist

begin
     string imgfiles, img, fn_in, fn_out, images, img_root
     string header_obj, header_arm, header_filter
     string taskname, taskversion
     
     images = in_images
    
     taskname="hnbpfixvirgo.cl"
     print("# "//taskname )

     if( sffixpix == no ){
       if( calbp == yes ){
          bpmask = osfn( str( envget( "hn_bpmask_fn" ) ) )
       }
       if( calds == yes ){
          if( dsall == no )
              dsmask = osfn( str( envget( "hn_dsmask_fn" ) ) )
	  else
              dsmask = osfn( str( envget( "hn_dsmaskall_fn" ) ) )
       }
     }else{
       if( calbp == yes ){
          bpmask = osfn( str( envget( "hn_bpmask_sf_fn" ) ) )
       }
       if( calds == yes ){
          if( dsall == no )
              dsmask = osfn( str( envget( "hn_dsmask_sf_fn" ) ) )
	  else
              dsmask = osfn( str( envget( "hn_dsmaskall_sf_fn" ) ) )
       }
     }
     if( bpmask != "" && !access( bpmask ) ){
        printf("# Bad pix mask %s not found. Abort\n", bpmask )
	bye
     }
     if( dsmask != "" && !access( dsmask ) ){
        printf("# Dark spot mask %s not found. Abort\n", dsmask )
	bye
     }
     if (outlist != ""  && access( outlist )){
        printf("# Deleting old output list %s\n", outlist )
	delete( outlist, ver- )
     }

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

	# filtering header keywords (object and filters)
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

        if( access( fn_out ) && override == no ){
            printf("# Output file %s exists. Skip.\n", fn_out )
	    next
        }else if( access( fn_out ) && fn_in != fn_out ){
            printf("# Output file %s exists. Deleting.", fn_out )
            imdelete( fn_out, ver- )
	}
	imcopy( fn_in, fn_out, ver- )
	printf("%s -> %s (%3s %4s %s)\n", fn_in, fn_out, \
  	    header_arm, header_filter, header_obj )
	if( sffixpix == no ){
          if( bpmask != "" ){
	     printf("# Adopting bad pixel mask (IRAF fixpix)%s\n", bpmask)
	     fixpix( fn_out, bpmask, linterp="INDEF", cinterp="INDEF",\
	     verbose-, pixels- )
          }
          if( dsmask != "" ){
	     printf("# Adopting dark spot mask (IRAF fixpix)%s\n", dsmask)
	     fixpix( fn_out, dsmask, linterp="INDEF", cinterp="INDEF",\
	     verbose-, pixels- )
          }
        }else{
	  if( bpmask != "" ){
	     printf("# Adopting bad pixel mask (SFITSIO sffixpix)%s\n", bpmask)
     	     sffixpix( fn_out, osfn( bpmask ), fn_out )
	  }
	  if( dsmask != "" ){
	     printf("# Adopting dark sopt mask (SFITSIO sffixpix)%s\n", bpmask)
     	     sffixpix( fn_out, osfn( dsmask ), fn_out )
	  }
	}
	if( outlist != "" )
	  printf("%s\n", fn_out, >> outlist )
     }

     # clean up
     delete( imgfiles, ver-, >& "dev$null" )

     printf("# list file : %s\n", outlist )
     print("# Done. ("//taskname//")" )

end

# end of the script

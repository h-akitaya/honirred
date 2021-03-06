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
#           Ver 3.00 2014/04/17 H.Akitaya ; flat file auto selection
#           Ver 3.01 2014/04/17 H.Akitaya ; bug fix
#           Ver 3.02 2014/07/29 H.Akitaya ; bug fix
#           Ver 3.10 2014/11/19 H.Akitaya ; various CCD partial read mode
#           Ver 3.20 2014/11/19 H.Akitaya ; filter check for spectroscopy
#           Ver 3.21 2015/01/20 H.Akitaya ; Y band imaging
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
string flatfn = "" { prompt = "Flat file name" }
string grism = "" { prompt = "irs|irl|opt"}
string se_in = "_ds"
string se_out = "_fl"
string mainext = ".fits"
string outlist=""
bool override = no
bool clean = no
bool auto = no

struct *imglist

begin
     string imgfiles, img, fn_in, fn_out, images, img_root
     string flatfn_ccdpartial=""
     string taskname
     string tmp_reg1, tmp_reg2, tmp_reg3, tmp_reg4, tmp_joinlist
     string header_obj, header_arm, header_filter, header_grism
     string header_obsmode, header_mask, header_spv, dummy, buf
     string spmode,n_sp
     int i,j, n_mainext
     int image_y2
     real biasval
     string specmode[3], specnum[3]
     int n_specmode=3
     bool objsel = no
     bool fltrsel = no
     bool grismsel = no
     bool ccdpartial = no

     taskname="hnflatten.cl"

     specmode[1]="Spec12"
     specmode[2]="Spec20"
     specmode[3]="Spec54"
     specnum[1]="012"
     specnum[2]="020"
     specnum[3]="054"

     images = in_images
     if( auto == no && !access( flatfn ) ){
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

     imgfiles = mktemp ( "tmp$tmp_hnflatten_1_" )
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
        if( header_arm == "ira" ){
            hselect( fn_in, "WH_IRAF2", yes ) | scanf( "%s", header_filter )
            hselect( fn_in, "WH_IRAF1", yes ) | scanf( "%s %s", dummy, header_grism )
        }else if ( header_arm == "opt" ){
            hselect( fn_in, "WH_OPTF2", yes ) | scanf( "%s", header_filter )
            hselect( fn_in, "WH_OPTF1", yes ) | scanf( "%s %s", dummy, header_grism )
       }else{
            hselect( fn_in, "WH_IRAF2", yes ) | scanf( "%s", header_filter )
            hselect( fn_in, "WH_OPTF1", yes ) | scanf( "%s %s", dummy, header_grism )  }
       if ( fltrsel == yes && filter != header_filter )
               next
       if( grismsel == yes ){
	  printf("%s %s\n", fn_in, header_grism )
          if( grism == "irs" && header_grism != "IRshort\"" )
	    next
          else if( grism == "irl" && header_grism != "IRlong\"" )
	    next
	  else if( grism == "opt" && header_grism != "Opt\"" )
	    next
        }
        hselect( fn_in, "OBS-MODE", yes ) | scanf("%s", header_obsmode )
	hselect( fn_in, "WH_FOCAL", yes ) | scanf("%s", header_mask )
        imgets( fn_in, "i_naxis2")
        image_y2 = int( imgets.value )

	# set flat file name for auto mode
	if ( auto == no )
	    goto noauto
	flatfn=""
        if( header_obsmode == "Imaging" ){
	    if( header_filter == "B" )
	        flatfn = str( envget("hn_flat_img_b_fn" ) ) 
            else if ( header_filter == "V" )
	        flatfn = str( envget("hn_flat_img_v_fn" ) ) 
            else if ( header_filter == "R" )
	        flatfn = str( envget("hn_flat_img_r_fn" ) ) 
            else if ( header_filter == "I" )
	        flatfn = str( envget("hn_flat_img_i_fn" ) ) 
            else if ( header_filter == "J" )
	        flatfn = str( envget("hn_flat_img_j_fn" ) ) 
            else if ( header_filter == "H" )
	        flatfn = str( envget("hn_flat_img_h_fn" ) ) 
            else if ( header_filter == "Ks" )
	        flatfn = str( envget("hn_flat_img_k_fn" ) ) 
            else if ( header_filter == "Y" && header_arm == "ira" )
	        flatfn = str( envget("hn_flat_img_yir_fn" ) ) 
            else if ( header_filter == "Y" && header_arm == "opt" )
	        flatfn = str( envget("hn_flat_img_yopt_fn" ) ) 
	}else if( header_obsmode == "SpecPol" ){
	    if( header_arm == "opt" ){
	        flatfn = str( envget("hn_flat_sppol_opt_fn" ) ) 
  	        if( header_filter == "none" ){
	          show | match("hn_flat_sppol_opt_none_fn") | scanf( "%s", buf)
		  if( buf != "" )
		    flatfn = str( envget("hn_flat_sppol_opt_none_fn" ) )
		}else if ( header_filter == "O58" ){
	          show | match("hn_flat_sppol_opt_o58_fn") | scanf( "%s", buf)
		  if( buf != "" )
		    flatfn = str( envget("hn_flat_sppol_opt_o58_fn" ) )
		}
            }else if ( header_arm == "ira" ){
	        if ( header_grism == "IRshort\"" )
		    flatfn = str( envget("hn_flat_sppol_irs_fn" ) ) 
	        else if ( header_grism == "IRlong\"" ){
		    flatfn = str( envget("hn_flat_sppol_irl_fn" ) )
		    if( header_filter == "none" ){
		      show | match("hn_flat_sppol_irl_none_fn") | scanf( "%s", buf)
		      if( buf != "" )
		        flatfn = str( envget("hn_flat_sppol_irl_none_fn" ) )
		    }else if ( header_filter == "1.33" ){
		      show | match("hn_flat_sppol_irl_o133_fn") | scanf( "%s", buf)
		      if( buf != "" )
		        flatfn = str( envget("hn_flat_sppol_irl_o133_fn" ) )
		    }
		}
	    }
	}else if( header_obsmode == "ImPol" ){
	    if( header_filter == "B" )
	        flatfn = str( envget("hn_flat_impol_b_fn" ) ) 
            else if ( header_filter == "V" )
	        flatfn = str( envget("hn_flat_impol_v_fn" ) ) 
            else if ( header_filter == "R" )
	        flatfn = str( envget("hn_flat_impol_r_fn" ) ) 
            else if ( header_filter == "I" )
	        flatfn = str( envget("hn_flat_impol_i_fn" ) ) 
            else if ( header_filter == "J" )
	        flatfn = str( envget("hn_flat_impol_j_fn" ) ) 
            else if ( header_filter == "H" )
	        flatfn = str( envget("hn_flat_impol_h_fn" ) ) 
            else if ( header_filter == "Ks" )
	        flatfn = str( envget("hn_flat_impol_k_fn" ) ) 
        }
        for(i=1; i<=n_specmode; i=i+1){
	  spmode=specmode[i]
	  n_sp=specnum[i]
	  if( header_obsmode == spmode ){
	    if ( header_arm == "ira" && header_grism == "IRshort\"" )
	      flatfn = str( envget("hn_flat_spec_"//n_sp//"_irs_fn" ) ) 
	    else if ( header_arm == "ira" && header_grism == "IRlong\"" ){
 	      if( header_filter == "none" ){
	        show | match("hn_flat_spec_"//n_sp//"_irl_none_fn") | scanf( "%s", buf)
	        if( buf != "" )
	          flatfn = str( envget("hn_flat_spec_"//n_sp//"_irl_none_fn" ) )
	      }else if ( header_filter == "1.33" ){
	        show | match("hn_flat_spec_"//n_sp//"_irl_o133_fn") | scanf( "%s", buf)
		if( buf != "" )
		  flatfn = str( envget("hn_flat_spec_"//n_sp//"_irl_o133_fn" ) )
              }
            }else if ( header_arm == "opt" ){
              flatfn = str( envget("hn_flat_spec_"//n_sp//"_opt_fn" ) )
 	      if( header_filter == "none" ){
	        show | match("hn_flat_spec_"//n_sp//"_opt_none_fn") | scanf( "%s", buf)
	        if( buf != "" )
	          flatfn = str( envget("hn_flat_spec_"//n_sp//"_opt_none_fn" ) )
	      }else if ( header_filter == "O58" ){
	        show | match("hn_flat_spec_"//n_sp//"_opt_o58_fn") | scanf( "%s", buf)
		if( buf != "" )
		  flatfn = str( envget("hn_flat_spec_"//n_sp//"_opt_o58_fn" ) )
              }
            }
	  }
        }

	if( !access( flatfn ) ){
	    printf("#ERROR: flat image %s not found. Skip.\n", flatfn )
	    next
	}
	if( header_arm == "opt" ){
	    hselect( fn_in, "SPV", yes ) | scanf("%s", header_spv )
	    if( header_spv != "read" ){
	        ccdpartial=yes
		printf("# CCD image is partially read. " )
		printf("Triming flat image (1-%d) %s\n", image_y2, flatfn )
	        # temporary partial read flat file name
	        flatfn_ccdpartial = \
		     mktemp( "tmp$tmp_hnflatten_partial_" )//".fits"
		imcopy( flatfn//"[*,1:"//image_y2//"]", \
		    flatfn_ccdpartial, verbose- )
      	    }else{
	        ccdpartial = no
	    }
	}
noauto:
	if( access( fn_out ) ){
	    if( override == no ) {
	       printf("##### Error!! output file %s exists. #####\n", fn_out )
	       next
            } else {
	       printf("# Output file %s exists. Override.\n", fn_out )
	       imdelete( fn_out, ver- )
	    }
	}
	if( ccdpartial == no )
	    imarith( fn_in, "/", flatfn, fn_out, ver- )
	else
	    imarith( fn_in, "/", flatfn_ccdpartial, fn_out, ver- )
	hedit( fn_out, "HNFLATFN", flatfn, add+, verify-, show- )
	printf("%s -> %s (%s %3s %4s %s %s); Flat = %s\n", fn_in, fn_out, \
  	    header_obsmode, header_arm, header_filter, header_grism, header_obj, flatfn )

	if( access( flatfn_ccdpartial ) )
	    imdelete( flatfn_ccdpartial, ver- )
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

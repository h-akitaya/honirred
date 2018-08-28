#
#       HONIR REDUCTION 
#
#       initialization of global variables : honirinit.cl
#
#       2009/09/30      H.Akitaya   Ver.0.01
#       2014/02/10      H.Akitaya   Ver.0.02
#       2014/03/01      H.Akitaya   Ver.0.03
#       2014/04/17      H.Akitaya   Ver.0.04
#       2014/05/01      H.Akitaya   Ver.0.05
#       2014/05/02      H.Akitaya   Ver.0.06
#       2014/07/07      H.Akitaya   Ver.0.07
#       2014/07/29      H.Akitaya   Ver.0.08
#       2014/08/01      H.Akitaya   Ver.0.09
#       2014/12/01      H.Akitaya   Ver.0.10 : 201411 cal data
#       2014/12/17      H.Akitaya   Ver.0.11 : 201411 cal data
#       2015/01/20      H.Akitaya   Ver.0.12 : 201412 cal data
#

procedure honirinit( obsrun_in )

string obsrun_in = "201404a" { prompt = "Keycode for observational run to be reduced (201402a|201404a|201405|201406|201408|201411|xxxxxxx)"}

begin
  string obsrun
  obsrun = obsrun_in

  printf("# honirinit.cl\n" )

  printf("# initialize environment varibables for observation run %s\n",\
          obsrun )

  ###### 2014/02 #################################################	   
  if( obsrun == "201402a" || obsrun == "201402" ){
    ### Directory of calibration data dir
      set hncalibdir   = "home$honir_cal/cal201402a/"
    ### bad pixel patterm template
      set hn_bpmask_fn = "hncalibdir$bpm_20140130.pl"
    ### dark spot mask template
      set hn_dsmask_fn = "hncalibdir$dsmask_050_201402a.pl"
    ### all dark spot mask template
      set hn_dsmaskall_fn = "hncalibdir$dsmask_all_201402a.pl"

    ### bad pixel patterm template (for SFITSIO hnpixfix)
      set hn_bpmask_sf_fn = "hncalibdir$bpm_20140130.fits.gz"
    ### dark spot mask template (for SFITSIO hnpixfix)
      set hn_dsmask_sf_fn = "hncalibdir$dsmask_050_201402a.fits.gz"
    ### all dark spot mask template (for SFITSIO hnpixfix)
      set hn_dsmaskall_sf_fn = "hncalibdir$dsmask_all_201402a.fits.gz"
    #--- Directory Setting *** should be attatch '/' at the end ***
  ###### 2014/04 #################################################	   
  }else if( obsrun == "201404a" || obsrun == "201442" ){
    ### Directory of calibration data dir
      set hncalibdir   = "home$honir_cal/cal201404a/"
    ### bad pixel patterm template
      set hn_bpmask_fn = "hncalibdir$bpm_20140130.pl"
    ### dark spot mask template
      set hn_dsmask_fn = "hncalibdir$dsmask_050_201402a.pl"
    ### all dark spot mask template
      set hn_dsmaskall_fn = "hncalibdir$dsmask_all_201402a.pl"

    ### bad pixel patterm template (for SFITSIO hnpixfix)
      set hn_bpmask_sf_fn = "hncalibdir$bpm_20140130.fits.gz"
    ### dark spot mask template (for SFITSIO hnpixfix)
      set hn_dsmask_sf_fn = "hncalibdir$dsmask_050_201402a.fits.gz"
    ### all dark spot mask template (for SFITSIO hnpixfix)
      set hn_dsmaskall_sf_fn = "hncalibdir$dsmask_all_201402a.fits.gz"
    ### flat images ####
      set hn_flat_img_j_fn = "hncalibdir$flat_img_j_20140317.fits"
      set hn_flat_img_h_fn = "hncalibdir$flat_img_h_20140317.fits"
      set hn_flat_img_k_fn = "hncalibdir$flat_img_k_20140317.fits"
      set hn_flat_img_b_fn = "hncalibdir$flat_img_b_20140305.fits"
      set hn_flat_img_v_fn = "hncalibdir$flat_img_v_20140305.fits"
      set hn_flat_img_r_fn = "hncalibdir$flat_img_r_20140305.fits"
      set hn_flat_img_i_fn = "hncalibdir$flat_img_i_20140305.fits"
      set hn_flat_sppol_irl_fn = "hncalibdir$flat_sppol_irl_allhwp.fits"
      set hn_flat_sppol_irs_fn = "hncalibdir$flat_sppol_irs_allhwp.fits"
      set hn_flat_sppol_opt_fn = "hncalibdir$flat_sppol_opt_allhwp.fits"
      set hn_flat_impol_j_fn = "hncalibdir$flat_impol_j_20140302.fits"
      set hn_flat_impol_h_fn = "hncalibdir$flat_impol_h_20140302.fits"
      set hn_flat_impol_k_fn = "hncalibdir$flat_impol_k_20140302.fits"
      set hn_flat_impol_b_fn = "hncalibdir$flat_impol_b_20140302.fits"
      set hn_flat_impol_v_fn = "hncalibdir$flat_impol_v_20140302.fits"
      set hn_flat_impol_r_fn = "hncalibdir$flat_impol_r_20140302.fits"
      set hn_flat_impol_i_fn = "hncalibdir$flat_impol_i_20140302.fits"
      set hn_flat_spec_012_irl_fn = "hncalibdir$flat_spec012_irl_20140127.fits"
      set hn_flat_spec_012_irs_fn = "hncalibdir$flat_spec012_irs_20140127.fits"
      set hn_flat_spec_012_opt_fn = "hncalibdir$"
      set hn_flat_spec_020_irl_fn = "hncalibdir$"
      set hn_flat_spec_020_irs_fn = "hncalibdir$"
      set hn_flat_spec_020_opt_fn = "hncalibdir$"
      set hn_flat_spec_054_irl_fn = "hncalibdir$"
      set hn_flat_spec_054_irs_fn = "hncalibdir$"
      set hn_flat_spec_054_opt_fn = "hncalibdir$"
  ###### 2014/05 #################################################	   
  }else if( obsrun == "201405" ){
    ### Directory of calibration data dir
      set hncalibdir   = "home$honir_cal/cal201405/"
    ### bad pixel patterm template
      set hn_bpmask_fn = "hncalibdir$bpm_20140130.pl"
    ### dark spot mask template
      set hn_dsmask_fn = "hncalibdir$dsmask_050_201402a.pl"
    ### all dark spot mask template
      set hn_dsmaskall_fn = "hncalibdir$dsmask_all_201402a.pl"

    ### bad pixel patterm template (for SFITSIO hnpixfix)
      set hn_bpmask_sf_fn = "hncalibdir$bpm_20140130.fits.gz"
    ### dark spot mask template (for SFITSIO hnpixfix)
      set hn_dsmask_sf_fn = "hncalibdir$dsmask_050_201402a.fits.gz"
    ### all dark spot mask template (for SFITSIO hnpixfix)
      set hn_dsmaskall_sf_fn = "hncalibdir$dsmask_all_201402a.fits.gz"
    ### flat images ####
      set hn_flat_impol_h_fn = "hncalibdir$flat_impol_H_20140526.fits"
      set hn_flat_impol_k_fn = "hncalibdir$flat_impol_K_20140526.fits"
      set hn_flat_impol_j_fn = "hncalibdir$flat_impol_J_20140526.fits"
      set hn_flat_impol_r_fn = "hncalibdir$flat_impol_r_20140516.fits"
  ###### 2014/06 #################################################	   
  }else if( obsrun == "201406" ){
    ### Directory of calibration data dir
      set hncalibdir   = "home$honir_cal/cal201406/"
    ### bad pixel patterm template
      set hn_bpmask_fn = "hncalibdir$bpm_20140130.pl"
    ### dark spot mask template
      set hn_dsmask_fn = "hncalibdir$dsmask_050_201402a.pl"
    ### all dark spot mask template
      set hn_dsmaskall_fn = "hncalibdir$dsmask_all_201402a.pl"

    ### bad pixel patterm template (for SFITSIO hnpixfix)
      set hn_bpmask_sf_fn = "hncalibdir$bpm_20140130.fits.gz"
    ### dark spot mask template (for SFITSIO hnpixfix)
      set hn_dsmask_sf_fn = "hncalibdir$dsmask_050_201402a.fits.gz"
    ### all dark spot mask template (for SFITSIO hnpixfix)
      set hn_dsmaskall_sf_fn = "hncalibdir$dsmask_all_201402a.fits.gz"
    ### flat images ####
      set hn_flat_img_b_fn = "hncalibdir$flat_img_b_20140623.fits"
      set hn_flat_img_v_fn = "hncalibdir$flat_img_v_20140623.fits"
      set hn_flat_img_r_fn = "hncalibdir$flat_img_r_20140623.fits"
      set hn_flat_img_i_fn = "hncalibdir$flat_img_i_20140623.fits"
      set hn_flat_img_j_fn = "hncalibdir$flat_img_j_20140625.fits"
      set hn_flat_img_h_fn = "hncalibdir$flat_img_h_20140714.fits"
      set hn_flat_img_k_fn = "hncalibdir$flat_img_k_20140625.fits"
  ###### 2014/08 #################################################	   
  }else if( obsrun == "201408" ){
    ### Directory of calibration data dir
      set hncalibdir   = "home$honir_cal/cal201406/"
    ### bad pixel patterm template
      set hn_bpmask_fn = "hncalibdir$bpm_20140130.pl"
    ### dark spot mask template
      set hn_dsmask_fn = "hncalibdir$dsmask_050_201402a.pl"
    ### all dark spot mask template
      set hn_dsmaskall_fn = "hncalibdir$dsmask_all_201402a.pl"

    ### bad pixel patterm template (for SFITSIO hnpixfix)
      set hn_bpmask_sf_fn = "hncalibdir$bpm_20140130.fits.gz"
    ### dark spot mask template (for SFITSIO hnpixfix)
      set hn_dsmask_sf_fn = "hncalibdir$dsmask_050_201402a.fits.gz"
    ### all dark spot mask template (for SFITSIO hnpixfix)
      set hn_dsmaskall_sf_fn = "hncalibdir$dsmask_all_201402a.fits.gz"
    ### flat images ####
      set hn_flat_img_b_fn = "hncalibdir$flat_img_b_20140623.fits"
      set hn_flat_img_v_fn = "hncalibdir$flat_img_v_20140623.fits"
      set hn_flat_img_r_fn = "hncalibdir$flat_img_r_20140623.fits"
      set hn_flat_img_i_fn = "hncalibdir$flat_img_i_20140623.fits"
      set hn_flat_img_j_fn = "hncalibdir$flat_img_j_20140731.fits"
      set hn_flat_img_h_fn = "hncalibdir$flat_img_h_20140731.fits"
      set hn_flat_img_k_fn = "hncalibdir$flat_img_k_20140731.fits"
  ###### 2014/11a #################################################	   
  }else if( obsrun == "201411a" || obsrun == "201411" ){
    ### Directory of calibration data dir
      set hncalibdir   = "home$honir_cal/cal201411a/"
    ### bad pixel patterm template
      set hn_bpmask_fn = "hncalibdir$bpm_20140130.pl"
    ### dark spot mask template
      set hn_dsmask_fn = "hncalibdir$dsmask_050_201402a.pl"
    ### all dark spot mask template
      set hn_dsmaskall_fn = "hncalibdir$dsmask_all_201402a.pl"

    ### bad pixel patterm template (for SFITSIO hnpixfix)
      set hn_bpmask_sf_fn = "hncalibdir$bpm_20140130.fits.gz"
    ### dark spot mask template (for SFITSIO hnpixfix)
      set hn_dsmask_sf_fn = "hncalibdir$dsmask_050_201402a.fits.gz"
    ### all dark spot mask template (for SFITSIO hnpixfix)
      set hn_dsmaskall_sf_fn = "hncalibdir$dsmask_all_201402a.fits.gz"
    ### flat images ####
      set hn_flat_img_b_fn = "hncalibdir$flat_img_b_20141116.fits"
      set hn_flat_img_v_fn = "hncalibdir$flat_img_v_20141116.fits"
      set hn_flat_img_r_fn = "hncalibdir$flat_img_r_20141116.fits"
      set hn_flat_img_i_fn = "hncalibdir$flat_img_i_20141116.fits"
      set hn_flat_img_j_fn = "hncalibdir$flat_img_j_20141115.fits"
      set hn_flat_img_h_fn = "hncalibdir$flat_img_h_20141115.fits"
      set hn_flat_img_k_fn = "hncalibdir$flat_img_k_20141115.fits"
      set hn_flat_img_yir_fn = "hncalibdir$flat_img_yir_20141115.fits"
      set hn_flat_img_yopt_fn = "hncalibdir$flat_img_yopt_20141115.fits"

      set hn_flat_impol_j_fn = "hncalibdir$flat_impol_j_20141123.fits"
      set hn_flat_impol_h_fn = "hncalibdir$flat_impol_h_20141125.fits"
      set hn_flat_impol_k_fn = "hncalibdir$flat_impol_k_20141125.fits"
      set hn_flat_impol_b_fn = "hncalibdir$flat_impol_b_20141121.fits"
      set hn_flat_impol_v_fn = "hncalibdir$flat_impol_v_20141121.fits"
      set hn_flat_impol_r_fn = "hncalibdir$flat_impol_r_20141211.fits"
      set hn_flat_impol_i_fn = "hncalibdir$flat_impol_i_20141121.fits"

      set hn_flat_sppol_irl_fn = "hncalibdir$flat_sppol_irl_none_20141215.fits"
      set hn_flat_sppol_irl_none_fn = "hncalibdir$flat_sppol_irl_none_20141215.fits"
      set hn_flat_sppol_irl_o133_fn = "hncalibdir$flat_sppol_irl_o133_20141215.fits"
      set hn_flat_sppol_irs_fn = "hncalibdir$flat_sppol_irs_none_20141215.fits"
      set hn_flat_sppol_opt_fn = "hncalibdir$flat_sppol_opt_none_20141215.fits"
      set hn_flat_sppol_opt_none_fn = "hncalibdir$flat_sppol_opt_none_20141215.fits"
      set hn_flat_sppol_opt_o58_fn = "hncalibdir$flat_sppol_opt_o58_20141215.fits"

      set hn_flat_spec_012_irl_fn = "hncalibdir$"
      set hn_flat_spec_012_irl_none_fn = "hncalibdir$"
      set hn_flat_spec_012_irl_o133_fn = "hncalibdir$"
      set hn_flat_spec_012_irs_fn = "hncalibdir$"
      set hn_flat_spec_012_opt_fn = "hncalibdir$"
      set hn_flat_spec_012_opt_none_fn = "hncalibdir$"
      set hn_flat_spec_012_opt_o58_fn = "hncalibdir$"

      set hn_flat_spec_020_irl_fn = "hncalibdir$"
      set hn_flat_spec_020_irl_none_fn = "hncalibdir$"
      set hn_flat_spec_020_irl_o133_fn = "hncalibdir$"
      set hn_flat_spec_020_irs_fn = "hncalibdir$"
      set hn_flat_spec_020_opt_fn = "hncalibdir$"
      set hn_flat_spec_020_opt_none_fn = "hncalibdir$"
      set hn_flat_spec_020_opt_o58_fn = "hncalibdir$"

      set hn_flat_spec_054_irl_fn = "hncalibdir$"
      set hn_flat_spec_054_irl_none_fn = "hncalibdir$"
      set hn_flat_spec_054_irl_o133_fn = "hncalibdir$"
      set hn_flat_spec_054_irs_fn = "hncalibdir$"
      set hn_flat_spec_054_opt_fn = "hncalibdir$"
      set hn_flat_spec_054_opt_none_fn = "hncalibdir$"
      set hn_flat_spec_054_opt_o58_fn = "hncalibdir$"
  ###### 2014/12a #################################################	   
  }else if( obsrun == "201412a" || obsrun == "201412" ){
    ### Directory of calibration data dir
      set hncalibdir   = "home$honir_cal/cal201412a/"
    ### bad pixel patterm template
      set hn_bpmask_fn = "hncalibdir$bpm_20140130.pl"
    ### dark spot mask template
      set hn_dsmask_fn = "hncalibdir$dsmask_050_201402a.pl"
    ### all dark spot mask template
      set hn_dsmaskall_fn = "hncalibdir$dsmask_all_201402a.pl"

    ### bad pixel patterm template (for SFITSIO hnpixfix)
      set hn_bpmask_sf_fn = "hncalibdir$bpm_20140130.fits.gz"
    ### dark spot mask template (for SFITSIO hnpixfix)
      set hn_dsmask_sf_fn = "hncalibdir$dsmask_050_201402a.fits.gz"
    ### all dark spot mask template (for SFITSIO hnpixfix)
      set hn_dsmaskall_sf_fn = "hncalibdir$dsmask_all_201402a.fits.gz"
    ### flat images ####
      set hn_flat_img_b_fn = "hncalibdir$flat_img_b_20141228.fits"
      set hn_flat_img_v_fn = "hncalibdir$flat_img_v_20141228.fits"
      set hn_flat_img_r_fn = "hncalibdir$flat_img_r_20141228.fits"
      set hn_flat_img_i_fn = "hncalibdir$flat_img_i_20141228.fits"
      set hn_flat_img_j_fn = "hncalibdir$flat_img_j_20141228.fits"
      set hn_flat_img_h_fn = "hncalibdir$flat_img_h_20141228.fits"
      set hn_flat_img_k_fn = "hncalibdir$flat_img_k_20141228.fits"

      set hn_flat_impol_j_fn = "hncalibdir$flat_impol_j_20141228.fits"
      set hn_flat_impol_h_fn = "hncalibdir$flat_impol_h_20141228.fits"
      set hn_flat_impol_k_fn = "hncalibdir$flat_impol_k_20141228.fits"
      set hn_flat_impol_b_fn = "hncalibdir$flat_impol_b_20150118.fits"
      set hn_flat_impol_v_fn = "hncalibdir$flat_impol_v_20141228.fits"
      set hn_flat_impol_r_fn = "hncalibdir$flat_impol_r_20141228.fits"
      set hn_flat_impol_i_fn = "hncalibdir$flat_impol_i_20141228.fits"

      set hn_flat_sppol_irl_fn = "hncalibdir$flat_sppol_irl_none_20150105.fits"
      set hn_flat_sppol_irl_none_fn = "hncalibdir$flat_sppol_irl_none_20150105.fits"
      set hn_flat_sppol_irl_o133_fn = "hncalibdir$flat_sppol_irl_o133_20150105.fits"
      set hn_flat_sppol_irs_fn = "hncalibdir$flat_sppol_irs_none_20150105.fits"
      set hn_flat_sppol_opt_fn = "hncalibdir$flat_sppol_opt_none_20150105.fits"
      set hn_flat_sppol_opt_none_fn = "hncalibdir$flat_sppol_opt_none_20150105.fits"
      set hn_flat_sppol_opt_o58_fn = "hncalibdir$flat_sppol_opt_o58_20150105.fits"

      set hn_flat_spec_012_irl_fn = "hncalibdir$"
      set hn_flat_spec_012_irl_none_fn = "hncalibdir$"
      set hn_flat_spec_012_irl_o133_fn = "hncalibdir$"
      set hn_flat_spec_012_irs_fn = "hncalibdir$"
      set hn_flat_spec_012_opt_fn = "hncalibdir$"
      set hn_flat_spec_012_opt_none_fn = "hncalibdir$"
      set hn_flat_spec_012_opt_o58_fn = "hncalibdir$"

      set hn_flat_spec_020_irl_fn = "hncalibdir$"
      set hn_flat_spec_020_irl_none_fn = "hncalibdir$"
      set hn_flat_spec_020_irl_o133_fn = "hncalibdir$"
      set hn_flat_spec_020_irs_fn = "hncalibdir$"
      set hn_flat_spec_020_opt_fn = "hncalibdir$"
      set hn_flat_spec_020_opt_none_fn = "hncalibdir$"
      set hn_flat_spec_020_opt_o58_fn = "hncalibdir$"

      set hn_flat_spec_054_irl_fn = "hncalibdir$"
      set hn_flat_spec_054_irl_none_fn = "hncalibdir$"
      set hn_flat_spec_054_irl_o133_fn = "hncalibdir$"
      set hn_flat_spec_054_irs_fn = "hncalibdir$"
      set hn_flat_spec_054_opt_fn = "hncalibdir$"
      set hn_flat_spec_054_opt_none_fn = "hncalibdir$"
      set hn_flat_spec_054_opt_o58_fn = "hncalibdir$"

  ###### user defined #################################################	   
  # }else if( obsrun == "xxxxx" ){
  #  # declare variables here.
  #
  }else{
    error(1, "# No calibration data was found !!" )
  }

  set _initproc = "DONE"
  keep

  # show results
   printf("%-20s %s\n", "# Bad pixel mask (for IRAF fixpix):", \
                  osfn(str( envget("hn_bpmask_fn" ) ) ) )
   printf("%-20s %s\n", "# Dark spot mask (for IRAF fixpix):", \
                  osfn(str( envget("hn_dsmask_fn" ) ) ) )
   printf("%-20s %s\n", "# All dark spot mask (for IRAF fixpix):", \
                  osfn(str( envget("hn_dsmaskall_fn" ) ) ) )
   printf("%-20s %s\n", "# Bad pixel mask (for SFITSIO sffixpix):", \
                  osfn(str( envget("hn_bpmask_sf_fn" ) ) ) )
   printf("%-20s %s\n", "# Dark spot mask (for SFITSIO sffixpix) :", \
                  osfn(str( envget("hn_dsmask_sf_fn" ) ) ) )
   printf("%-20s %s\n", "# All dark spot mask (for SFITSIO fixpix):", \
                  osfn(str( envget("hn_dsmaskall_sf_fn" ) ) ) )
   printf("%-20s\n", "# Setting flat images." )

#  printf("%-20s %s\n", "# Bias Pattern Template :", \
#                  osfn(str( envget("bias_template_fn" ) ) ) )

  printf("# Done.\n" )

end

#end

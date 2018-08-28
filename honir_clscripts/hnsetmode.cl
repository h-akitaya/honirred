#
#       HONIR REDUCTION 
#           reduction mode setting
#
#       initialization of global variables : hnsetmode.cl
#
#       2014/04/10      H.Akitaya   Ver.0.1
#

procedure hnsetmode( mode )

string mode = "" { prompt = "mode (sppol"}

begin
  string obsrun
  obsrun = obsrun_in

  printf("# honirinit.cl Ver 0.1\n" )

  printf("# initialize environment varibables for observation run %s\n",\
          obsrun )

  ###### 2011.08 #################################################	   
  if( obsrun == "201402a" || obsrun == "201402" ){
  
    #--- Directory Setting *** should be attatch '/' at the end ***
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

#  printf("%-20s %s\n", "# Bias Pattern Template :", \
#                  osfn(str( envget("bias_template_fn" ) ) ) )

  printf("# Done.\n" )

end

#end

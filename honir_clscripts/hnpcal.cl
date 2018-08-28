#
# hnpcal.cl ( from lppcal.cl)
#   HONIR q, u, p, theta quick look script
#         ver 1.0 2014/03/18 H.Akitaya
#
#

procedure hnpcal( input_fn )

file input_fn   { prompt = "Image List File Name" }

struct *imglist

# main

begin

  string images, imgfiles, img, polmode
  int apnum
  real hwppa
  int file_n_q
  int file_n_u
  real file_nsqrt_q
  real file_nsqrt_u
  string dummy

  # to use "sed"
  task sed = "$foreign"

  images = input_fn

  # delete temporary files (before main routine)

  delete( "_pcalql_*", verify- )

  # main routine
  imgfiles = mktemp ( "tmp$_hnpcal_tmp" )
  sections( images, option="fullname", > imgfiles )
  imglist = imgfiles
  while( fscan( imglist, img ) != EOF ){
#    imgets( img, "APNUM1" )
#    printf( "%s\n", imgets.value ) | scanf("%d %d", x, apnum )
    imgets( img, "POLMODE" )
    polmode = imgets.value
#    printf( "%d", apnum )
    imgets( img, "HWPANGLE" )
    hwppa = real( imgets.value )
    printf("%s %s %5.1f\n", img, polmode, hwppa )
    if( hwppa == 0.0 && polmode == "o" )
      print( img, >> "_pcalql_o_000.lst" )
    else if( hwppa == 0.0 && polmode == "e" )
      print( img, >> "_pcalql_e_000.lst" )
    else if( hwppa == 22.5 && polmode == "o" )
      print( img, >> "_pcalql_o_225.lst" )
    else if( hwppa == 22.5 && polmode == "e" )
      print( img, >> "_pcalql_e_225.lst" )
    else if( hwppa == 45.0 && polmode == "o" )
      print( img, >> "_pcalql_o_450.lst" )
    else if( hwppa == 45.0 && polmode == "e" )
      print( img, >> "_pcalql_e_450.lst" )
    else if( hwppa == 67.5 && polmode == "o" )
      print( img, >> "_pcalql_o_675.lst" )
    else if( hwppa == 67.5 && polmode == "e" )
      print( img, >> "_pcalql_e_675.lst" )
      
    if( polmode == "o" )
      print( img, >> "_pcalql_o_all.lst" )
    else if( polmode == "e" ) 
      print( img, >> "_pcalql_e_all.lst" )
  }

  # calc I
  sed ('s/_o/_i/', "_pcalql_o_all.lst",  > "_pcalql_i_all.lst" )
  sarith( "@_pcalql_o_all.lst", "+", "@_pcalql_e_all.lst", \
    "@_pcalql_i_all.lst", format="multispec", errval=0., verbose-, \
    reverse- )

  # k+Ie/Io
  sed ('s/_o/_k/',  "_pcalql_o_all.lst",  > "_pcalql_k_all.lst")
  sarith( "@_pcalql_e_all.lst", "/", "@_pcalql_o_all.lst", \
    "@_pcalql_k_all.lst", format="multispec", errval=0., verbose-, \
    reverse- )

  # aq^2, au^2
  sed ('s/_o/_aq2/', "_pcalql_o_000.lst", > "_pcalql_aq2.lst")
  sed ('s/_o/_au2/', "_pcalql_o_225.lst", > "_pcalql_au2.lst")
  sed ('s/_o/_k/', "_pcalql_o_000.lst", > "_pcalql_k_000.lst")
  sed ('s/_o/_k/', "_pcalql_o_450.lst", > "_pcalql_k_450.lst")
  sed ('s/_o/_k/', "_pcalql_o_225.lst", > "_pcalql_k_225.lst")
  sed ('s/_o/_k/', "_pcalql_o_675.lst", > "_pcalql_k_675.lst")
  #
  sarith ( "@_pcalql_k_000.lst", "/", "@_pcalql_k_450.lst", \
    "@_pcalql_aq2.lst" , format="multispec", errval=0.,\
     verbose-, reverse- )

  sarith ( "@_pcalql_k_225.lst", "/", "@_pcalql_k_675.lst", \
    "@_pcalql_au2.lst" , format="multispec", errval=0.,\
     verbose-, reverse- )
  #
  # aq, au
  sed ('s/_aq2/_aq1/', "_pcalql_aq2.lst", > "_pcalql_aq1.lst")
  sed ('s/_au2/_au1/', "_pcalql_au2.lst", > "_pcalql_au1.lst")
  #
  sarith ( "@_pcalql_aq2.lst", "sqrt", "", "@_pcalql_aq1.lst", \
   format="multispec", errval=0., verbose-, reverse- )
  sarith ( "@_pcalql_au2.lst", "sqrt", "", "@_pcalql_au1.lst", \
   format="multispec", errval=0., verbose-, reverse- )

  # 1-aq, 1-au, 1+aq, 1+au
  sed ('s/_aq1/_1mnsaq/', "_pcalql_aq1.lst", > "_pcalql_1mnsaq.lst")
  sed ('s/_au1/_1mnsau/', "_pcalql_au1.lst", > "_pcalql_1mnsau.lst")
  sed ('s/_aq1/_1plsaq/', "_pcalql_aq1.lst", > "_pcalql_1plsaq.lst")
  sed ('s/_au1/_1plsau/', "_pcalql_au1.lst", > "_pcalql_1plsau.lst")

  sarith ( "@_pcalql_aq1.lst", "-" , 1.0 , "@_pcalql_1mnsaq.lst", \
    format="multispec", errval=0., verbose-, reverse+ )
  sarith ( "@_pcalql_au1.lst", "-" , 1.0 , "@_pcalql_1mnsau.lst", \
    format="multispec", errval=0., verbose-, reverse+ )
  sarith ( "@_pcalql_aq1.lst", "+" , 1.0 , "@_pcalql_1plsaq.lst", \
    format="multispec", errval=0., verbose-, reverse+ )
  sarith ( "@_pcalql_au1.lst", "+" , 1.0 , "@_pcalql_1plsau.lst", \
    format="multispec", errval=0., verbose-, reverse+ )

    #q,u

    sed ('s/_aq1/_q/', "_pcalql_aq1.lst", > "_pcalql_q.lst")
    sed ('s/_au1/_u/', "_pcalql_au1.lst", > "_pcalql_u.lst")

    sarith ( "@_pcalql_1mnsaq.lst", "/", "@_pcalql_1plsaq.lst", \
    "@_pcalql_q.lst", format="multispec", errval=0., verbose-, reverse- )
    sarith ( "@_pcalql_1mnsau.lst", "/", "@_pcalql_1plsau.lst", \
    "@_pcalql_u.lst", format="multispec", errval=0., verbose-, reverse- )

    # i, q, u average

    count ( "_pcalql_q.lst" ) | scan ( file_n_q, dummy, dummy, dummy )
    count ( "_pcalql_u.lst" ) | scan ( file_n_u, dummy, dummy, dummy )

    file_nsqrt_q = sqrt( file_n_q - 1.0 )
    file_nsqrt_u = sqrt( file_n_u - 1.0 )

    imcombine ( "@_pcalql_q.lst", "pcalql_q_ave.fits", combine="average", \
    reject="sigclip", lsigma=2.8,  hsigma=2.8, sigma="pcalql_q_sig.fits",\
    logfile="" )
    imcombine ( "@_pcalql_u.lst", "pcalql_u_ave.fits", combine="average", \
    reject="sigclip", lsigma=2.8,  hsigma=2.8, sigma="pcalql_u_sig.fits",\
    logfile="" )

    sarith ( "pcalql_q_sig.fits", "/", file_nsqrt_q, "pcalql_q_err.fits" )
    sarith ( "pcalql_u_sig.fits", "/", file_nsqrt_u, "pcalql_u_err.fits" )

    scombine ( "@_pcalql_i_all.lst", "pcalql_i_ave.fits", logfile = "" )

    # q2, u2
    sarith( "pcalql_q_ave.fits", "*", "pcalql_q_ave.fits", "pcalql_q2_ave.fits", \
    format="multispec", errval=0., verbose-, reverse-)
    sarith( "pcalql_u_ave.fits", "*", "pcalql_u_ave.fits", "pcalql_u2_ave.fits", \
    format="multispec", errval=0., verbose-, reverse-)

    # p2
    sarith( "pcalql_q2_ave.fits", "+", "pcalql_u2_ave.fits", "pcalql_p2_ave.fits", \
    format="multispec", errval=0., verbose-, reverse- )

    # p
    sarith ( "pcalql_p2_ave.fits", "sqrt", "", "pcalql_p_ave.fits", \
    format="multispec", errval=0., verbose-, reverse- )

    # p-error
    sarith ( "pcalql_u2_ave.fits", "/", "pcalql_q2_ave.fits", \
    "pcalql_u2q2_ave.fits",\
    format="multispec", errval=0., verbose-, reverse- )
    sarith ( "pcalql_q2_ave.fits", "/", "pcalql_u2_ave.fits", \
    "pcalql_q2u2_ave.fits",\
    format="multispec", errval=0., verbose-, reverse- )
    sarith ( "pcalql_u2q2_ave.fits", "+", 1.0 , \
    "pcalql_u2q2plus1_ave.fits",\
    format="multispec", errval=0., verbose-, reverse- )
    sarith ( "pcalql_q2u2_ave.fits", "+", 1.0 , \
    "pcalql_q2u2plus1_ave.fits",\
    format="multispec", errval=0., verbose-, reverse- )

    sarith ( "pcalql_q_err.fits", "*", "pcalql_q_err.fits",\
    "pcalql_q_err2.fits",\
    format="multispec", errval=0., verbose-, reverse- )
    sarith ( "pcalql_u_err.fits", "*", "pcalql_u_err.fits",\
    "pcalql_u_err2.fits",\
    format="multispec", errval=0., verbose-, reverse- )

    sarith ( "pcalql_q_err2.fits", "/", "pcalql_u2q2plus1_ave.fits" , \
    "pcalql_deltap_q_2.fits",\
    format="multispec", errval=0., verbose-, reverse- )
    sarith ( "pcalql_u_err2.fits", "/", "pcalql_q2u2plus1_ave.fits" , \
    "pcalql_deltap_u_2.fits",\
    format="multispec", errval=0., verbose-, reverse- )

    sarith ( "pcalql_deltap_q_2.fits", "+", "pcalql_deltap_u_2.fits", \
    "pcalql_p_err2.fits",\
    format="multispec", errval=0., verbose-, reverse- )

    sarith ( "pcalql_p_err2.fits", "sqrt", "", "pcalql_p_err.fits",\
    format="multispec", errval=0., verbose-, reverse- )

    # theta-error

    sarith ( "pcalql_q_err2.fits", "/", "pcalql_q2u2plus1_ave.fits" , \
    "pcalql_deltapdeg_q_2.fits",\
    format="multispec", errval=0., verbose-, reverse- )
    sarith ( "pcalql_u_err2.fits", "/", "pcalql_u2q2plus1_ave.fits" , \
    "pcalql_deltapdeg_u_2.fits",\
    format="multispec", errval=0., verbose-, reverse- )

    sarith ( "pcalql_deltapdeg_q_2.fits", "+", "pcalql_deltapdeg_u_2.fits", \
    "pcalql_pdeg_err2.fits",\
    format="multispec", errval=0., verbose-, reverse- )
    sarith ( "pcalql_pdeg_err2.fits", "sqrt", "", "pcalql_pdegrad_err_tmp.fits",\
    format="multispec", errval=0., verbose-, reverse- )
    sarith ( "pcalql_pdegrad_err_tmp.fits", "/", 2.0, \
    "pcalql_pdegrad_err_tmp.fits" ,\
    format="multispec", errval=0., verbose-, reverse- )
    sarith ( "pcalql_pdegrad_err_tmp.fits", "/", "pcalql_p_ave.fits", \
    "pcalql_pdegrad_err.fits" ,\
    format="multispec", errval=0., verbose-, reverse- )
    imreplace( "pcalql_pdegrad_err.fits", 3.14159265358979, \
    lower=3.14159265358979 )
    sarith ( "pcalql_pdegrad_err.fits" , "*", 57.2957795130823, \
    "pcalql_pdegdeg_err.fits",\
    format="multispec", errval=0., verbose-, reverse- )
    
    imdelete( "pcalql_q2u2_ave.fits" ,ver- )
    imdelete( "pcalql_u2q2_ave.fits" ,ver- )
    imdelete( "pcalql_q2u2plus1_ave.fits" ,ver- )
    imdelete( "pcalql_u2q2plus1_ave.fits" ,ver- )
    imdelete( "pcalql_q_err2.fits" ,ver- )
    imdelete( "pcalql_u_err2.fits" ,ver- )
    imdelete( "pcalql_deltap_q_2.fits" ,ver- )
    imdelete( "pcalql_deltap_u_2.fits" ,ver- )
    imdelete( "pcalql_p_err2.fits" ,ver- )
    imdelete( "pcalql_deltapdeg_q_2.fits" ,ver- )
    imdelete( "pcalql_deltapdeg_u_2.fits" ,ver- )
    imdelete( "pcalql_pdeg_err2.fits" ,ver- )
    imdelete("pcalql_pdegrad_err_tmp.fits",ver- )

    imdelete( "pcalql_q2_ave.fits" ,ver- )
    imdelete( "pcalql_u2_ave.fits" ,ver- )
    imdelete( "pcalql_p2_ave.fits" ,ver- )


    # u/q
    sarith ("pcalql_u_ave.fits" ,"/", "pcalql_q_ave.fits", "pcalql_uovq_ave.fits", \
    format="multispec", errval=0., verbose-, reverse- )

    # atan(u/q)
    imfunction ("pcalql_uovq_ave.fits", "pcalql_atan_ave.fits", "atan" )

    # poldeg shift template

    scopy ( "pcalql_q_ave.fits", "pcalqlpdeg_shift_180.fits" )
    imreplace ("pcalqlpdeg_shift_180.fits", 1.0, lower=0.0 )
    imreplace ("pcalqlpdeg_shift_180.fits", -1.0, upper=0.0 )
    imreplace ("pcalqlpdeg_shift_180.fits", 0.0, upper=1.0, lower=1.0 )
    imreplace ("pcalqlpdeg_shift_180.fits", 1.0, upper=-1.0, lower=-1.0 )

    scopy ("pcalql_q_ave.fits", "pcalqlpdeg_shift_360a.fits" )
    imreplace ("pcalqlpdeg_shift_360a.fits", 1.0, lower=0.0)
    imreplace ("pcalqlpdeg_shift_360a.fits", 0.0, upper=0.0)

    scopy ("pcalql_u_ave.fits", "pcalqlpdeg_shift_360b.fits" )
    imreplace ("pcalqlpdeg_shift_360b.fits", 1.0, lower=0.0 )
    imreplace ("pcalqlpdeg_shift_360b.fits", -1.0, upper=0.0 )
    imreplace ("pcalqlpdeg_shift_360b.fits", 0.0, upper=1.0, lower=1.0 )
    imreplace ("pcalqlpdeg_shift_360b.fits", 1.0, upper=-1.0, lower=-1.0 )
    sarith ("pcalqlpdeg_shift_360a.fits", "*", "pcalqlpdeg_shift_360b.fits",\
    "pcalqlpdeg_shift_360.fits" )
    sarith ("pcalqlpdeg_shift_360.fits", "*", 2.0, "pcalqlpdeg_shift_360.fits",\
    clobber+ )
    sarith("pcalqlpdeg_shift_180.fits", "+", "pcalqlpdeg_shift_360.fits",\
    "pcalqlpdeg_shift.fits" )
    sarith("pcalqlpdeg_shift.fits", "*", 3.14159265358979, "pcalqlpdeg_shift.fits",\
    clobber+)

    # +180 or +360 degrees
    sarith ("pcalql_atan_ave.fits", "+",  "pcalqlpdeg_shift.fits",\
    "pcalql_atan_ave.fits", clobber+ )
    # 1/2 arctan(u/q) 
    sarith ("pcalql_atan_ave.fits", "/", 2.0, "pcalql_thetarad_ave.fits" )
    # to degree unit
    sarith ("pcalql_thetarad_ave.fits", "*", 57.2957795130823, "pcalql_thetadeg_ave.fits" )

    # delete temporary files (after main routine)

    # images
    imdelete( "pcalqlpdeg_shift.fits" ,ver- )
    imdelete( "pcalqlpdeg_shift_180.fits" ,ver- )
    imdelete( "pcalqlpdeg_shift_360.fits" ,ver- )
    imdelete( "pcalqlpdeg_shift_360a.fits" ,ver- )
    imdelete( "pcalqlpdeg_shift_360b.fits" ,ver- )
    imdelete( "pcalql_atan_ave.fits" ,ver- )
    imdelete( "pcalql_uovq_ave.fits" ,ver- )
    imdelete( "pcalql_thetarad_ave.fits" ,ver- )


    imdelete( "@_pcalql_aq2.lst" ,ver- )
    imdelete( "@_pcalql_au2.lst" ,ver- )
    imdelete( "@_pcalql_aq1.lst" ,ver- )
    imdelete( "@_pcalql_au1.lst" ,ver- )

    imdelete( "@_pcalql_1mnsaq.lst" ,ver- )
    imdelete( "@_pcalql_1mnsau.lst" ,ver- )
    imdelete( "@_pcalql_1plsaq.lst" ,ver- )
    imdelete( "@_pcalql_1plsau.lst" ,ver- )
    imdelete( "pcalql_q_sig.fits" ,ver- )
    imdelete( "pcalql_u_sig.fits" ,ver- )

    imdelete( "@_pcalql_k_all.lst" ,ver- )
    imdelete( "@_pcalql_i_all.lst" ,ver- )
    imdelete( "@_pcalql_q.lst" ,ver- )
    imdelete( "@_pcalql_u.lst" ,ver- )

    # temporary list files
    delete ( "_pcalql_*.lst" ,ver- )
    delete( imgfiles, ver- )

    bye

end

# end

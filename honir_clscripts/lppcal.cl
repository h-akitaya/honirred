#
# lppcal.cl ( -2005.8.19 lips_pcalql.cl )
#   LIPS q, u, p, theta quick look script
#         ver 1.0 2004.2.28 H.Akitaya
#         ver 1.1 2004.3. 4 H.Akitaya
#         ver 1.1 2005.8.19 H.Akitaya (renamed )
#         ver 1.2 2006.7.31 H.Akitaya (task ambiguity reduced)
#
#  input : list file
#       format  *_[oe]_{000,225,450,675}_*.fits
#          (dispcorrected multispec spectra)
#

procedure lppcal( input_fn )

file input_fn     { prompt = "Image List File Name" }

# main

begin

int file_n_q
int file_n_u
real file_nsqrt_q
real file_nsqrt_u
string dummy

# to use "sed"
task sed = "$foreign"

# delete temporary files (before main routine)

delete( "_pcalql_*", verify- )

# main routine

match( "cas000_o", input_fn , > "_pcalql_o_000.lst" )
match( "cas045_o", input_fn , > "_pcalql_o_225.lst" )
match( "cas090_o", input_fn , > "_pcalql_o_450.lst" )
match( "cas135_o", input_fn , > "_pcalql_o_675.lst" )
match( "cas000_e", input_fn , > "_pcalql_e_000.lst" )
match( "cas045_e", input_fn , > "_pcalql_e_225.lst" )
match( "cas090_e", input_fn , > "_pcalql_e_450.lst" )
match( "cas135_e", input_fn , > "_pcalql_e_675.lst" )
#match( "_o_000", input_fn , > "_pcalql_o_000.lst" )
#match( "_o_225", input_fn , > "_pcalql_o_225.lst" )
#match( "_o_450", input_fn , > "_pcalql_o_450.lst" )
#match( "_o_675", input_fn , > "_pcalql_o_675.lst" )
#match( "_e_000", input_fn , > "_pcalql_e_000.lst" )
#match( "_e_225", input_fn , > "_pcalql_e_225.lst" )
#match( "_e_450", input_fn , > "_pcalql_e_450.lst" )
#match( "_e_675", input_fn , > "_pcalql_e_675.lst" )

match( "_o.dc", input_fn , > "_pcalql_o_all.lst" )
match( "_e.dc", input_fn , > "_pcalql_e_all.lst" )

# calc I
sed ('s/_o.dc/_i.dc/', "_pcalql_o_all.lst",  > "_pcalql_i_all.lst" )
sarith( "@_pcalql_o_all.lst", "+", "@_pcalql_e_all.lst", \
       "@_pcalql_i_all.lst", format="multispec", errval=0., verbose-,\
       reverse- )

# k+Ie/Io
sed ('s/_o/_k_/',  "_pcalql_o_all.lst",  > "_pcalql_k_all.lst")
sarith( "@_pcalql_e_all.lst", "/", "@_pcalql_o_all.lst", \
       "@_pcalql_k_all.lst", format="multispec", errval=0., verbose-,\
       reverse- )

# aq^2, au^2
sed ('s/000_o/_aq2_/', "_pcalql_o_000.lst", > "_pcalql_aq2.lst")
sed ('s/045_o/_au2_/', "_pcalql_o_225.lst", > "_pcalql_au2.lst")
sed ('s/_o/_k_/', "_pcalql_o_000.lst", > "_pcalql_k_000.lst")
sed ('s/_o/_k_/', "_pcalql_o_450.lst", > "_pcalql_k_450.lst")
sed ('s/_o/_k_/', "_pcalql_o_225.lst", > "_pcalql_k_225.lst")
sed ('s/_o/_k_/', "_pcalql_o_675.lst", > "_pcalql_k_675.lst")
#
sarith ( "@_pcalql_k_000.lst", "/", "@_pcalql_k_450.lst", \
          "@_pcalql_aq2.lst" , format="multispec", errval=0.,\
	   verbose-, reverse- )

sarith ( "@_pcalql_k_225.lst", "/", "@_pcalql_k_675.lst", \
          "@_pcalql_au2.lst" , format="multispec", errval=0.,\
	   verbose-, reverse- )
#
# aq, au
sed ('s/_aq2_/_aq1_/', "_pcalql_aq2.lst", > "_pcalql_aq1.lst")
sed ('s/_au2_/_au1_/', "_pcalql_au2.lst", > "_pcalql_au1.lst")
#
sarith ( "@_pcalql_aq2.lst", "sqrt", "", "@_pcalql_aq1.lst", \
 format="multispec", errval=0., verbose-, reverse- )
sarith ( "@_pcalql_au2.lst", "sqrt", "", "@_pcalql_au1.lst", \
 format="multispec", errval=0., verbose-, reverse- )

# 1-aq, 1-au, 1+aq, 1+au
sed ('s/_aq1_/_1mnsaq_/', "_pcalql_aq1.lst", > "_pcalql_1mnsaq.lst")
sed ('s/_au1_/_1mnsau_/', "_pcalql_au1.lst", > "_pcalql_1mnsau.lst")
sed ('s/_aq1_/_1plsaq_/', "_pcalql_aq1.lst", > "_pcalql_1plsaq.lst")
sed ('s/_au1_/_1plsau_/', "_pcalql_au1.lst", > "_pcalql_1plsau.lst")

sarith ( "@_pcalql_aq1.lst", "-" , 1.0 , "@_pcalql_1mnsaq.lst", \
 format="multispec", errval=0., verbose-, reverse+ )
sarith ( "@_pcalql_au1.lst", "-" , 1.0 , "@_pcalql_1mnsau.lst", \
 format="multispec", errval=0., verbose-, reverse+ )
sarith ( "@_pcalql_aq1.lst", "+" , 1.0 , "@_pcalql_1plsaq.lst", \
 format="multispec", errval=0., verbose-, reverse+ )
sarith ( "@_pcalql_au1.lst", "+" , 1.0 , "@_pcalql_1plsau.lst", \
 format="multispec", errval=0., verbose-, reverse+ )

#q,u

sed ('s/_aq1_/_q_/', "_pcalql_aq1.lst", > "_pcalql_q.lst")
sed ('s/_au1_/_u_/', "_pcalql_au1.lst", > "_pcalql_u.lst")

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
 
imdelete( "pcalql_q2u2_ave.fits" )
imdelete( "pcalql_u2q2_ave.fits" )
imdelete( "pcalql_q2u2plus1_ave.fits" )
imdelete( "pcalql_u2q2plus1_ave.fits" )
imdelete( "pcalql_q_err2.fits" )
imdelete( "pcalql_u_err2.fits" )
imdelete( "pcalql_deltap_q_2.fits" )
imdelete( "pcalql_deltap_u_2.fits" )
imdelete( "pcalql_p_err2.fits" )
imdelete( "pcalql_deltapdeg_q_2.fits" )
imdelete( "pcalql_deltapdeg_u_2.fits" )
imdelete( "pcalql_pdeg_err2.fits" )
imdelete("pcalql_pdegrad_err_tmp.fits")

imdelete( "pcalql_q2_ave.fits" )
imdelete( "pcalql_u2_ave.fits" )
imdelete( "pcalql_p2_ave.fits" )


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
imdelete( "pcalqlpdeg_shift.fits" )
imdelete( "pcalqlpdeg_shift_180.fits" )
imdelete( "pcalqlpdeg_shift_360.fits" )
imdelete( "pcalqlpdeg_shift_360a.fits" )
imdelete( "pcalqlpdeg_shift_360b.fits" )
imdelete( "pcalql_atan_ave.fits" )
imdelete( "pcalql_uovq_ave.fits" )
imdelete( "pcalql_thetarad_ave.fits" )


imdelete( "@_pcalql_aq2.lst" )
imdelete( "@_pcalql_au2.lst" )
imdelete( "@_pcalql_aq1.lst" )
imdelete( "@_pcalql_au1.lst" )

imdelete( "@_pcalql_1mnsaq.lst" )
imdelete( "@_pcalql_1mnsau.lst" )
imdelete( "@_pcalql_1plsaq.lst" )
imdelete( "@_pcalql_1plsau.lst" )
imdelete( "pcalql_q_sig.fits" )
imdelete( "pcalql_u_sig.fits" )

imdelete( "@_pcalql_k_all.lst" )
imdelete( "@_pcalql_i_all.lst" )
imdelete( "@_pcalql_q.lst" )
imdelete( "@_pcalql_u.lst" )

# temporary list files
delete ( "_pcalql_*.lst", ver- )

bye

end

# end

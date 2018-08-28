#
# lips_xyout.cl
#   LIPS raw data xy-file output
#         ver 1.0 2004.3.11 H.Akitaya
#         ver 1.1 2005.8.19 H.Akitaya  bug fix (output dt was dp )
#    lips_xyout output.xy
#

procedure lips_xyout( output_fn )

file output_fn     { prompt = "Output XY File Name" }

# main

begin

real wl
int ap, ap_before
real i, di, iadu, diadu, q, dq, u, du, p, dp, t, dt
real dw_tmp
real dm
real dw[20]
string dm_s

file f_i = "pcalql_i_ave.fits"
file f_i_err = "pcalql_i_err.fits"
file f_iadu = "pcaliadu_iadu_sum.fits"
file f_iadu_err = "pcaliadu_iadu_err.fits"
file f_q = "pcalql_q_ave.fits"
file f_q_err = "pcalql_q_err.fits"
file f_u = "pcalql_u_ave.fits"
file f_u_err = "pcalql_u_err.fits"
file f_p = "pcalql_p_ave.fits"
file f_p_err = "pcalql_p_err.fits"
file f_t = "pcalql_thetadeg_ave.fits"
file f_t_err = "pcalql_pdegdeg_err.fits"

#file tmpf_i = mktemp( "_tmp_lips_xyout_" )
#file tmpf_i_err = mktemp( "_tmp_lips_xyout_" )
#file tmpf_iadu = mktemp( "_tmp_lips_xyout_" )
#file tmpf_iadu_err = mktemp( "_tmp_lips_xyout_" )
#file tmpf_q = mktemp( "_tmp_lips_xyout_" )
#file tmpf_q_err = mktemp( "_tmp_lips_xyout_" )
#file tmpf_u = mktemp( "_tmp_lips_xyout_" )
#file tmpf_u_err = mktemp( "_tmp_lips_xyout_" )
#file tmpf_p = mktemp( "_tmp_lips_xyout_" )
#file tmpf_p_err = mktemp( "_tmp_lips_xyout_" )
#file tmpf_t = mktemp( "_tmp_lips_xyout_" )
#file tmpf_t_err = mktemp( "_tmp_lips_xyout_" )

file tmpf_slist

file tmpf_i
file tmpf_i_err
file tmpf_iadu
file tmpf_iadu_err
file tmpf_q
file tmpf_q_err
file tmpf_u
file tmpf_u_err
file tmpf_p
file tmpf_p_err
file tmpf_t
file tmpf_t_err

file tmpf_pasted1
file tmpf_pasted2
file tmpf_pasted3


# to use "paste"
task paste = "$foreign"

tmpf_slist = mktemp("_tmp_lips_xyout_slist_")

tmpf_i = mktemp("_tmp_lips_xyout_")
tmpf_i_err = mktemp("_tmp_lips_xyout_")
tmpf_iadu = mktemp("_tmp_lips_xyout_")
tmpf_iadu_err = mktemp("_tmp_lips_xyout_")
tmpf_q = mktemp("_tmp_lips_xyout_")
tmpf_q_err = mktemp("_tmp_lips_xyout_")
tmpf_u = mktemp("_tmp_lips_xyout_")
tmpf_u_err = mktemp("_tmp_lips_xyout_")
tmpf_p = mktemp("_tmp_lips_xyout_")
tmpf_p_err = mktemp("_tmp_lips_xyout_")
tmpf_t = mktemp("_tmp_lips_xyout_")
tmpf_t_err = mktemp("_tmp_lips_xyout_")

tmpf_pasted1 = mktemp("_tmp_lips_xyout_")
tmpf_pasted2 = mktemp("_tmp_lips_xyout_")
tmpf_pasted3 = mktemp("_tmp_lips_xyout_")

# initialize
for( ap=1; ap <= 20; ap=ap+1 )
{
		dw[ap]=0.0
}
# read aperture information ( aperture number, wavelength resolution )
printf( "#lips_xyout: reading aperture information ...\n" )
slist( f_i, long_header=no, > tmpf_slist )

list = tmpf_slist
while( fscan( list, dm_s, ap, dm, dm, dm, dm, dw_tmp, dm, dm_s )!=EOF )
{
		dw[ap] = dw_tmp
}
	
#
printf( "#lips_xyout: reading fits files ...\n" )

listpix( f_i, wcs="world", formats="%16.9e %2d %12.7e", > tmpf_i )

listpix( f_i_err, wcs="world", formats="%13.9e %2d %13.9e", > tmpf_i_err )
listpix( f_iadu, wcs="world", formats="%13.9e %2d %13.9e", > tmpf_iadu )
listpix( f_iadu_err, wcs="world", formats="%13.9e %2d %13.9e", > tmpf_iadu_err )
listpix( f_q, wcs="world", formats="%13.9e %2d %13.9e", > tmpf_q )
listpix( f_q_err, wcs="world", formats="%13.9e %2d %13.9e", > tmpf_q_err )
listpix( f_u, wcs="world", formats="%13.9e %2d %13.9e", > tmpf_u )
listpix( f_u_err, wcs="world", formats="%13.9e %2d %13.9e", > tmpf_u_err )
listpix( f_p, wcs="world", formats="%13.9e %2d %13.9e", > tmpf_p )
listpix( f_p_err, wcs="world", formats="%13.9e %2d %13.9e", > tmpf_p_err )
listpix( f_t, wcs="world", formats="%13.9e %2d %13.9e", > tmpf_t )
listpix( f_t_err, wcs="world", formats="%13.9e %2d %13.9e", > tmpf_t_err )

paste( tmpf_i, tmpf_i_err, tmpf_iadu, tmpf_iadu_err, tmpf_q, tmpf_q_err,\
  ">", tmpf_pasted1 )
paste( tmpf_u, tmpf_u_err, tmpf_p, tmpf_p_err, tmpf_t, tmpf_t_err,\
   ">", tmpf_pasted2 )
paste( tmpf_pasted1, tmpf_pasted2, ">", tmpf_pasted3 )

#
printf( "#lips_xyout: writing %s ...\n", output_fn )
ap_before = 1
list = tmpf_pasted3
while( fscan( list, \
              wl, ap, i, dm, dm, di, dm, dm, iadu, dm, dm, diadu,\
              dm, dm, q, dm, dm, dq, dm, dm, u, dm, dm, du,\
	      dm, dm, p, dm, dm, dp, dm, dm, t, dm, dm, dt) != EOF )
{
#printf( "%16.9e", wl )
		
		if( ap != ap_before) printf("\n", >> output_fn )
			ap_before = ap
		printf( "%16.9e %2d %12.7e %12.7e %12.7e %12.7e %12.7e %12.7e %12.7e %12.7e %12.7e %12.7e %12.7e %12.7e %10.7f\n",\
				wl, ap, i, di, iadu, diadu, q, dq, u, dq, p, dp, t, dt, dw[ap], \
				>> output_fn ) 
	}	      
	

# delete temporary files

delete ( tmpf_slist )

delete ( tmpf_i )
delete ( tmpf_i_err )
delete ( tmpf_iadu )
delete ( tmpf_iadu_err )
delete ( tmpf_q )
delete ( tmpf_q_err )
delete ( tmpf_u )
delete ( tmpf_u_err )
delete ( tmpf_p )
delete ( tmpf_p_err )
delete ( tmpf_t )
delete ( tmpf_t_err )
delete ( tmpf_pasted1 )
delete ( tmpf_pasted2 )
delete ( tmpf_pasted3 )

bye

end

# end

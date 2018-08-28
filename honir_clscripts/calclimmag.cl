#
#   calculate limiting magnutude
#
#           Ver 1.00 2014/07/22 H.Akitaya
#           Ver 1.01 2014/07/28 H.Akitaya
#                 Bug fix
#

procedure calclimmag( in_image, starcatmag, sn )

string in_image {prompt = "Input image" }
real starcatmag {prompt = "Star catalog magnitude"}
real sn {prompt = "Required S/N ratio" }
real cbox = 10
real annulus = 11.0
real dannulus = 2.0
string apertures = "9.0"
real snratio = 5.0
real epadu=11.0
real pixscale = 0.295

begin
    string in_image_, tmp_coord_fn, tmp_mag_fn, bg_region
    real star0_x, star0_y, bg_stddev, starflux, mag0
    
    in_image_=in_image
    tmp_coord_fn=mktemp ( "tmp$tmp_calclimmag1" )
    tmp_mag_fn=mktemp( "tmp$calclimmag2" )

    display( in_image_, 1, >& "dev$null" )
    print("# select object [space]" )
    hngetimcur | scanf( "%f %f", star0_x, star0_y )
    printf("%f %f\n", star0_x, star0_y, > tmp_coord_fn )
    qphot( in_image, cbox, annulus, dannulus, apertures, inter-, \
    coords=tmp_coord_fn, output=tmp_mag_fn, epadu=epadu, \
    radplot-, zmag=0.0, filter="WH_IRAF2" )
    
    txdump( tmp_mag_fn, "FLUX", "ID=1") | scanf("%f", starflux ) 
    printf("# Star position: ( %6.1f, %6.1f )\n# Star flux: %9.3f\n", star0_x, star0_y, starflux )
    
    print("# select background region [space x 2]" )
    getregion | scanf( "%s", bg_region )
    imstatistics( in_image_//bg_region, format-, field="stddev") | scanf( "%f", bg_stddev )
    printf("# Region: %s, BG fluctuation: %9.4f\n", bg_region, bg_stddev )
    
    mag0 = starcatmag + 5./2.*log10( starflux )
    printf("# mag0: %7.3f\n", mag0 )
    
    imglimmag( mag0, bg_stddev, real(apertures)*pixscale, sn, epadu )
    
    delete( tmp_coord_fn, ver- )
    delete( tmp_mag_fn, ver- )

end

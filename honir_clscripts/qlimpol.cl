procedure qlimpol ( in_images, coords )

string in_images { prompt = "Image Name" }
string coords { prompt = "Coordinate file" }

real cbox = 10
real annulus = 11.0
real dannulus = 2.0
string apertures = "9.0"
string logout_intr=""
string offset_fn=""
real mag0 = 0.0
real epadu=2.2 # CCD
bool interactive=no

struct *imglist

begin
     string imgfiles, img, fn_in, fn_out, images
     string tempstr1, tempstr2, buf1, idstr, hn_arm, filter
     string tmpmag_fn, coord_fn
     int year, month, day, hh, mm, ss, n_stars, id
     string reg_obj, reg_obj_sk, reg_comp, reg_comp_sk
     bool flag_indef
     string tmp_coord
     real hwp
     real star0_x, star0_y, tmp_x, tmp_y, diff_x, diff_y
     real star_c[100], star_mag[100], star_x[100], star_y[100], \
       star_merr[100], star_area[100], star_msky[100]
     real obj_c, obj_mag, obj_x, obj_y, obj_area, obj_msky, \
        obj_merr, dmag, err_dmag, \
        time, mjd, exp_t, airmass, ha
     int i, n_images

     images=in_images
     coord_fn = coords
     n_stars = 2
     imgfiles = mktemp ( "tmp$tmp_qlimpol_1_" )
     sections( images, option="fullname", > imgfiles )
     n_images = sections.nimages

     tmpmag_fn = "tmp_qlphottmpmag.mag"

     imglist=imgfiles

     while( fscan( imglist, img ) != EOF ){
	hselect( img, "MJD, EXPTIME, AIRMASS, HA-DEG, HWPANGLE", \
	yes ) | scanf("%f %f %f %f %f", mjd, exp_t, airmass, ha, hwp )
	hselect( img, "HN-ARM", yes ) | scanf("%s", hn_arm )
	if( hn_arm == "ira" ){
	    hselect( img, "WH_IRAF2", yes ) | scanf("%s", filter ) 
	}else if( hn_arm == "opt" ){
	    hselect( img, "WH_OPTF2", yes ) | scanf("%s", filter )
	}else{
	    filter = "INDEF"
	}
	if( access( tmpmag_fn ) )
	    delete( tmpmag_fn, ver- )
        qphot( img, cbox, annulus, dannulus, apertures, inter-, \
	    coords=coord_fn, output=tmpmag_fn, epadu=epadu,
	    filter="" )
        for( id=1; id<=n_stars; id+=1 ){
	    idstr="ID="//id
            txdump( tmpmag_fn, "XCENTER, YCENTER, FLUX, AREA, \
	            MSKY, MAG, MERR", idstr ) \
	            | scanf( "%f %f %f %f %f %f %f ", \
		    obj_x, obj_y, obj_c, obj_area, obj_msky, \
		    obj_mag, obj_merr )
	    star_x[id]=obj_x
	    star_y[id]=obj_y
	    star_c[id]=obj_c
	    star_area[id]=obj_area
	    star_msky[id]=obj_msky
	    star_mag[id]=obj_mag
	    star_merr[id]=obj_merr
	}
 	time=mjd
	printf("%20s %6s %6.2f %13.6f %8.3f %14.10f %10.6f", \
		     img, filter, hwp,time, exp_t, ha, airmass)
        for(id=1; id<=n_stars; id+=1 ){
	    printf("%2d %9.4f %9.4f", \
	    id, star_c[id], star_c[id]*(10**(2.0/5.0*star_merr[id] )-1.0) )
	}
	printf("%13.7f %5.1f", star_c[2]/star_c[1], real( apertures ) )
#        for(id=1; id<=n_stars; id+=1 ){
#            printf("#%02d %8.2f %8.2f %11.7f %11.7f %10.1f %8.3f %8.3f ", \
#	    id, star_x[id], star_y[id], star_c[id], \
#	    star_area[id], star_msky[id], star_mag[id], star_merr[id] )
#	}
	printf("\n" )
    }
    delete( imgfiles, ver-, >& "dev$null" )
#    print("# Done.\n" )
end

# end of the script

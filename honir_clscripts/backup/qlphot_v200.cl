#
#   photometry  quick look
#
#           Ver 1.00 2013.01.29 H.Akitaya
#           Ver 1.10 2013.02.15 H.Akitaya include MJD, error
#           Ver 2.00 2013/06/14 H.Akitaya modified largely
#
#  Usage: qlphot (image(s) or @list) (coordinate file)
#

procedure qlphoto ( in_images, coord_fn )

string in_images { prompt = "Image Name" }
string coord_fn { prompt = "Coordinate file" }
real cbox = 10
real annulus = 11.0
real dannulus = 2.0
string apertures = "9.0"
real mag0 = 0.0
real epadu=2.2 # CCD

struct *imglist

begin
     string imgfiles, img, fn_in, fn_out, in_images_
     string tempstr1, tempstr2, buf1, idstr
     string tmpmag_fn, coord_fn_
     int year, month, day, hh, mm, ss, n_stars, id
     string reg_obj, reg_obj_sk, reg_comp, reg_comp_sk
     bool flag_indef

     real star_c[100], star_mag[100], star_x[100], star_y[100], \
       star_merr[100], star_area[100], star_msky[100]

     real obj_c, obj_mag, obj_x, obj_y, obj_area, obj_msky, \
	obj_merr, dmag, err_dmag, \
	time, mjd, exp_t, airmass, ha
     in_images_ = in_images
     coord_fn_ = coord_fn
#     tmpmag_fn = "tmp$tmp_qlphottmpmag.mag"
     tmpmag_fn = "tmp_qlphottmpmag.mag"
	
     print("# qlphot" )

     imgfiles = mktemp ( "tmp$_tmp_qlphot_" )
     sections( in_images_, option="fullname", > imgfiles )
     n_stars=0
     list=coord_fn_
     while( fscanf( list, "%s", buf1 ) != EOF ){
         n_stars+=1
     }

     printf("# time: %s\n", buf1)
     printf("# parameters\n")
     printf("# cbox=%5.2f\n# annulus=%5.2f\n# dannulus=%5.2f\n", \
		  cbox, annulus, dannulus )
     printf("# apertures=%5.2f\n# coord_fn=%s\n# gain=%6.3f\n", \
		apertures, coord_fn, epadu )

     imglist = imgfiles
     while( fscan( imglist, img ) != EOF ){
#	hselect( img, "LST", yes) | scanf("\"%d/%d/%d %d:%d:%d\"", year, month, day, hh, mm, ss)
	hselect( img, "MJD, EXPTIME, AIRMASS, HA-DEG", yes) | scanf("%f %f %f %f", mjd, exp_t, airmass, ha )
	
	if( access( tmpmag_fn ) ){
	    delete( tmpmag_fn, ver- )
	}
	qphot( img, cbox, annulus, dannulus, apertures, inter-, coords=coord_fn_, output=tmpmag_fn )
	time | scanf( "%30c", buf1 )
	for( id=1; id<=n_stars; id+=1 ){
	  idstr="ID="//id
#	  printf( "%s\n", idstr ) # for debug
          txdump( tmpmag_fn, "XCENTER, YCENTER, FLUX, AREA, MSKY, MAG, MERR", idstr ) \
	     | scanf( "%f %f %f %f %f %f %f ", obj_x, obj_y, obj_c, obj_area, obj_msky, obj_mag, obj_merr )
	     star_x[id]=obj_x
	     star_y[id]=obj_y
	     star_c[id]=obj_c
	     star_area[id]=obj_area
	     star_msky[id]=obj_msky
	     star_mag[id]=obj_mag
	     star_merr[id]=obj_merr
        }

	time=mjd
	printf("%20s %13.6f %8.3f %14.10f %10.6f ", \
		     img, time, exp_t, ha, airmass )
        for(id=1; id<=n_stars; id+=1 ){
            printf("#%02d %8.2f %8.2f %11.7f %11.7f %10.1f %8.3f %8.3f ", \
	    id, star_x[id], star_y[id], star_c[id], \
	    star_area[id], star_msky[id], star_mag[id], star_merr[id] )
	}
        if( n_stars >= 2 ) {
           printf("#0-1 " )
 	   flag_indef=no
	   if ( str(star_mag[1])=="INDEF" ) flag_indef=yes
	   if ( str(star_mag[2])=="INDEF" ) flag_indef=yes
	   if ( flag_indef==yes ) {
              printf( "%8s ", "INDEF" )
	   } else {
              dmag = star_mag[1]-star_mag[2]
	      printf("%8.3f ", dmag )
	   }
 	   flag_indef=no
	   if ( str(star_merr[1])=="INDEF" ) flag_indef=yes
	   if ( str(star_merr[2])=="INDEF" ) flag_indef=yes
	   if ( flag_indef == yes ){
	      printf("%8s ", "INDEF" )
	   } else {
              err_dmag = sqrt( star_merr[1]**2 + star_merr[2]**2)
	      printf("%8.4f ", err_dmag )
           }
        }
        if( n_stars >= 3 ) {
           printf("#1-2 " )
 	   flag_indef=no
	   if ( str(star_mag[2])=="INDEF" ) flag_indef=yes
	   if ( str(star_mag[3])=="INDEF" ) flag_indef=yes
	   if ( flag_indef==yes ) {
              printf( "%8s ", "INDEF" )
	   } else {
              dmag = star_mag[2]-star_mag[3]
	      printf("%8.3f ", dmag )
	   }
 	   flag_indef=no
	   if ( str(star_merr[2])=="INDEF" ) flag_indef=yes
	   if ( str(star_merr[3])=="INDEF" ) flag_indef=yes
	   if ( flag_indef == yes ){
	      printf("%8s ", "INDEF" )
	   } else {
              err_dmag = sqrt( star_merr[2]**2 + star_merr[3]**2)
	      printf("%8.4f ", err_dmag )
           }
        }
	printf("\n")
     }

     delete( imgfiles, ver-, >& "dev$null" )
     print("# Done.\n" )

end

# end of the script

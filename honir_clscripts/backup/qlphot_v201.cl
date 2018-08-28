#
#   photometry  quick look
#
#           Ver 1.00 2013.01.29 H.Akitaya
#           Ver 1.10 2013.02.15 H.Akitaya include MJD, error
#           Ver 2.00 2013/06/14 H.Akitaya modified largely
#           Ver 2.01 ?
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
string logout_intr=""
string offset_fn=""
real mag0 = 0.0
real epadu=2.2 # CCD
bool interactive=no

struct *imglist, *list_offset

begin
     string imgfiles, img, fn_in, fn_out, in_images_
     string tempstr1, tempstr2, buf1, idstr
     string tmpmag_fn, coord_fn_
     int year, month, day, hh, mm, ss, n_stars, id
     string reg_obj, reg_obj_sk, reg_comp, reg_comp_sk
     bool flag_indef
     string tmp_coord
     real star0_x, star0_y, tmp_x, tmp_y, diff_x, diff_y;
     int i, n_images

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

     if( logout_intr != "" ) {
         if ( access( logout_intr ) ){
	     error(1, "# Interactive mode log file "//logout_intr//" exists! Abort." )
         }
     }

     n_stars=0
     list=coord_fn_
     while( fscanf( list, "%s", buf1 ) != EOF ){
         n_stars+=1
     }
     imgfiles = mktemp ( "tmp$_tmp_qlphot_" )
     sections( in_images_, option="fullname", > imgfiles )
     n_images = sections.nimages
     if( offset_fn !="" ) {
        if( !access( offset_fn ) ) {
	   error(1, "# Offset file "//offset_fn//" not found! Abort." )
        }
	sections( "@"//offset_fn, option- )
	print( sections.nimages, n_images )
	if( sections.nimages != n_images ){
	   error(1, "# Wrong line numbers in "//offset_fn//"! Abort." )
        }
	list_offset=offset_fn
     }
     

     time | scanf( "%30c", buf1 )
     printf("# time: %s\n", buf1)
     printf("# parameters\n")
     printf("# cbox=%5.2f\n# annulus=%5.2f\n# dannulus=%5.2f\n", \
		  cbox, annulus, dannulus )
     printf("# apertures=%5.2f\n# coord_fn=%s\n# gain=%6.3f\n", \
		apertures, coord_fn, epadu )
     printf("# interactive mode=%b\n", interactive )		
     printf("# interactive mode log file =%s\n", logout_intr )		
     imglist = imgfiles
     while( fscan( imglist, img ) != EOF ){
#	hselect( img, "LST", yes) | scanf("\"%d/%d/%d %d:%d:%d\"", year, month, day, hh, mm, ss)
	hselect( img, "MJD, EXPTIME, AIRMASS, HA-DEG", yes) | scanf("%f %f %f %f", mjd, exp_t, airmass, ha )
	
	if( access( tmpmag_fn ) ){
	    delete( tmpmag_fn, ver- )
	}
	if( interactive==yes || offset_fn !="" ){
	    tmp_coord=mktemp ( "tmp$_tmp_qlphot_" )
	    display( img, 1, >& "dev$null" )
	    if( interactive == yes ) {
  	       getimcur | scanf( "%f %f %s", star0_x, star0_y, buf1 )
            } else {
               buf1=fscanf( list_offset, "%f %f", star0_x, star0_y )
	    }
            if( logout_intr != "" ) {
	       printf("%8.3f %8.3f\n", star0_x, star0_y, >> logout_intr )
            }
	    list=coord_fn
	    i=0
	    while( fscanf( list, "%f %f", tmp_x, tmp_y ) != EOF ){
	        if( i==0 ) {
		   diff_x = tmp_x - star0_x
		   diff_y = tmp_y - star0_y
		}
		x = tmp_x - diff_x
		y = tmp_y - diff_y
		printf( "%9.3f %9.3f\n", x, y, >> tmp_coord )
		i+=1
	    }
	    coord_fn_ = tmp_coord
#	    type( tmp_coord )
	}
	qphot( img, cbox, annulus, dannulus, apertures, inter-, coords=coord_fn_, output=tmpmag_fn, epadu=epadu )
	if ( interactive==yes ) delete( tmp_coord, ver- )
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
           for( i=2; i<=n_stars; i+=1 ){
              printf("#1-%d ", i)
 	      flag_indef=no
	      if ( str(star_mag[1])=="INDEF" ) flag_indef=yes
	      if ( str(star_mag[i])=="INDEF" ) flag_indef=yes
	      if ( flag_indef==yes ) {
                 printf( "%8s ", "INDEF" )
	      } else {
                 dmag = star_mag[1]-star_mag[i]
	         printf("%8.3f ", dmag )
	      }
 	      flag_indef=no
	      if ( str(star_merr[1])=="INDEF" ) flag_indef=yes
	      if ( str(star_merr[i])=="INDEF" ) flag_indef=yes
	      if ( flag_indef == yes ){
	         printf("%8s ", "INDEF" )
	      } else {
                 err_dmag = sqrt( star_merr[1]**2 + star_merr[i]**2)
	         printf("%8.4f ", err_dmag )
              }
           }
        }
        if( n_stars >= 3 ) {
           printf("#2-3 " )
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

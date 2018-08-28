#
#   photometry  quick look
#
#           Ver 1.00 2013.01.29 H.Akitaya
#           Ver 1.10 2013.02.15 H.Akitaya include MJD, error
#                ->  2013/06/12 H.Akitaya  qlphot.cl -> qlphot_old.cl
#
#  Usage: qlphot_old (image(s) or @list) (coordinate file)
#

procedure qlphoto_old ( _in_images, _coord_fn )

string _in_images { prompt = "Image Name" }
string _coord_fn { prompt = "Coordinate file" }
real cbox = 10
real annulus = 11.0
real dannulus = 2.0
string apertures = "9.0"
real mag0 = 0.0
int day0 = 28
real epadu=11.6 # VIRGO

struct *imglist

begin
     string imgfiles, img, fn_in, fn_out, in_images
     string tempstr1, tempstr2
     string tmpmag_fn, coord_fn
     int year, month, day, hh, mm, ss
     string reg_obj, reg_obj_sk, reg_comp, reg_comp_sk
     real obj_c, obj_mag, obj_x, obj_y, comp_c, comp_mag, comp_x, comp_y, \
	dmag, time, mjd;
     real obj_merr, comp_merr, dmag_merr
     in_images = _in_images
     coord_fn = _coord_fn
     tmpmag_fn = "tmp$qltmpmag.mag"
	
     print("# qluiphoto" )
	
     imgfiles = mktemp ( "tmp$_tmp_qluiphoto1_" )
     sections( in_images, option="fullname", > imgfiles )

     imglist = imgfiles
     while( fscan( imglist, img ) != EOF ){
#	hselect( img, "LST", yes) | scanf("\"%d/%d/%d %d:%d:%d\"", year, month, day, hh, mm, ss)
	hselect( img, "MJD", yes) | scanf("%f", mjd )

	
	if( access( tmpmag_fn ) ){
	    delete( tmpmag_fn, ver- )
	}
	qphot( img, cbox, annulus, dannulus, apertures, inter-, coords=coord_fn, output=tmpmag_fn )
        txdump( tmpmag_fn, "XCENTER,YCENTER,FLUX,MAG,MERR", "ID=1" ) \
	   | scanf( "%f %f %f %f %f", obj_x, obj_y, obj_c, obj_mag, obj_merr )
        txdump( tmpmag_fn, "XCENTER,YCENTER,FLUX,MAG,MERR", "ID=2" ) \
	   | scanf( "%f %f %f %f %f", comp_x, comp_y, comp_c, comp_mag, comp_merr )

#	time = (real(day)-day0) + real(hh)/24.0 + mm/24.0/60.0 + ss/24.0/60.0/60.0
	time=mjd
	if ( str(obj_mag)!="INDEF" && str(comp_mag)!="INDEF" && str(obj_merr)!="INDEF" && str(comp_merr)!="INDEF"){
  	   dmag = obj_mag-comp_mag
#         printf("%20s %04d/%02d/%02d %02d:%02d:%02d %13.7f %8.2f %8.2f %8.3f %8.2f %8.2f %8.3f %8.3f\n", img, year, month, day, hh, mm, ss, time, obj_x, obj_y, obj_mag, comp_x, comp_y, comp_mag, dmag )
	   dmag_merr = sqrt( obj_merr*obj_merr + comp_merr*comp_merr)
           printf("%20s %13.7f %8.2f %8.2f %8.3f %8.3f %8.2f %8.2f %8.3f %8.3f %8.3f %8.3f\n", img, time, obj_x, obj_y, obj_mag, obj_merr, comp_x, comp_y, comp_mag, comp_merr, dmag, dmag_merr )
        }
     }

     delete( imgfiles, ver-, >& "dev$null" )
     print("# Done.\n" )

end

# end of the script

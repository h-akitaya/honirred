#
#   psf photometry  quick look
#         qlpsfphot.cl
#
#     (based on honir_clscripts/qlphot.cl )
#
#           Ver 1.00 2013.06.08 H.Akitaya
#
#  Usage: qlpsfphot (image(s) or @list) (reference coord) (objects coord)
#

procedure qlpsfphoto ( in_images, psf_coord_list, obj_coord_list )

string in_images { prompt = "Image Name(s) or List" }
string psf_coord_list { prompt = "PSF reference coordinate list" }
string obj_coord_list { prompt = "Objects coordinate list" }
string datapars = "datdataps.par"
string centerpars = "datcentes.par"
string fitskypars = "datfitsks.par"
string photpars = "datphotps.par"
string daopars = "datdaopas.par"
int maxnpsf = 20

struct *imglist

begin
     string in_images_, psf_coord_list_, obj_coord_list_
     string imgfiles, img
     string tmp_phot1, tmp_phot2, tmp_pst, tmp_plt, tmp_psf, tmp_opst
     string tmp_allstar, tmp_rej, tmp_grp
     real obj_c, obj_mag, obj_x, obj_y, comp_c, comp_mag, comp_x, comp_y, \
	dmag, time, mjd;
     real obj_merr, comp_merr, dmag_merr
     in_images_ = in_images

     psf_coord_list_ = psf_coord_list
     obj_coord_list_ = obj_coord_list

	
     print("# psfqlphoto" )
	
     imgfiles = mktemp ( "tmp$_tmp_qluiphoto1_" )
     sections( in_images_, option="fullname", > imgfiles )

     imglist = imgfiles
     while( fscan( imglist, img ) != EOF ){
     
	hselect( img, "MJD", yes) | scanf("%f", mjd )
	
#	if( access( tmpmag_fn ) ){
#	    delete( tmpmag_fn, ver- )
#	}

#	qphot( img, cbox, annulus, dannulus, apertures, inter-, coords=coord_fn, output=tmpmag_fn )

	# phot for psf model stars and objects
#        tmp_phot1 = mktemp ( "tmp$_tmp_qlpsfphoto_" )
        tmp_phot1 = "_tmp.phot"
        tmp_phot2 = mktemp ( "tmp$_tmp_qlpsfphoto_" )
	phot( img, psf_coord_list_, tmp_phot1, \
	datapars=datapars, centerpars=centerpars, \
	fitskypars=fitskypars, photpar=photpars, \
	inter- )
	phot( img, obj_coord_list_, tmp_phot2, \
	datapars=datapars, centerpars=centerpars, \
	fitskypars=fitskypars, photpars=photpars, \
	interactive- )
	
	# psfselect
        tmp_pst = mktemp ( "tmp$_tmp_qlpsfphoto_" )
        tmp_plt = mktemp ( "tmp$_tmp_qlpsfphoto_" )
	pstselect( img, tmp_phot1, tmp_pst, maxnpsf=maxnpsf, \
	mkstars-, plotfile=tmp_plt, \
	datapars=datapars, daopars=daopars, \
	interactive-, verbose-, verify- )
	
	#psf
#        tmp_psf = mktemp ( "tmp$_tmp_qlpsfphoto_" )
        tmp_psf = "_tmp.psf"
        tmp_opst = mktemp ( "tmp$_tmp_qlpsfphoto_" )
        tmp_grp = mktemp ( "tmp$_tmp_qlpsfphoto_" )
	psf( img, tmp_phot1, tmp_pst, tmp_psf, \
	tmp_opst, tmp_grp, plotfile=tmp_plt, \
        datapars=datapars, daopars=daopars, \
	interactive-, mkstars-, verify- )
	
	#allstar
#       tmp_allstar = mktemp ( "tmp$_tmp_qlpsfphoto_" )
       tmp_allstar = "_tmp.allstar"
        tmp_rej = mktemp ( "tmp$_tmp_qlpsfphoto_" )
	allstar( img, tmp_phot2, tmp_psf, tmp_allstar, tmp_rej, \
	"default", \
        datapars=datapars, daopars=daopars, verbose-, verify- )

        txdump( tmp_allstar, "XCENTER,YCENTER,MAG,MERR", "ID=1" ) \
	   | scanf( "%f %f %f %f %f", obj_x, obj_y,  obj_mag, obj_merr )
        txdump( tmp_allstar, "XCENTER,YCENTER,MAG,MERR", "ID=2" ) \
	   | scanf( "%f %f %f %f %f", comp_x, comp_y,  comp_mag, comp_merr )

	time=mjd
	if ( str(obj_mag)!="INDEF" && str(comp_mag)!="INDEF" && str(obj_merr)!="INDEF" && str(comp_merr)!="INDEF"){
  	   dmag = obj_mag-comp_mag
	   dmag_merr = sqrt( obj_merr*obj_merr + comp_merr*comp_merr)
           printf("%20s %13.7f %8.2f %8.2f %8.3f %8.3f %8.2f %8.2f %8.3f %8.3f %8.3f %8.3f\n", img, time, obj_x, obj_y, obj_mag, obj_merr, comp_x, comp_y, comp_mag, comp_merr, dmag, dmag_merr )
        }
        delete( tmp_phot1, ver-, >& "dev$null" )
        delete( tmp_phot2, ver-, >& "dev$null" )
        delete( tmp_plt, ver-, >& "dev$null" )
        delete( tmp_pst, ver-, >& "dev$null" )
        delete( tmp_opst, ver-, >& "dev$null" )
#        delete( tmp_allstar, ver-, >& "dev$null" )
        delete( tmp_rej, ver-, >& "dev$null" )
        delete( tmp_grp, ver-, >& "dev$null" )
#        imdelete( tmp_psf, ver-  )
     }

     delete( imgfiles, ver-, >& "dev$null" )
   
     print("# Done.\n" )

end

# end of the script

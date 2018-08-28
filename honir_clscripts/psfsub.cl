#
#   psf subtraction
#         psfsub.cl
#
#     (based on honir_clscripts/qlpsfphot.cl )
#
#           Ver 1.00 2013/06/10 H.Akitaya
#           Ver 1.10 2013/07/11 H.Akitaya  : offset file 
#
#  Usage: psfsub (image(s) or @list) (reference coord) (objects coord)
#

procedure psfsub( in_images, psf_coord_list, obj_coord_list )

string in_images { prompt = "Image Name(s) or List" }
string psf_coord_list { prompt = "PSF reference coordinate list" }
string obj_coord_list { prompt = "Objects coordinate list" }
string offset_fn=""
string datapars = "datdataps.par"
string ref_centerpars = "datcentes_ref.par"
string sub_centerpars = "datcentes_sub.par"
string fitskypars = "datfitsks.par"
string photpars = "datphotps.par"
string daopars = "datdaopas.par"
int maxnpsf = 20
bool erace_object = no

struct *imglist

begin
     string in_images_, psf_coord_list_, obj_coord_list_, psf_coord_list_proc
     string imgfiles, img, tmp_offset_coord
     file tmp_phot1, tmp_phot2, tmp_pst, tmp_plt, tmp_psf, tmp_opst
     file tmp_allstar, tmp_rej, tmp_grp
     file tmp_obj_coord_diff
     real obj_x, obj_y, diff_x, diff_y;
     real obj1_x, obj1_y, obj_diff_x, obj_diff_y;
     bool flag_first, flag_offset=no
     int n_offsetdata, n_image
     real offset_x[999], offset_y[999]

     in_images_ = in_images
     psf_coord_list_ = psf_coord_list
     obj_coord_list_ = obj_coord_list
	
     print("# psfsub" )
	
     imgfiles = mktemp ( "tmp$_tmp_qluiphoto_1" )
     sections( in_images_, option="fullname", > imgfiles )

     if( offset_fn != "" ) {
         if( !access( offset_fn ) ){
	     error(1, "# Offset file name "//offset_fn//" not found. Aborted." )
	 }else{
	     flag_offset=yes
	     list = offset_fn
	     n_offsetdata=0
	     while( fscanf( list, "%f %f", x, y ) != EOF ) {
	         offset_x[n_offsetdata+1] = x
	         offset_y[n_offsetdata+1] = y
		 n_offsetdata += 1
	     }
	 }
     }

     imglist = imgfiles
     
     n_image=0
     while( fscan( imglist, img ) != EOF ){
	n_image += 1

	# phot for psf model stars and objects
        tmp_phot1 = mktemp ( "tmp$_tmp_qlpsfphoto_2" )
#        tmp_phot1 = "_tmp.phot"
        tmp_phot2 = mktemp ( "tmp$_tmp_qlpsfphoto_3" )
	if( flag_offset == yes ){
            tmp_offset_coord = mktemp ( "tmp$_tmp_qlpsfphoto_4" )
	    mkoffcoordlst( psf_coord_list_, offset_x[n_image], offset_y[n_image], tmp_offset_coord )
	    psf_coord_list_proc =  tmp_offset_coord
	}else{
	    psf_coord_list_proc =  psf_coord_list_
	}	

	phot( img, psf_coord_list_proc, tmp_phot1, \
	datapars=datapars, centerpars=ref_centerpars, \
	fitskypars=fitskypars, photpar=photpars, \
	inter- )
        txdump( tmp_phot1, "XCENTER,YCENTER", "ID=1" ) \
	   | scanf( "%f %f", obj1_x, obj1_y )
        tmp_obj_coord_diff = mktemp ( "tmp$_tmp_qlpsfphoto_5" )
	list = obj_coord_list_
	flag_first=yes
	while( fscanf( list, "%f %f", obj_x, obj_y ) != EOF ) {
	  if( flag_first == yes ) {
	     diff_x = obj1_x - obj_x
	     diff_y = obj1_y - obj_y
	     printf("# offset(x,y)=(%7.3f,%7.3f)\n", diff_x, diff_y )
	     if( erace_object == yes ){
	         obj_diff_x = obj_x+diff_x
	         obj_diff_y = obj_y+diff_y
	         printf("%f %f\n", obj_diff_x, obj_diff_y, >> tmp_obj_coord_diff )
 	         printf("# psf substar (object itself) (x,y)=(%7.3f,%7.3f)\n", obj_diff_x, obj_diff_y  )
             }
	     flag_first=no
	  } else {
	     obj_diff_x = obj_x+diff_x
	     obj_diff_y = obj_y+diff_y
	     printf("%f %f\n", obj_diff_x, obj_diff_y, >> tmp_obj_coord_diff )
	     printf("# psf substar(x,y)=(%7.3f,%7.3f)\n", obj_diff_x, obj_diff_y )
	  }
	}
	phot( img, tmp_obj_coord_diff, tmp_phot2, \
	datapars=datapars, centerpars=sub_centerpars, \
	fitskypars=fitskypars, photpars=photpars, \
	interactive- )
	
	# psfselect
        tmp_pst = mktemp ( "tmp$_tmp_qlpsfphoto_6" )
#        tmp_pst = "_tmp.pst"
        tmp_plt = mktemp ( "tmp$_tmp_qlpsfphoto_7" )
	pstselect( img, tmp_phot1, tmp_pst, maxnpsf=maxnpsf, \
	mkstars-, plotfile=tmp_plt, \
	datapars=datapars, daopars=daopars, \
	interactive-, verbose-, verify- )
	
	#psf
        tmp_psf = mktemp ( "tmp$_tmp_qlpsfphoto_" )
#        tmp_psf = "_tmp.psf"
        tmp_opst = mktemp ( "tmp$_tmp_qlpsfphoto_" )
        tmp_grp = mktemp ( "tmp$_tmp_qlpsfphoto_" )
	psf( img, tmp_phot1, tmp_pst, tmp_psf, \
	tmp_opst, tmp_grp, plotfile=tmp_plt, \
        datapars=datapars, daopars=daopars, \
	interactive-, mkstars-, verify- )
#	printf("%s\n", tmp_psf )
#	= access( tmp_psf//".fits" )
	if( access( tmp_psf//".fits" ) ){
	   printf("# PSF fitting finished.\n")
        } else {
	   printf("# PSF fitting Failed! Skip.\n")
           delete( tmp_phot1, ver-, >& "dev$null" )
           delete( tmp_phot2, ver-, >& "dev$null" )
           delete( tmp_plt, ver-, >& "dev$null" )
           delete( tmp_pst, ver-, >& "dev$null" )
	   next
	}
	#allstar
       tmp_allstar = mktemp ( "tmp$_tmp_qlpsfphoto_" )
#       tmp_allstar = "_tmp.allstar"
        tmp_rej = mktemp ( "tmp$_tmp_qlpsfphoto_" )
	allstar( img, tmp_phot2, tmp_psf, tmp_allstar, tmp_rej, \
	"default", \
        datapars=datapars, daopars=daopars, verbose-, verify- )

	termprocess:
        delete( tmp_phot1, ver-, >& "dev$null" )
        delete( tmp_phot2, ver-, >& "dev$null" )
        delete( tmp_plt, ver-, >& "dev$null" )
        delete( tmp_pst, ver-, >& "dev$null" )
        delete( tmp_opst, ver-, >& "dev$null" )
        delete( tmp_allstar, ver-, >& "dev$null" )
        delete( tmp_rej, ver-, >& "dev$null" )
        delete( tmp_grp, ver-, >& "dev$null" )
        delete( tmp_obj_coord_diff, ver-, >& "dev$null" )
	if( flag_offset == yes ){
            delete ( tmp_offset_coord, ver- )
	}
        imdelete( tmp_psf, ver-  )
     }

     delete( imgfiles, ver-, >& "dev$null" )
   
     print("# Done.\n" )

end

# end of the script

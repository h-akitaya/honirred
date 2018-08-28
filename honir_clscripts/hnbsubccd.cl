#
#  hnbsubccd.cl
#  HONIR bias template subtraction
#
#           Ver 0.01 2011. 9.30 H.Akitaya
#           Ver 0.02 2011.10. 1 H.Akitaya : parameter template
#           Ver 1.00 2014/03/03 H.Akitaya : hnbsub_ccd.cl -> hnbsubccd.cl
#           Ver 1.10 2014/04/09 H.Akitaya : override, clean mode
#           Ver 1.10 2014/05/07 H.Akitaya : bug fix
#
#  input : file(s) or @list-file
#

procedure hnbsubccd ( in_images )

string in_images { prompt = "Image Name"}
string se_in = "_bt"
string se_out = "_bs"
string mainext = ".fits"
string template = ""
struct *imglist
bool override = no
bool clean = no

begin
     string imgfiles, biasstat, img, fn_in, fn_out, img_root
     string fn_bias_template
     if( template == ""){
          fn_bias_template = osfn( str( envget( "bias_template_fn" ) ) )
     }else{
      fn_bias_template = osfn( template )
      }

     print("# hnbsubccd.cl" )

     imgfiles = mktemp ( "_lpbsub_tmp1" )
     sections( in_images, option="fullname", > imgfiles )

     imglist = imgfiles
     while( fscan( imglist, img ) != EOF ){
     
        # get rid of the extentions
        extsrm( img, mainext, se_in ) | scanf( "%s", img_root )

	# make file names 
#	fn_in = img_root//se_in//mainext
	fn_in = img
	fn_out = img_root//se_out//mainext

	# bias subtraction
	if( access( fn_out ) ){
	    if( override == no ) {
	        printf("# Output file %s exists. Skip.\n", fn_out )
	        next
	    }else{
	        printf("# Output file %s exists. Override..\n", fn_out )
		imdelete( fn_out, ver- )
            }
        }
        printf( "%s - %s -> %s\n", fn_in, fn_bias_template, fn_out )
        imarith( fn_in, "-", fn_bias_template, fn_out )
	if( clean== yes ){
	    printf("Deleting original file %s\n", fn_in )
	    imdelete( fn_in, ver- )
	}
     }

     if( access( imgfiles ) )
         delete( imgfiles, ver- )
     print("# Done. (hnbsubccd.cl)" )

end

# end of the script

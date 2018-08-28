#
#  lpbsub.cl
#  LIPS bias subtraction
#
#           Ver 1.00 2005. 8.10 H.Akitaya
#
#  input : file(s) or @list-file
#

procedure lpbsub ( in_images )

string in_images { prompt = "Image Name"}
string subext_in = "_bssp"
string subext_out = "_bsub"
string mainext = ".fits"
int ov_x1 = 2171
int ov_x2 = 2190
int ov_y1 = 101
int ov_y2 = 1900
struct *imglist

begin
     string imgfiles, biasstat, img, fn_in, fn_out, ov_reg
     int i,j, n_mainext
     real biasval
     
     print("# lpbsub.cl Ver 1.00" )

     ov_reg = "["//ov_x1//":"//ov_x2//","//ov_y1//":"//ov_y2//"]"
     printf("# overscan region %s\n", ov_reg )
     
     imgfiles = mktemp ( "_lpbsub_tmp1" )
     biasstat = mktemp ( "_lpbsub_tmp2" )
     
     sections( in_images, option="fullname", > imgfiles )

     imglist = imgfiles
     while( fscan( imglist, img ) != EOF ){
     
        # get rid of the extentions
        extsrm( img, mainext, subext_in ) | scanf( "%s", img )

	# make file names 
	fn_in = img//subext_in//mainext
	fn_out = img//subext_out//mainext

	# measure overscan-region bias value
	imstatistics( fn_in//ov_reg, format-, field="midpt" ) | \
	                                 scanf( "%f", biasval )
	printf( "# %18s %18s %12.5f\n", fn_in, fn_out, biasval )
	
	# bias subtraction
	if( ! access( fn_out ) ){
	    imarith( fn_in, "-", biasval, fn_out )
            print( biasval , >> biasstat )
	}else{
	    printf("# Error: output file %s exists.\n", fn_out )
	}
     }
     # output statistics 
     print("# statistics" )
     type( biasstat ) | average

     # clean up
     delete( imgfiles, ver-, >& "dev$null" )
     delete( biasstat, ver-, >& "dev$null" )
     
     print("# Done. (lpbsub.cl)" )

end

# end of the script

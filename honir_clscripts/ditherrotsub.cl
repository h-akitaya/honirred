#
#   dithered images rotation subtraction
#
#           Ver 1.00 2013/06/19 H.Akitaya
#
#  Usage: ditherrotsub (image(s) or @list)
#

procedure ditherrotsub ( in_images )

string in_images { prompt = "Image Name" }
int n_shift=1
string subext=""
bool verbose = no
int n_set=0
struct *imglist

begin
     int n_files, i, num
     string filename[99]
     string tmp_fn1
     file tmpsub1, tmpsub2
     bool flag_exist

     string imgfiles, img, fn_in, fn_out, in_images_

     in_images_ = in_images
	
     if (verbose == yes ) print("# ditherrotsub" )

     imgfiles = mktemp ( "tmp$_tmp_qlphot_" )
     sections( in_images_, option="fullname", > imgfiles )

     n_files=0
     list = imgfiles
     while( fscanf( list, "%s", tmp_fn1 ) != EOF ){
         n_files+=1
         filename[n_files]=tmp_fn1
     }
     if ( n_set == 0 ) n_set = n_files
     if (verbose == yes ) {
        printf("# %s files found.\n", n_files )
	printf("# %d files / set\n", n_set )
     }
     if ( mod( n_files, n_set ) != 0 ){
        error(1, "# Wrong file number or n_set !!" )
     }

     tmpsub1 = mktemp ( "tmp$_tmp_qlditherrotsub_" )
#     tmpsub1 = "tmp1"
     tmpsub2 = mktemp ( "tmp$_tmp_qlditherrotsub_" )
#     tmpsub2 = "tmp2"
     imglist = imgfiles

     for( i=1; i <= n_files; i+=1 ) {
	if ( int((i-1+n_shift)/n_set) > int((i-1)/n_set) ) {
	   num = i + n_shift - n_set
	} else {
	   num = i + n_shift
        }
	printf("%s\n", filename[num], >> tmpsub1 )
	extsrm( filename[i], ".fits", subext ) | scanf("%s", tmp_fn1 )
	printf("%s_diff%s\n", tmp_fn1, ".fits", >> tmpsub2 )
     }
     flag_exist=no
     list = tmpsub2
     while( fscanf( list, "%s", tmp_fn1 ) != EOF ){
        if ( access( tmp_fn1 ) ) {
	    if ( verbose==yes ) printf("# %s exists.\n", tmp_fn1 )
	    flag_exist=yes
	}
     }
     if ( flag_exist==yes ) {
	error(1, "# Differential files exist. Abort." )
     } else {
        imarith( "@"//imgfiles, "-", "@"//tmpsub1, "@"//tmpsub2, verbose=verbose )
     }

     delete( tmpsub1, ver- )
     delete( tmpsub2, ver-)
     delete( imgfiles, ver-, >& "dev$null" )
     if (verbose == yes ) print("# Done.\n" )

end

# end of the script

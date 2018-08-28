#
#  hnnodsub.cl
#  HONIR nodded spectra subraction
# 
#
#           Ver 1.00 2014/04/07 H.Akitaya
#
#  usage: hnnodsub (images/imga list)
#
#

procedure hnnodsub( in_images )

string in_images { prompt = "Image Name"}
bool hwpchk = no  { prompt = "Grouping with HWP angle ?"}
string se_in = "_fl"
string se_out = "_sk"
string mainext = ".fits"
string outlist=""
bool override = no
bool clean = no

struct *imglist

begin
     string imgfiles, img, fn_in, fn_out, images, img_root, fn_sub
     string hwpangle_str, nodpos, nodpos1, nodpos2
     real hwpangle
     string taskname
     int i,j, n_mainext, counter
     bool pairfound
     real biasval
     bool objsel = no
     bool fltrsel = no
     bool grismsel = no
     string nodpos_array[999], fn_in_array[999], fn_out_array[999]
     real hwpangle_array[999]
     int group[99]
     int nimg, img_group
     int ngroup=1

     taskname="hnnodsub.cl"

     images = in_images
     if( outlist !="" ) {
        if( access( outlist ) ){
	   if( override == no ){
               error(1, "# Old list file "//outlist//" exists. Aborted." )
           }else{
               print( "# Old list file "//outlist//" exists. Override." )
	       delete( outlist, ver- )
        }  }
     }

     print("# "//taskname )

     imgfiles = mktemp ( "tmp$_hntrim_tmp5" )
     sections( images, option="fullname", > imgfiles )

     imglist = imgfiles
     nimg=0
     ngroup=0
     img_group=0
     while( fscan( imglist, img ) != EOF ){
     
        # get rid of the extentions
        extsrm( img, mainext, se_in ) | scanf( "%s", img_root )

	# make file names 
	fn_in = img
	fn_out = img_root//se_out//mainext

	hselect( fn_in, "HWPANGLE", yes ) | scanf( "%s", hwpangle_str )
	hwpangle=real( hwpangle_str )
	hselect( fn_in, "NODPOS", yes ) | scanf( "%s", nodpos )
	fn_in_array[nimg+1] = fn_in
	fn_out_array[nimg+1] = fn_out
	hwpangle_array[nimg+1] = hwpangle
	nodpos_array[nimg+1] = nodpos
	
	if( nimg != 0 ){
	   if( hwpchk== yes && hwpangle != hwpangle_array[nimg] ){
	      group[ngroup+1] = img_group
	      ngroup +=1
	      img_group=0
	   }
        }
	img_group+=1
	nimg += 1
    }
    group[ngroup+1] = img_group
    ngroup +=1
    print( nimg )
    for( i=0; i< nimg; i+=1){
        printf("%s %s %s %5.1f\n", fn_in_array[i+1], fn_out_array[i+1], \
	nodpos_array[i+1], hwpangle_array[i+1] )
    }
    counter=0
    for( i=0; i<ngroup; i+=1){
    	printf("# Group %d, n=%d\n", i, group[i+1] )
    	if( group[i+1] == 1 ){
	    printf("No appropriate nodding pair found. Skip.\n")
	    next
        }
	for( j=0; j< group[i+1]; j+=1 ){
	    fn_in=fn_in_array[counter+j+1]
	    fn_out=fn_out_array[counter+j+1]
            nodpos1 = nodpos_array[counter+j+1]
	    pairfound=no
	    if( (j %2 == 0 ) && (j != (group[i+1]-1)) ) {
                for( k=j; k<group[i+1]; k+=1 ){
	            if( nodpos_array[counter+j+1] != nodpos_array[counter+k+1] ){
	                fn_sub=fn_in_array[counter+k+1]
			nodpos2 = nodpos_array[counter+k+1]
		        pairfound=yes
		        break
                    }
                }
	    }else{
                for( k=j; k>=0; k-=1 ){
	            if( nodpos_array[counter+j+1] != nodpos_array[counter+k+1] ){
	                fn_sub=fn_in_array[counter+k+1]
			nodpos2 = nodpos_array[counter+k+1]
		        pairfound=yes
		        break
                    }
	        }   
	    }
	    if( pairfound==no ){
	        printf("No appropriate nodding pair found. Skip.\n")
	        next
            }else{
	        printf("%s - %s = %s (%s-%s)\n", \
	           fn_in, fn_sub, fn_out, nodpos1, nodpos2 )
	        if( access( fn_out ) && override == no ){
                    printf("Output file %s exists. Skip.\n", fn_out )
                }else{
		    if( access( fn_out ) ){
		    printf("Output file %s exists. Override.\n", fn_out )
                        imdelete( fn_out, ver- )
	   	    }
		    imarith( fn_in, "-", fn_sub, fn_out, ver- )
		    if( outlist != "" )
		    	printf("%s\n", fn_out, >> outlist )
                }
	    }
        }
        counter+=group[i+1]
    }

#	if( clean == yes ){
#         printf("# Deleting origianl file: %s\n", fn_in )
#	  imdelete( fn_in, ver- )
#        }

     # clean up
     delete( imgfiles, ver-, >& "dev$null" )
     printf("# list file : %s\n", outlist )
     print("# Done. ("//taskname//")" )

end

# end of the script

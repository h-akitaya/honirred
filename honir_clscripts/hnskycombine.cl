#
#  hnskycombine.cl
#   sky combine
#
#     Ver 1.00  2013/07/11  H. Akitaya
#     Ver 1.10  2013/07/11  H. Akitaya
#     Ver 1.20  2014/02/08  H. Akitaya
#     Ver 1.21  2014/02/21  H. Akitaya
#     Ver 1.22  2014/03/03  H. Akitaya
#     Ver 1.23  2014/03/04  H. Akitaya
#              hnskycomb -> hnskycombine
#     Ver 1.24  2014/07/29  H. Akitaya
#              temporary file name changed

procedure hnskycombine( in_images, output_fn )

string in_images {prompt = "Input image files"}
string output_fn {prompt = "Output file name"}
#bool objsel = no
string object = ""
#bool fltrsel = no
string filter = ""
real lsigma=2.5
real hsigma=2.5
bool mclip=yes
string combine="median"
bool scale=no
string region="[701:900,701:900]"
#string statsec="701,900:701,900"
bool override = no

struct *imglist

begin

string in_images_, output_fn_, imgfiles, img, skyvalue_fn
string scaled_list_fn, scaled_fn, comblist, matchedlst
string header_obj, header_arm, header_filter
string buf1, buf2
real skyvalue, skyave, skyvalues[999], sky_scale

bool objsel = no
bool fltrsel = no

in_images_ = in_images
output_fn_ = output_fn

print("# hnskycomb.cl" )
if ( object != "" )
    objsel = yes
if ( filter != "" )
    fltrsel = yes

imgfiles = mktemp ( "tmp$tmp_hnskycomb_1_" )
matchedlst = mktemp ( "tmp$tmp_hnskycomb_2_" )
sections( in_images_, option="fullname", > imgfiles )

skyvalue_fn = mktemp ( "tmp$tmp_hnskycomb_3_" )

imglist = imgfiles
i=0
while( fscan( imglist, img ) != EOF ){
    hselect( img, "OBJECT", yes ) | scanf( "%s", header_obj )
    if( objsel == yes && object != header_obj )
          next
    hselect( img, "HN-ARM", yes ) | scanf( "%s", header_arm )
    if( header_arm == "ira" )
       hselect( img, "WH_IRAF2", yes ) | scanf( "%s", header_filter )
    else
       hselect( img, "WH_OPTF2", yes ) | scanf( "%s", header_filter )
    if( fltrsel == yes && filter != header_filter )
       next
    i+=1
    imstatistics( img//region, format-, field="midpt" ) | scanf( "%f", skyvalue )
    printf("# %s %9.2f %5s %s \n", img, skyvalue, header_filter, header_obj )
    printf("%s\n", img, >> matchedlst )
    skyvalues[i]=skyvalue
    printf("%f\n", skyvalue, >> skyvalue_fn )
}

if( i == 0 ) {
    printf( "# No images matched for the requirement. Abort." )
}else{

    type( skyvalue_fn ) | average |  scanf("%f %s %s", \
    skyave, buf1, buf2 )
    printf("# sky average : %f\n", skyave )
    printf("# statistics region : %f\n", region )

    if ( scale == yes ) {
        printf("# combine sky images after scaling\n" )
        scaled_list_fn = mktemp ( "tmp$tmp_hnskycomb_4_" )
        imglist = matchedlst
        i=0
        while( fscan( imglist, img ) != EOF ){
            i+=1
	    sky_scale = skyvalues[i]/skyave
	    scaled_fn = "tmp_hnskycomb_"//img
	    if( access( scaled_fn ) ){
	        imdelete( scaled_fn, ver- )
 	    }
	    imarith( img, "/", sky_scale, scaled_fn, ver- )
	    printf("%s\n", scaled_fn, >> scaled_list_fn )
        }
        comblist = scaled_list_fn
    }else{
        printf("# combine without scaling\n" )
        comblist = matchedlst
    }

    if( access( output_fn_ ) && override == no){
        printf("# Output file %s exists. Skip.\n", output_fn_ )
    }else{
        if( access( output_fn_ ) ){
            printf("# Output file %s exists. Deleting.\n", output_fn_ )
            imdelete( output_fn_, ver- )
        }
        imcombine( "@"//comblist, output_fn_, combine=combine, \
        scale = "none", \
        mclip=mclip, reject="sigclip", lsigma=lsigma, hsigma=hsigma )
    }
}
delete( imgfiles, ver- )
delete( skyvalue_fn, ver- )
delete( matchedlst, ver- )

if ( scale == yes ) {
    imdelete( "@"//scaled_list_fn, ver- )
    delete( scaled_list_fn, ver- )
}
print("# Done. (hnskycomb.cl)" )
#printf( "# Done.\n" )

bye

end

#end

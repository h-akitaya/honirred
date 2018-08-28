#
#  hnmskycomb.cl
#   multiple group sky combine
#
#     Ver 1.00  2013/07/13  H. Akitaya
#

procedure hnmskycomb( in_images, outfn_root, n_ingrp )

string in_images {prompt = "Input image files"}
string outfn_root {prompt = "Root of output file name "}
int n_ingrp {prompt = "Image number in a group"}
real lsigma=2.5
real hsigma=2.5
bool mclip=yes
bool override=yes
bool scale=no
string region="[701:900,701:900]"
int grpno0=1

struct *imglist

begin

string in_images_, outfn_root_, imgfiles, img, grplist_fn, sky_fn
int n_ingrp_, n_img
string buf1, buf2
int grpno
string extstr=".fits"
bool newgrp = yes
in_images_ = in_images
outfn_root_ = outfn_root
n_ingrp_ = n_ingrp

print("# hnmskycomb.cl Ver 1.00" )

imgfiles = mktemp ( "tmp$_hnskycomb_tmp1" )
sections( in_images_, option="fullname", > imgfiles )

imglist = imgfiles

n_img=0
grpno=grpno0-1
while( fscan( imglist, img ) != EOF ){
    n_img+=1
    if( newgrp == yes ){
        grplist_fn =mktemp ( "tmp$_hnskycomb_tmp2" )
	grpno +=1  
	printf( "%s%03d%s\n", outfn_root_, grpno, extstr ) | scanf("%s", sky_fn )
	printf( "New sky group %03d : %s\n", grpno, sky_fn )
	newgrp = no
    }
    printf("%s\n", img, >> grplist )
    printf("%s; %d\n", img, n_img )

    if ( n_img == n_ingrp_ ) {
	print( "########"//n_img )
	n_img=0
	newgrp = yes
        printf("#Combine sky\n" )
	if ( access( sky_fn ) ){
	    print("# Old sky file "//sky_fn//" exists." )
	    if( override == no ) {
                delete( grplist_fn, ver-)
	        print("# Skip.\n" )
		next
            }else{
                printf("# Delete old sky file.\n" )
	        delete( sky_fn, ver- )
	    }
        }
	hnskycomb( "@"//grplist_fn, sky_fn, lsigma=lsigma, hsigma=hsigma, \
		mclip=mclip, scale=scale, region=region )
	hedit( sky_fn, "hnskygrp", grpno, add+, verify-, show- )
        delete( grplist_fn, ver-)
    }
}

if( newgrp == no ){
    printf("Warning: %3d files remained and unused.\n", n_img )
    delete( grplist_fn, ver-)
}

delete( imgfiles, ver- )

print("# Done. (hnmskycomb.cl)" )
#printf( "# Done.\n" )

bye

end

#end

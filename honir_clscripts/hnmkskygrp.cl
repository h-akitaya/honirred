#
#  hnmkskygrp.cl
#   multiple group sky combine
#
#     Ver 1.00  2013/07/13  H. Akitaya
#

procedure hnmkskygrp( in_images, n_ingrp )

string in_images {prompt = "Input image files"}
int n_ingrp {prompt = "Image number in a group"}
bool override=yes
int grpno0=1

struct *imglist

begin

string in_images_, imgfiles, img
int n_ingrp_, n_img
int grpno
string extstr=".fits"
bool newgrp = yes
in_images_ = in_images
n_ingrp_ = n_ingrp

print("# hnmkskygrp.cl Ver 1.00" )

imgfiles = mktemp ( "tmp$_hnskycomb_tmp1" )
sections( in_images_, option="fullname", > imgfiles )

imglist = imgfiles

n_img=0
grpno=grpno0-1
while( fscan( imglist, img ) != EOF ){
    n_img+=1
    if( newgrp == yes ){
	grpno +=1  
	printf( "# New sky group %03d\n", grpno )
        printf("# adding group number header : HNSKYGRP = %d\n", grpno )
	newgrp = no
    }
    printf("%s %d\n", img, n_img )
    hedit( img, "hnskygrp", grpno, add+, verify-, show-)
    if ( n_img == n_ingrp_ ) {
	n_img=0
	newgrp = yes
    }
}

if( newgrp == no ){
    printf("Warning: %3d files surplus.\n", n_img )
}

delete( imgfiles, ver- )

print("# Done. (hnmkskygrp.cl)" )

bye

end

#end

#
#  hnskycomb.cl
#   sky combine
#
#     Ver 1.00  2013/07/11  H. Akitaya
#

procedure hnskycomb( in_images, output_fn )

string in_images {prompt = "Input image files"}
string output_fn {prompt = "Output file name"}
real lsigma=2.5
real hsigma=2.5
bool mclip=yes

#struct *imglist

begin

string in_images_, output_fn_, imgfiles
in_images_ = in_images
output_fn_ = output_fn

print("# hnskycomb.cl Ver 1.00" )

imgfiles = mktemp ( "tmp$_hntrim_tmp5" )
sections( in_images_, option="fullname", > imgfiles )

#imglist = imgfiles

imcombine( "@"//imgfiles, output_fn_, combine="median", mclip=mclip, reject="sigclip", \
	   lsigma=lsigma, hsigma=hsigma )

delete( imgfiles, ver-, >& "dev$null" )
print("# Done. (hnskycomb.cl)" )
#printf( "# Done.\n" )

bye

end

#end


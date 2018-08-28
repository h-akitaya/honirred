#
# extrm.cl
#   remove extentios from the string
#
#     Ver 1.00  2005. 8.10  H. Akitaya
#     Ver 1.01  2013/06/23  H. Akitaya
#

procedure extrm( filename, extension )

string filename {prompt = "file name"}
string extension {prompt = "extension"}

begin

int n_ext, i
string filename_, extension_
filename_=filename
extension_=extension

# get rid of the main extension_s
n_ext = strlen( extension_ )
i = strlen( filename_ )
if( strstr( extension_, filename_) == i-n_ext+1 )
   filename_ = substr( filename_, 1, i-n_ext )

# output
printf( "%s\n", filename_ )

bye

end

#end


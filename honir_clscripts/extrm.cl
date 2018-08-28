#
# extrm.cl
#   remove extentios from the string
#
#     Ver 1.00  2005. 8.10  H. Akitaya
#

procedure extrm( filename, extention )

string filename {prompt = "file name: "}
string extention {prompt = "extention: "}

begin

int n_ext, i

# get rid of the main extentions
n_ext = strlen( extention )
i = strlen( filename )
if( strstr( extention, filename) == i-n_ext+1 )
   filename = substr( filename, 1, i-n_ext )

# output
printf( "%s\n", filename )

bye

end

#end


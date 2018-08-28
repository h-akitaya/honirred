#
# extsrm.cl
#   remove extentios from the string
#
#     Ver 1.00  2005. 8.10  H. Akitaya
#

procedure extsrm( filename, mainext, subext )

string filename {prompt = "file name: "}
string mainext  {prompt = "main extention: "}
string subext   {prompt = "sub extention: "}

begin

# call removeext.cl
extrm( filename, mainext ) | scanf( "%s", filename )
extrm( filename, subext ) | scanf( "%s", filename )

# output
printf( "%s\n", filename )

bye

end

#end


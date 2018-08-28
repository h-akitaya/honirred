#
#  hnmarknod.cl
#
#     Ver 1.00  2014/03/30  H. Akitaya
#

procedure hnmkskygrp( in_images, in_nodpattern )

string in_images {prompt = "Input image files"}
string in_nodpattern {prompt = "nodding pattern" }
struct *imglist

begin

  string images, nodpattern, imgfiles, nodletter, img
  int n_nodptrn, index

  images = in_images
  nodpattern = in_nodpattern

  n_nodptrn = strlen( nodpattern )

  imgfiles = mktemp ( "tmp$_hnmarknod" )
  sections( images, option="fullname", > imgfiles )
  imglist = imgfiles
  index=1
  while( fscan( imglist, img ) != EOF ){
    nodletter = substr( nodpattern, index, index)
    index += 1
    if( index > n_nodptrn )
      index = 1
#    printf("%s : NODPOS = %s\n", img, nodletter)
    hedit( img, "NODPOS", nodletter, add+, verify- )
  }
  delete( imgfiles, ver- )

  print("# Done. (hnmarknod.cl)" )

  bye

end

#end
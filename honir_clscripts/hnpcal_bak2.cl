#
# hnpcal.cl ( from lppcal.cl)
#   HONIR q, u, p, theta quick look script
#         ver 1.0 2014/03/18 H.Akitaya
#
#

procedure hnpcal( input_fn )

file input_fn { prompt = "Image List File Name" }

struct *imglist

# main

begin

  string images, imgfiles, img
  int apnum
  int file_n_q
  int file_n_u
  real file_nsqrt_q
  real file_nsqrt_u
  string dummy

  # to use "sed"
  task sed = "$foreign"

  images = input_fn

  # delete temporary files (before main routine)

  delete( "_pcalql_*", verify- )

  # main routine
  imgfiles = mktemp( "tmp$_hnpcal_tmp" )
  sections( images, option="fullname", > imgfiles )
  imglist = imgfiles
  while( fscan( imglist, img ) != EOF ){
    imgets( img, "APNUM1" )
    printf( "%s\n", imgets.value ) | scanf("%d %s", apnum, dummy )
    printf( "%d\n", apnum )
  }
  

  delete( imgfiles, ver- )
  bye

end	
# end

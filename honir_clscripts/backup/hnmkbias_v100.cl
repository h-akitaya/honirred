# HONIR reduction package
#
#   CCD bias template maker
#
#    hnmkbias.cl
#
#      Ver 1.00 2015/03/11  H. Akitaya


procedure hnmkbias( input_fn, output_fn )

string input_fn {prompt="input files or list"}
string output_fn {prompt="output file name"}

bool override = no   # override old file ?
bool clean = no      # clean-up original raw images?
real lsigma = 2.2
real hsigma = 2.2
struct *imglist

begin

  string input_fn_, output_fn_, imgfiles, biaslist, biasbtlist, img
  string datatyp
  string taskname
  int n_img

  input_fn_ = input_fn
  output_fn_ = output_fn
  n_img = 0

  taskname="hnmkbias.cl"

  printf("# %s\n", taskname )

  if( override == no && access( output_fn_ ) ) {
    error(1, "# "//output_fn_//" exists!!. Abort.")
  }

  imgfiles = mktemp( "tmp$tmp_hnmkbias_" )
  sections( input_fn_, option="fullname", > imgfiles )
  biaslist = mktemp( "tmp$tmp_hnmkbias_" )
  biasbtlist = mktemp( "tmp$tmp_hnmkbias_" )

  imglist=imgfiles
  while( fscan( imglist, img ) != EOF ){
    imgets( img, 'DATA-TYP' )
    datatyp = imgets.value
    if( datatyp == "BIAS" ){
      printf("%s\n", img, >> biaslist )
      printf("Bias image: %s\n", img )
      n_img += 1
    }
  }
  
  if( n_img != 0 ){
    hntrimccd( "@"//biaslist, se_in="", se_out="_bt", outlist=biasbtlist )
    printf( "# Combining (mclip=yes, reject=\"sigclip\", lsig= %5.2f, hsig= %5.2f )", lsigma, hsigma)
    imcombine( "@"//biasbtlist, output_fn_, mclip=yes, reject="sigclip", \
           lsigma=lsigma, hsigma=hsigma )
    if( clean == yes ){
      print("# Deleting original files..." )
      imdelete( "@"//biasbtlist, ver- )
      imdelete( "@"//biaslist, ver- )
    }
    delete( biasbtlist, ver- )
    delete( biaslist, ver- )
  } else {
    print("Bias image not found !!")
  }

  printf("# Finished (%s)\n", taskname )

  bye

end

#end of the script

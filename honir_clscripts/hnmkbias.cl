# HONIR reduction package
#
#   CCD bias template maker
#
#    hnmkbias.cl
#
#      Ver 1.00 2014/03/11  H. Akitaya
#      Ver 1.10 2014/04/10  H. Akitaya : skiptrim, partial mode
#      Ver 1.11 2014/04/14  H. Akitaya : bug fix
#      Ver 1.12 2014/07/29  H. Akitaya : bug fix
#      Ver 1.20 2014/11/19  H. Akitaya : Various partial read mode
#

procedure hnmkbias( input_fn, output_fn )

string input_fn {prompt="input files or list"}
string output_fn {prompt="output file name"}

bool override = no   # override old file ?
bool clean = no      # clean-up original raw images?
bool partial = no {prompt = "partial read image ?"}
bool skiptrim = yes { prompt = "Skip hnccdtrim ?"}
real lsigma = 2.2
real hsigma = 2.2
struct *imglist

begin

  string input_fn_, output_fn_, imgfiles, biaslist, biasbtlist, img
  string datatyp, hnarm, spv, trimed
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

  imgfiles = mktemp( "tmp$tmp_hnmkbias_1_" )
  sections( input_fn_, option="fullname", > imgfiles )
  biaslist = mktemp( "tmp$tmp_hnmkbias_2_" )
  biasbtlist = mktemp( "tmp$tmp_hnmkbias_3_" )

  imglist=imgfiles
  while( fscan( imglist, img ) != EOF ){
    hselect( img, 'DATA-TYP', yes, missing="INDEF" ) | scanf("%s", datatyp )
    hselect( img, 'HN-ARM', yes, missing="INDEF" ) | scanf("%s", hnarm )
    if( datatyp == "BIAS" && hnarm == "opt" ){
      hselect( img, 'SPV', yes, missing="INDEF" ) | scanf("%s", spv )
      if( (spv == "read" && partial == no ) || \
        ( spv != "read" && partial == yes ) ){
          hselect( img, 'HNTRIMC', yes, missing="INDEF" ) | scanf("%s", trimed )
	  if( (trimed=="yes" && skiptrim==yes ) || \
	    (trimed!="yes" && skiptrim==no )){
	      printf("%s\n", img, >> biaslist )
              printf("Bias image: %s\n", img )
              n_img += 1
          }
      }
    }
  }
  if( n_img != 0 ){
    if( skiptrim == no ){
        hntrimccd( "@"//biaslist, se_in="", se_out="_bt", outlist=biasbtlist )
    }else{
        biasbtlist=biaslist
    }
    if( access( output_fn ) ){
      printf("# "//output_fn_//" exists. Override.\n")
      imdelete( output_fn )           	      
    }
    printf( "# Combining (mclip=yes, reject=\"sigclip\", lsig= %5.2f, hsig= %5.2f )", lsigma, hsigma)
    imcombine( "@"//biasbtlist, output_fn_, mclip=yes, reject="sigclip", \
           lsigma=lsigma, hsigma=hsigma )
    if( clean == yes ){
      print("# Deleting original files..." )
      if( skiptrim == no )
          imdelete( "@"//biaslist, ver- )
      imdelete( "@"//biasbtlist, ver- )
    }
    if( skiptrim == no )
        delete( biaslist, ver- )
    delete( biasbtlist, ver- )
  } else {
    print("Bias image not found !!")
  }

  delete( imgfiles, ver- )
  printf("# Finished (%s)\n", taskname )

  bye

end

#end of the script

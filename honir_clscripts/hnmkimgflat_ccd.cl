#
# HONIR reduction package
#
#   CCD imaging flat image maker
#
#    hnmkimgflat_ccd.cl
#
#      Ver 1.00 2013/02/04  H. Akitaya
#      Ver 1.01 2014/07/29  H. Akitaya
#               variable name changed
#

procedure hnmkimgflat_ccd( result_fn, flaton_lst, bias_lst )

string result_fn {prompt="output file name"}
string flaton_lst {prompt="list file name of flat images"}
string bias_lst {prompt="list file name of bias images"}
real replace_upper = 0.2

struct *imglist

begin

string flaton_lst_, bias_lst_, bt_lst, flatlst, aveimg, procname
string flat_on_ave_img,bias_ave_img, tmp_img, result_fn_
string chkreg, taskname, version
string tmpresult_fn
string img
int i, nimg
real ave, stddev

result_fn_ = result_fn
flaton_lst_ = flaton_lst
bias_lst_ = bias_lst

taskname="hnmkimgflat_ccd.cl"
version="1.01"

#result_fn_ = "flat_nrm.fits"
#flaton_lst_="flat_on.lst"
#bias_lst_="bias.lst"
#flataveimg="ave.fits"
bt_lst = "bt.lst"
chkreg="[1056:1060,976:980]"
flat_on_ave_img = mktemp( "tmp$tmp_hnmkimgflat1_" )
bias_ave_img = mktemp( "tmp$tmp_hnmkimgflat2_" )

printf("# %s Ver.%s\n", taskname, version )

if( access( result_fn_ ) ){
  error(1, "# "//result_fn_//" exists!!. Aborted.")
}

for( i=1; i<=2; i+=1){
  if( i== 1){
    aveimg=flat_on_ave_img
    flatlst=flaton_lst_
    procname="Flat(On)"
  }else if( i==2){
    aveimg=bias_ave_img
    flatlst=bias_lst_
    procname="Bias"
  }
  printf("# Starting processing %s...\n", procname )

  hntrimccd( "@"//flatlst )
  
  bt_lst = mktemp( "tmp$tmp_hnmkimgflat5_" )
  sed( 's/.fits/_bt.fits/', flatlst, > bt_lst )
  imglist=bt_lst

  #count check
  tmpresult_fn = mktemp( "tmp$tmp_hnmkimgflat3_" )

  while( fscan( imglist, img ) != EOF ){
     imstatistics( img//chkreg, format-, field="mean", >> tmpresult_fn )
  }

  type( tmpresult_fn ) | average | scanf("%f %f %d", ave, stddev, nimg )
  printf("##### statistics ###############\n")
  printf("# %s\n", procname )
  printf("# number of frames : %d\n", nimg )
  printf("# mean (ADU) : %7.1f\n", ave )
  printf("# stddev (ADU) : %7.1f\n", stddev )
  printf("# fluctuation (percent) : %5.2f\n", stddev/ave*100.0 )
  printf("################################\n")

  # combining
  imcombine( "@"//bt_lst, aveimg, mclip=yes, reject="sigclip", \
  lsig=2.5, hsig=2.5 )
	   
  delete( tmpresult_fn, ver- )
  delete( bt_lst, ver- )
}

# bias subtraction
tmp_img = mktemp( "tmp$tmp_hnmkimgflat4_" )
printf("# Subracting off-flat image ...\n" )
imarith( flat_on_ave_img, "-", bias_ave_img, tmp_img )

imstatistics( tmp_img//chkreg, format-, field="midpt") | scanf( "%f", ave )
printf("# Central region median (ADU) : %10.3f\n", ave )

# normalization
printf("# Normalizing ...\n" )
imarith( tmp_img, "/", ave, result_fn_ )
imreplace( result_fn_, 1.0, lower=INDEF, upper=replace_upper, radius=0 )


imdelete( tmp_img, ver- )
imdelete( flat_on_ave_img, ver- )
imdelete( bias_ave_img, ver- )

printf("# final flat image: %s\n", result_fn_ )
printf("# Finished (%s)\n", taskname )

bye

end

#end of the script

#
# HONIR reduction package
#
#   VIRGO flat image maker
#
#    hnmkflat_virgo.cl
#
#      Ver 1.00 2013/01/17  H. Akitaya
#      Ver 1.10 2013/02/04  H. Akitaya (replacing lower count pixels)
#      Ver 1.20 2013/03/26  H. Akitaya (incl. spectroscopic flat mode)
#
#

procedure hnmkimgflat_virgo( _result_fn, _flaton_lst, _flatoff_lst )

string _result_fn {prompt="output file name"}
string _flaton_lst {prompt="list file name of flat-on images"}
string _flatoff_lst {prompt="list file name of flat-off images"}

real replace_upper = 0.2
string flatmode = "image"

struct *imglist

begin

string flaton_lst, flatoff_lst, bt_lst, flatlst, aveimg, procname
string flat_on_ave_img,flat_off_ave_img, tmp_img, result_fn
string chkreg, taskname, version
string tmpresult_fn
string img
int i, nimg
real ave, stddev

result_fn = _result_fn
flaton_lst=_flaton_lst
flatoff_lst=_flatoff_lst

taskname="hnmkimgflat_virgo.cl"
version="1.10"

#result_fn = "flat_nrm.fits"
#flaton_lst="flat_on.lst"
#flatoff_lst="flat_off.lst"
#flataveimg="ave.fits"
bt_lst = "bt.lst"
flat_on_ave_img = mktemp( "tmp$_hnmkimgflat_tmp" )
flat_off_ave_img = mktemp( "tmp$_hnmkimgflat_tmp" )

printf("# %s Ver.%s\n", taskname, version )

if( flatmode == "irs" ){
    chkreg="[440:444,976:980]"
}else if( flatmode == "irl" ){
    chkreg="[1110:1114,976:980]"
}else if( flatmode == "image" ){
    chkreg="[1056:1060,976:980]"
}else{
    chkreg="[1056:1060,976:980]"
    # imaging mode
}
printf("# %s mode. Noralized at %s.\n", flatmode, chkreg)

if( access( result_fn ) ){
  error(1, "# "//result_fn//" exists!!. Aborted.")
}

for( i=1; i<=2; i+=1){
  if( i== 1){
    aveimg=flat_on_ave_img
    flatlst=flaton_lst
    procname="Flat(On)"
  }else if( i==2){
    aveimg=flat_off_ave_img
    flatlst=flatoff_lst
    procname="Flat(Off)"
  }
  printf("# Starting processing %s...\n", procname )

  hntrimvirgo( "@"//flatlst )
  
  bt_lst = mktemp( "tmp$_hnmkimgflat_tmp" )
  sed( 's/.fits/_bt.fits/', flatlst, > bt_lst )
  imglist=bt_lst

  #count check
  tmpresult_fn = mktemp( "tmp$_hnmkimgflat_tmp" )

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

# dark(off-flat) subtraction
tmp_img = mktemp( "tmp$_hnmkimgflat_tmp" )
printf("# Subracting off-flat image ...\n" )
imarith( flat_on_ave_img, "-", flat_off_ave_img, tmp_img )

imstatistics( tmp_img//chkreg, format-, field="midpt") | scanf( "%f", ave )
printf("# Central region median (ADU) : %10.3f\n", ave )

# normalization
printf("# Normalizing ...\n" )
imarith( tmp_img, "/", ave, result_fn )
imreplace( result_fn, 1.0, lower=INDEF, upper=replace_upper, radius=0 )

imdelete( tmp_img, ver- )
imdelete( flat_on_ave_img, ver- )
imdelete( flat_off_ave_img, ver- )

printf("# final flat image: %s\n", result_fn )
printf("# Finished (%s)\n", taskname )

bye

end

#end of the script
hnmkflat_virgo flat_irs_12.fits flat_irs_12_on.lst flat_irs_12_off.lst replace=0.05 flatmode=irs
##### statistics ###############
# Flat(On)
# number of frames : 23
# mean (ADU) :  3517.9
# stddev (ADU) :     8.9
# fluctuation (percent) :  0.25
################################
##### statistics ###############
# Flat(Off)
# number of frames : 8
# mean (ADU) :    11.9
# stddev (ADU) :     5.3
# fluctuation (percent) : 44.90
################################

hnmkflat_virgo flat_irl_12.fits flat_irl_12_on.lst flat_irl_12_off.lst replace=0.05 flatmode=irl

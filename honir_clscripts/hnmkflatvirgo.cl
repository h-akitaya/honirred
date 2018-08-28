# HONIR reduction package
#
#   VIRGO flat image maker
#
#    hnmkflatvirgo.cl
#
#      Ver 1.00 2013/01/17  H. Akitaya
#      Ver 1.10 2013/02/04  H. Akitaya (replacing lower count pixels)
#      Ver 1.20 2013/03/26  H. Akitaya (incl. spectroscopic flat mode)
#      Ver 1.21 2013/07/23  H. Akitaya (change variable names, task name)
#      Ver 1.22 2014/01/31  H. Akitaya (skiptrim option)
#      Ver 1.23 2014/02/10  H. Akitaya 
#      Ver 1.24 2014/03/03  H. Akitaya 
#      Ver 1.25 2014/11/30  H. Akitaya : normarization option
#
#

procedure hnmkflatvirgo( result_fn, flaton_lst, flatoff_lst )

string result_fn {prompt="output file name"}
string flaton_lst {prompt="list file name of flat-on images"}
string flatoff_lst {prompt="list file name of flat-off images"}

bool skiptrim = no
bool replace = no # replace dark pixel ?
real replace_upper = 0.2 # threshold count for replacing to 1
string flatmode = "image" # image|irs|irl|impol|polirs|polirl|other
string chkreg="[491:540,1185:1234]" # region for normalize
bool override = no # override old file ?
bool clean = no    # clean-up original raw images?
bool calbp = yes
bool sffixpix = yes #
string bpmask = ""            # fixpix bad pixel mask (""-> no processing )
bool normalize = yes
struct *imglist

begin

string flaton_lst_, flatoff_lst_, btlst, flatlst, aveimg, procname
string flat_on_ave_img,flat_off_ave_img, tmp_img, result_fn_
string taskname
string tmpresult_fn
string img
int i, nimg
real ave, stddev

result_fn_ = result_fn
flaton_lst_ = flaton_lst
flatoff_lst_ = flatoff_lst

taskname="hnmkflatvirgo.cl"

#btlst = "bt.lst"
flat_on_ave_img = mktemp( "tmp$_hnmkflatvirgo_tmp_on" )
flat_off_ave_img = mktemp( "tmp$_hnmkflatvirgo_tmp_off" )

printf("# %s\n", taskname )

if( override == no && access( result_fn_ ) ) {
  error(1, "# "//result_fn_//" exists!!. Abort.")
}

if( flatmode == "irs" ){
    chkreg="[440:444,976:980]"
}else if( flatmode == "irl" ){
    chkreg="[1110:1114,976:980]"
}else if( flatmode == "image" ){
    chkreg="[1056:1060,976:980]"
}else if( flatmode == "impol" ){
    chkreg="[901:950,901:950]"
}else if( flatmode == "polirl" ){
    chkreg="[901:950,1131:1180]"
}else if( flatmode == "polirs" ){
    chkreg="[491:540,1185:1234]"
}else if( flatmode == "other" ){
    chkreg = chkreg
}else {
    chkreg="[1056:1060,976:980]"
    # imaging mode
}
printf("# %s mode. Noralized at %s.\n", flatmode, chkreg)

for( i=1; i<=2; i+=1){
  flatlst = mktemp( "tmp$_hnmkflatvirgo_tmp_fltl" )
  btlst = mktemp( "tmp$_hnmkflatvirgo_tmp1" )
 if( i == 1 ){
    aveimg=flat_on_ave_img
    sections( flaton_lst_, option="fullname", > flatlst )
    procname="Flat(On)"
  } else if( i==2 ){
    aveimg=flat_off_ave_img
    sections( flatoff_lst_, option="fullname", > flatlst )
    procname="Flat(Off)"
  }
  printf("# Starting processing %s...\n", procname )

  if ( skiptrim == no ) {
    hntrimvirgo( "@"//flatlst, outlist=btlst )
    if( clean == yes ) {
    print("# Deleting original files..." )
    imdelete( "@"//flatlst, ver- )
    }
  } else {
    type( flatlst, > btlst )
  }

  list=btlst

  #count check
  tmpresult_fn = mktemp( "tmp$_hnmkflatvirgo_tmp" )

  while( fscan( list, img ) != EOF ){
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
  print( "# Combining (mclip=yes, reject=\"sigclip\", lsig=2.5, hsig=2.5)")
  imcombine( "@"//btlst, aveimg, mclip=yes, reject="sigclip", \
         lsig=2.5, hsig=2.5 )
  if( clean == yes ){
     print("# Deleting original files..." )
     imdelete( "@"//btlst, ver- )
  }
	   
  delete( tmpresult_fn, ver- )
  delete( btlst, ver- )
  delete( flatlst, ver- )
}

# dark(off-flat) subtraction
tmp_img = mktemp( "tmp$_hnmkflatvirgo_tmp" )
printf("# Subracting off-flat image ...\n" )
imarith( flat_on_ave_img, "-", flat_off_ave_img, tmp_img )

imstatistics( tmp_img//chkreg, format-, field="midpt") | scanf( "%f", ave )
printf("# Central region median (ADU) : %10.3f\n", ave )

# normalization
if ( access( result_fn_ ) ){
   printf( "# File %s exists. Deleting.\n", result_fn_ )
   imdelete( result_fn_, ver- )
}
if ( normalize == yes ){
  printf("# Normalizing ...\n" )
  imarith( tmp_img, "/", ave, result_fn_ )
  if( replace == yes ){
     printf("# Replacing dark pixels (<%6.2f) into 1\n", replace_upper )
     imreplace( result_fn_, 1.0, lower=INDEF, upper=replace_upper, radius=0 )
  }
}else{
  printf("# NOT normalizing\n" )
  imcopy( tmp_img, result_fn )
}

if( calbp == yes ){
    print("# bad pixel fixing ...\n" )
    hnbpfixvirgo( result_fn_, se_in="", se_out="", objsel-, fltrsel-, \
    calbp+, calds-, dsmask="", sffixpix=sffixpix, over+ )
}else if( bpmask != "" ){
    print("# bad pixel fixing ...\n" )
    hnbpfixvirgo( result_fn_, se_in="", se_out="", objsel-, fltrsel-, \
    calbp-, bpmask=bpmask, calds-, dsmask="", sffixpix=sffixpix, over+ )
}

imdelete( tmp_img, ver- )
imdelete( flat_on_ave_img, ver- )
imdelete( flat_off_ave_img, ver- )

printf("# final flat image: %s\n", result_fn_ )
printf("# Finished (%s)\n", taskname )

bye

end

#end of the script

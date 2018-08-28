#
# HONIR reduction package
#
#   VIRGO dark image processing 
#
#    hnmkdarkvirgo.cl
#
#      Ver 1.00 2013/07/23  H. Akitaya
#
#

procedure hnmkdarkvirgo( in_images, dark_fn )

string in_images {prompt="Input image names or list"}
string dark_fn {prompt="Output dark image name"}

bool dksel = no          # auto selection for "DATA-TYP = DARK"
bool etsel = no          # exposure time selection mode 
real expt_select = 0.0    # exposure time for selection
string reject = "sigclip"
bool mclip = yes 
real lsigma = 2.5 {prompt = "Lower sigma clipping factor for imcombine" }
real hsigma = 2.5 {prompt = "Upper sigma clipping factor for imcombine" }
string darklst = ""
bool override = no
string chkreg="[440:444,976:980]"

struct *imglist

begin

string images, dark_fn_, imgfiles, tmpresult, img
string flat_on_ave_img,flat_off_ave_img, tmp_img, result_fn_, comblst
string selection_flg, datatyp
string taskname, version
int nimg
real ave, stddev, exptime, exptime_before
bool chk1stloop
bool uniform_expt = yes

nimg = 0

images = in_images
dark_fn_ = dark_fn

taskname="hnmkdarkvirgo.cl"
version="1.00"

printf("# %s Ver.%s\n", taskname, version )

if( access( dark_fn_ ) ){
  print("# "//dark_fn_//" exists!!.")
  if ( override == no ) {
     error(1, "# Abort." )
  } else {
     print("# Delete old dark file." )
     imdelete( dark_fn_, ver- )
  }
}

imgfiles= mktemp( "tmp$tmp_hnmkdarkvirgo_1" )
tmpresult= mktemp( "tmp$tmp_hnmkdarkvirgo_2" )
comblst= mktemp( "tmp$tmp_hnmkdarkvirgo_3" )
sections( images, option="fullname", > imgfiles )
imglist = imgfiles

chk1stloop = yes
printf("# Image name          Exp. Time (s)\n")
while( fscan( imglist, img ) != EOF ){
  hselect( img, "DATA-TYP", yes ) | scanf("%s", datatyp )
  hselect( img, "EXPTIME0", yes ) | scanf("%f", exptime )
  if( etsel == yes && exptime != expt_select )
    selection_flg = "ignored"
  else
    selection_flg = "ok"
  if( dksel == yes && datatyp != "DARK" )
    selection_flg = "ignored"
  printf("# %20s %7.3f %9s %s\n", img, exptime, selection_flg, datatyp )
  if( selection_flg == "ignored" )
    next

  if( chk1stloop == yes ){
     chk1stloop = no
  } else {
     if( exptime_before != exptime ) uniform_expt = no
  }
  imstatistics( img//chkreg, format-, field="mean", >> tmpresult )
  print( img, >> comblst )
  exptime_before = exptime
  nimg += 1
}

if( nimg == 0 ){
    printf("# No images with %7.2f s exposure selected. Abort.\n",\
    expt_select )
    bye
}

type( tmpresult ) | average | scanf("%f %f %d", ave, stddev, nimg )
printf("##### statistics ###############\n")
printf("# number of frames : %d\n", nimg )
printf("# mean (ADU) : %7.1f\n", ave )
printf("# stddev (ADU) : %7.1f\n", stddev )
printf("# fluctuation (percent) : %5.2f\n", stddev/ave*100.0 )
printf("################################\n")

# combining
imcombine( "@"//comblst, dark_fn_, mclip=mclip, reject=reject, \
lsig=lsig, hsig=hsig )

printf("# final dark image: %s\n", dark_fn_ )
if( uniform_expt == no ){
  printf("# Warning ! Including Different exposure time images !!\n" )
} else {
  printf("# Exposure time : %8.3f\n", exptime )
}
if ( darklst != "" ) {
  printf("%s\n", dark_fn, >> darklst )
}

printf("# Finished (%s)\n", taskname )

delete( imgfiles, ver- )
delete( tmpresult, ver- )
delete( comblst, ver- )

bye

end

#end of the script

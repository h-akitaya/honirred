# HONIR reduction package
#
#   CCD polarimetry flat image maker
#
#    hnmkpflccd.cl
#    based on hnmkpflvirgo.cl
#
#        Ver 1.0  2019/12/10 H.Akitaya
#

procedure hnmkpflccd(input_fn, output_fn)

string input_fn {prompt = "Input files or list" }
string output_fn {prompt = "Output file name" }
string flatmode = "impol" {prompt = "impol|specpol"}
string chkreg="[1241:1300,1001:1400]"  # region for normalize
string filter = "" {prompt="filter"}

bool clean = no
bool override = no

bool replace = no # replace dark pixel ?
real replace_upper = 0.2 # threshold count for replacing to 1
bool normalize = yes
bool offhwpzero = no

struct *imglist

begin

  string taskname
  string input_fn_, output_fn_, obsmode, filelist_all
  string flaton_fn, bias_fn, flatfn_eachhwp[4], hwpflatlst
  string hwpflatcomb_fn, grism, tmpstr
  real hwppa[4], ave, hwppatmp
  int n_hwppa

  input_fn_ = input_fn
  output_fn_ = output_fn
  n_hwppa=4

  hwppa[1]= 0.0
  hwppa[2]=22.5
  hwppa[3]=45.0
  hwppa[4]=67.5
  
  taskname="hnmkpflccd.cl"

  printf("# %s\n", taskname )

  if( override == no && access( output_fn_ ) ) {
    error(1, "# "//output_fn_//" exists!!. Abort.")
  }

  grism = ""
  if( flatmode == "impol" ){
    chkreg="[1241:1300,1001:1400]" # region for normalize
    obsmode = "ImPol"
  }else if( flatmode == "specpol" ){
    chkreg="[1131:1180,871:970]" # TBD at 2019/12/10
    obsmode = "SpecPol"
    grism="grism Opt"
  }else {
    chkreg="[1241:1300,1001:1400]" # same as "ImPol"
    obsmode = "ImPol"
  }

  printf("# %s mode. Noralized at %s.\n", flatmode, chkreg)
  
  filelist_all = mktemp( "tmp$hnhn1" )
  sections( input_fn_, option="fullname", > filelist_all )
  
  hwpflatlst = mktemp( "tmp$hnhn5" )

  for( i=1; i<= n_hwppa; i=i+1 ){
    printf( "# HWPANGLE = %5.1f\n", hwppa[i] )
    flaton_fn = mktemp( "tmp$hnhn2" )
    bias_fn = mktemp( "tmp$hnhn3" )
#    flatfn_eachhwp[i] = mktemp( "tmp$hnhn4" )//".fits"
    
    # printf("%03d\n", hwppa[i]*10.0 )  # | scanf( "%s", tmpstr )
    tmpstr = str(hwppa[i]*10.0 )
    flatfn_eachhwp[i] = "flat_"//filter//"_"//tmpstr//".fits"
    print( flatfn_eachhwp[i], >> hwpflatlst )
    if ( grism == "" ){
      hselect( "@"//filelist_all, "$I", '@"data-typ"=="DOMEFLAT" && @"WH_OPTF2"=="'//filter//'" && @"OBS-MODE"=="'//obsmode//'" && @"HWPANGLE"=='//hwppa[i], > flaton_fn )
    }else{
      hselect( "@"//filelist_all, "$I", '@"data-typ"=="DOMEFLAT" && @"WH_OPTF2"=="'//filter//'" && @"WH_IRAF1"=="'//grism//'" && @"OBS-MODE"=="'//obsmode//'" && @"HWPANGLE"=='//hwppa[i], > flaton_fn )
    }
    if ( offhwpzero == yes ){
      hwppatmp=0.0
    }else{
      hwppatmp=hwppa[i]
    }
    hselect( "@"//filelist_all, "$I", '@"data-typ"=="BIAS"', > bias_fn )

    hnmkimgflat_ccd( flatfn_eachhwp[i] , "@"//flaton_fn, "@"//bias_fn, \
      replace_upper = replace_upper)
    delete( flaton_fn, ver- )
    delete( bias_fn, ver- )
  }
  
  hwpflatcomb_fn = mktemp( "tmp$hnhnmkpflccd_tmp_6" )//".fits"
  imcombine( "@"//hwpflatlst, hwpflatcomb_fn, reject- )
      
#  imstatistics( hwpflatcomb_fn//chkreg, format-, \
#    field="midpt") | scanf( "%f", ave )
#  printf("# Central region %s median (ADU) : %10.3f\n", chkreg, ave )

  # normalization
  if ( access( output_fn_ ) ){
     printf( "# File %s exists. Deleting.\n", output_fn_ )
     imdelete( output_fn_, ver- )
  }

  printf("# Normalizing ...\n" )
  if ( normalize == yes ){
    imarith( hwpflatcomb_fn, "/", ave, output_fn_ )
    if( replace == yes ){
       printf("# Replacing dark pixels (<%6.2f) into 1\n", replace_upper )
       imreplace( output_fn_, 1.0, lower=INDEF, upper=replace_upper, radius=0 )
    }
  }else{
    imcopy( hwpflatcomb_fn, output_fn_ )
  }

  delete( filelist_all, ver- )
  imdelete( hwpflatcomb_fn, ver- )
#  imdelete( "@"//hwpflatlst, ver- )
  delete( hwpflatlst, ver- )
  printf( "# Result flat file : %s\n", output_fn_ )
      
  print "# Done("//taskname//")"
bye
  
end

#end of the script



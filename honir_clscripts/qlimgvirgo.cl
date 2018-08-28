#
#  qlimgvirgo.cl
#  HONIR Virgo image quick look
#
#           Ver 1.00 2013/01/26 H.Akitaya
#           Ver 1.01 2014/02/10 H.Akitaya
#                    bad pix fix function
#           Ver 1.10 2014/03/09 H.Akitaya
#
#
#  usage: qlimgvirgo
#

procedure qlimgvirgo( in_image )

string in_image { prompt = "Image Name"}
string fn_dark = "clscript_dir$darktemplate201301.fits"
string fn_flat = "clscript_dir$flattemplate_H_201301.fits"
string fn_bpmask = "clscript_dir$bpm_20140130.pl"
string file_out = "test_ql.fits"
string obsrun="201402a"
bool flat = no
bool ds9 = no
bool bpfix = no
bool sffix = yes

begin

  string file_in, mainext, se_in, se_out, img_root, fn_out_trim, img
  string basedir, tmp_file, dscr

  mainext=".fits"
  se_in=""
  se_out="_btx"

  img = in_image

  if( access( file_out ) ){
    print( "# Deleting old file..." )
    imdelete( file_out, ver- )
  }
  if( ! access( img ) ){

    error(1, "# File "//img//" not found !" )
  }

#  honirini( obsrun )

  extsrm( img, mainext, se_in ) | scanf( "%s", img_root )
  fn_out_trim = img_root//se_out//mainext

  if( access( fn_out_trim ) ){
    print( "# Deleting old file..." )
    imdelete( fn_out_trim, ver- )
  }

  hntrimvirgo( img, se_in="", se_out="_btx", >& "dev$null" )

  
  if (flat == yes ){
     tmp_file = mktemp("tmp$_qlimgvirgo_")
     imarith( fn_out_trim, "-", fn_dark, tmp_file )    
     imarith( tmp_file, "/", fn_flat, file_out )
     imdelete( tmp_file, ver- )
     dscr="dark subtracted, flattened"
  } else {
     imarith( fn_out_trim, "-", fn_dark, file_out )
     dscr="dark subtracted"
  }
  if( bpfix == yes){
     hnbpfixvirgo( file_out, over+, se_in="", se_out="", sffix+, calbp+, \
	calds+, objsel-, fltrsel-, dsall+ ,>& "dev$null" )
#     fixpix( file_out, fn_bpmask, verbose-, pixels-, sffix+, calbp+, calds+  )
     dscr=dscr//", bad pix fixed"
  }
  # clean up
  imdelete( fn_out_trim, ver-, >& "dev$null" )

  print("# Quick look image "//file_out//" ("//dscr//") created.")
  if (ds9 == yes ){
	xpaset( "-p ds9 frame 5" )
	xpaset( "-p ds9 file", file_out )  
  }
  print("# Done." )


end

# end of the script

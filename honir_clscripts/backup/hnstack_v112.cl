#
#  hnstack.cl
#  HONIR stacking ditherd images
#
#           Ver 1.00 2014/02/07 H.Akitaya
#           Ver 1.01 2014/02/08 H.Akitaya
#           Ver 1.10 2014/03/03 H.Akitaya
#           Ver 1.11 2014/04/14 H.Akitaya : remove objsel, fltrsel params.
#           Ver 1.12 2014/07/29 H.Akitaya
#
#  usage: hnstack (images/list) 
#

procedure hnstack( in_images, output_fn )

string in_images { prompt = "Image Name" }
string output_fn { prompt = "Output Image Name" }
string shiftfn = ""          # coordinate shift file
string reffn = ""
bool preserve = no
#bool objsel = no
string object = ""
#bool fltrsel = no
string filter = ""
string se_in = "_sk"
string se_out = "_tr"
string mainext = ".fits"
real boxsize=25
real bigbox=31
real lsigma=2.5 # lsimga for stacking imcombine
real hsigma=1.5 # hsimga for stacking imcombine
bool override = yes        # override results?

struct *imglist
#imcur *imagecurs

begin

string imgfiles, imgfiles_out, img, fn_in, fn_out, in_images_, img_root
string taskname, buf1, sky_temp, tmp_offset, tmp_coord, imcur_fn, matchedlst
string header_obj, header_arm, header_filter
string key
struct command
real sky_object, sky_template, sky_scale, x_star, y_star, wcs
real ora, odec, ora0, odec0, off_x, off_y
int grpno, nimg
real x_cur, y_cur
bool objsel = no
bool fltrsel = no

bool first_loop = yes
real pixscale = 0.3
in_images_ = in_images

# welcome message
taskname="hnstack.cl"

if ( object != "" )
    objsel = yes
if ( filter != "" )
    fltrsel = yes

print("# "//taskname )

# checking required files
if( shiftfn != "" ) {
    if( !access( shiftfn ) ){
        error(1, "# Coordinate shift file "//shiftfn//" not found. Aborted." )
    }
}
if( reffn != "" ) {
    if( !access( reffn ) ){
        error(1, "# Reference image "//reffn//" not found. Aborted." )
    }
}

# analyzing the input file names or list
imgfiles = mktemp ( "tmp$tmp_hnstack_1_" )
imgfiles_out = mktemp ( "tmp$tmp_hnstack_2_" )
matchedlst = mktemp ( "tmp$tmp_hnstack_3_" )
sections( in_images_, option="fullname", > imgfiles )
imglist = imgfiles

tmp_offset = mktemp ( "tmp$tmp_hnstack_4_" )
tmp_coord = mktemp ( "tmp$tmp_hnstack_5_" )

# main loop (for each file)

nimg=0
while( fscan( imglist, img ) != EOF ){
    
    # get rid of the extentions
    extsrm( img, mainext, se_in ) | scanf( "%s", img_root )

    # make file names 
    fn_in = img_root//se_in//mainext
    fn_out = img_root//se_out//mainext
    hselect( fn_in, "OBJECT", yes ) | scanf( "%s", header_obj )
    if( objsel == yes && object != header_obj )
           next
    hselect( fn_in, "HN-ARM", yes ) | scanf( "%s", header_arm )
    if( header_arm == "ira" )
        hselect( fn_in, "WH_IRAF2", yes ) | scanf( "%s", header_filter )
    else
        hselect( fn_in, "WH_OPTF2", yes ) | scanf( "%s", header_filter )
    if ( fltrsel == yes && filter != header_filter )
        next

    nimg += 1
    print( fn_in, >> matchedlst )
    if( first_loop == yes ) {
         first_loop = no
         if( reffn == ""){
             reffn = fn_in
         }
	 print( osfn( fn_in ) )
#         xpaset("-p", "ds9", "file", osfn( "."//fn_in ) )
         display( fn_in, 1, fill+, zscale-, zrange-)
	 printf("# mark the reference stars (m: mark, q: quit ) :\n")
	 while( fscan(imcur, x, y, wcs, command )!= EOF ) {
	 　　key = substr( command, 1, 1)
	     if (key == "m" ) {
                 print( x, y )
		 printf("%9.4f %9.4f\n", x, y, >> tmp_coord )
             }
	     else if ( key == "q" )
                 break
         }
#	 delete( imcur_fn, ver- )
         hselect( fn_in, "ORA-STR", yes ) | scanf( "%f", ora0 )
         hselect( fn_in, "ODEC-STR", yes ) | scanf( "%f", odec0 )
     }
     hselect( fn_in, "ORA-STR", yes ) | scanf( "%f", ora )
     hselect( fn_in, "ODEC-STR", yes ) | scanf( "%f", odec )

     if( header_arm == "ira" ) {            #IRA (VIRGO)
        off_x = (odec-odec0)/pixscale
        off_y = (-1.0)*(ora-ora0)/pixscale
     } else if( header_arm == "opt" ) {     # CCD
        off_x = (ora-ora0)/pixscale
        off_y = (odec-odec0)/pixscale
     } else {                               # CCD
        off_x = (ora-ora0)/pixscale
        off_y = (odec-odec0)/pixscale
     }

     printf("%9.3f %9.3f\n", off_x, off_y, >> tmp_offset )
     printf("%s %9.3f %9.3f %s %s \n", fn_in, off_x, off_y, \
     		header_filter, header_obj )
     print( fn_out, >> imgfiles_out )
}

# clean up

if ( nimg != 0 ){
    if( override == yes )
        imdelete( "@"//imgfiles_out, ver- )
    imalign( "@"//matchedlst, reffn, tmp_coord, "@"//imgfiles_out, \
   	    shifts=tmp_offset, boxsize=boxsize, bigbox=bigbox,\
	     negative=no  )
    if( output_fn != "" ) {
        imcombine( "@"//imgfiles_out, output_fn, mclip+, combine="sum", \
	reject="avsigclip", lsigma=lsigma, hsigma=hsigma )
    }
    if( preserve == no )
        imdelete( "@"//imgfiles_out, ver- )
}
delete( imgfiles, ver-, >& "dev$null" )
delete( imgfiles_out, ver-, >& "dev$null" )
delete( tmp_offset, ver-, >& "dev$null" )
delete( tmp_coord, ver-, >& "dev$null" )
delete( matchedlst, ver-, >& "dev$null" )

print("# Done. ("//taskname//")" )

bye
end

# end of the script

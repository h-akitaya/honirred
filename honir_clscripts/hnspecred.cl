#
#   HONIR Spectrum extraction
#
#           Ver 1.00 2013/06/24 H.Akitaya
#
#  Usage: hnspecred
#

procedure hnspecred ( in_images, sky_images )

string in_images { prompt = "Images or List" }
string sky_images { prompt = "Sky Images or List" }
string wltemplate = ""
string bpmask_fn = ""
string dark_fn = ""
string flat_fn = ""
bool interactive=yes
bool review=yes

struct *imglist
struct *skyimglist



begin

#### variable declarations (begin)
#
string in_images_, sky_images_, in_images_lst, sky_images_lst
string img_fn, sky_fn, img_diff, img_diff_fl, 
       sky_dk, sky_fl, img_fn_root
int n_in_images, n_sky_images, stat_fscan
#
##### variable declarations (end)

in_images_ = in_images
sky_images_ = sky_images


# some initialization processes
onedspec.dispaxis=1

in_images_lst = mktemp ( "tmp$_tmp_hnspec_" )
sky_images_lst = mktemp ( "tmp$_tmp_hnspec_" )
sections( in_images_, option="fullname", > in_images_lst )
type( in_images_lst )
n_in_images= sections.nimages
sections( sky_images_, option="fullname", > sky_images_lst )
n_sky_images= sections.nimages
if ( n_in_images != n_sky_images ) \
error(1, "# Numbers of images and sky images differs! Abort." )
if ( !access( wltemplate ) ) \
error(1, "# Wavelength template file "//wltemplate//" not found! Abort." )

print("# hnspecred" )

imglist = in_images_lst
skyimglist = sky_images_lst

while( fscan( imglist, img_fn ) != EOF ){
    extrm( img_fn, ".fits" ) | scanf("%s", img_fn_root )
    print( "#fn ="//img_fn//"\n" )
    stat_fscan = fscan( skyimglist, sky_fn )
    if ( !access( img_fn ) ){
    print("# Image file "//img_fn//" not found! Skip." )
    next
    }
    if ( !access( sky_fn ) ){
    print("# Sky Image file "//sky_fn//" not found! Skip." )
    next
    }
#    img_diff = mktemp ( "tmp$_tmp_hnspec_" )
    img_diff = img_fn_root//"_diff.fits"
    if ( access( img_diff ) ) imdelete( img_diff, ver- )
#    img_diff_fl = mktemp ( "tmp$_tmp_hnspec_" )
    img_diff_fl = img_fn_root//"_diff_fl.fits"
    if ( access( img_diff_fl ) ) imdelete( img_diff_fl, ver- )
#    sky_dk = mktemp ( "tmp$_tmp_hnspec_" )
    sky_dk = img_fn_root//"_sky_dk.fits"
    if ( access( sky_dk ) ) imdelete( sky_dk, ver- )
#    sky_fl = mktemp ( "tmp$_tmp_hnspec_" )
    sky_fl = img_fn_root//"_sky_fl.fits"
    if ( access( sky_fl ) ) imdelete( sky_fl, ver- )

    #
    # Extraction object spectrum
    #      
    # make differential images
    imarith ( img_fn, "-", sky_fn, img_diff, verbose- )

    # flattening
    if ( access( flat_fn ) ) {
        imarith( img_diff, "/", flat_fn, img_diff_fl, verbose- )
    } else {
        print("# Flat file "//flat_fn//" not found. Skip flattening\n" )
	imcopy( img_diff, img_diff_fl, verbose- )
    }
    # extract spectrum

    # bad pix mask
    if ( access( bpmask_fn ) ) {
        fixpix( img_diff_fl, bpmask_fn, verbose- )
    } else {
        print("# bad pixel file "//bpmask_fn//" not found. Skip fixpix.\n" )
    }
    # extract spectrum    

    print("Select aperture and extract a spectrum.\n" )
    if ( access( img_fn_root//".ms.fits" )) \
        imdelete( img_fn_root//".ms.fits" )
    apall( img_diff_fl, output=img_fn_root//".ms.fits", \
        interactive=interactive, find+, recenter+, resize+, edit+, trace+,\
	fittrace+, extract+, extras+, review=review )
    #
    # Processing sky emission images and wavelength identification
    #      

    # dark subtraction
    if ( access( dark_fn ) ) {
        imarith ( sky_fn, "-", dark_fn, sky_dk, verbose- )
    } else {
        printf("# Dark image "//dark_fn//" not found. " )
        printf("Skip dark subtraction.\n" )
        imcopy ( sky_fn, sky_dk, verbose- )
    }
    # flattening
    if ( access( flat_fn ) ) {
        imarith( sky_dk, "/", flat_fn, sky_fl, verbose- )
    } else {
        print("# Flat file "//flat_fn//" not found. Skip flattening\n" )
	imcopy( sky_dk, sky_fl, verbose- )
    }
    # bad pix mask
    if ( !access( bpmask_fn ) ) {
        print("# bad pixel file "//bpmask_fn//" not found. " )
	print("Skip fixpix.\n" )
    } else {
        fixpix( sky_fl, bpmask_fn, verbose- )
	# 
    }

    # spectrum extraction
    printf("Select aperture and extract a spectrum.\n" )
    if ( access( img_fn_root//"_sky.ms.fits" )) \
        imdelete( img_fn_root//"_sky.ms.fits" )
    apall( sky_fl, output=img_fn_root//"_sky.ms.fits", ref=img_diff_fl, \
       recenter-, trace-, back-, inter-, resize-, edit-, review=review )

    if( access( wltemplate ) ){
        printf("# Reidentify emission lines: " )
        printf("template = "//wltemplate//".\n" )
        reidentify( wltemplate, img_fn_root//"_sky.ms.fits",newaps-, override-,\
            refit+, addfeature-, maxfeatures=15 )
    } else {
        printf("# Identify emission lines manually.\n" )
        identify( img_fn_root//"_sky.ms" )
    }

    # Walelength coordinate allocation

    hedit ( img_fn_root//".ms", "REFSPEC1", img_fn_root//"_sky.ms", add+, ver- )
    if ( access( img_fn_root//".dc.fits" )) \
        imdelete( img_fn_root//".dc.fits" )
    dispcor( img_fn_root//".ms", img_fn_root//".dc" )
    # 

    # Erace temporary files
    imdelete( img_diff, verify- )
    imdelete( img_diff_fl, verify- )
    imdelete( sky_dk, verify- )
    imdelete( sky_fl, verify- )
}


#delete( imgfiles, ver-, >& "dev$null" )
print("# Done.\n" )

end

# end of the script

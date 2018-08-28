#
# erasecosray.cl
#
#   Ver 1.0 2014/07/17 H. Akitaya
#   Ver 1.1 2014/08/01 H. Akitaya
#   Ver 1.2 2014/08/01 H. Akitaya : bug fix
#
#

procedure erasecosray( in_images )

# parameters

string in_images { prompt = "Input file name"}
#string fn_out = "" { prompt = "Output file name"}
real threshold { prompt = "Background threshold" }
string region { prompt = "Region" }
bool override = no { prompt = "Override mode" }
bool interactive = no {prompt = "Interactive mode" }
string se_in = ""
string se_out = "_cr"
string mainext = ".fits"
struct *imglist

begin

# variables 

string tmpfile0, tmpfile1, tmpfile2, tmpfile3, dummy, fn_in, fn_out, fn_in_root
string imgfiles, images
real bgfluc
bool again = no
bool skip = yes
threshold.p_value = 0.0

# main routine

images = in_images
imgfiles = mktemp ( "tmp$tmp_erasecosray4" )
sections( images, option="fullname", > imgfiles )

imglist=imgfiles

while( fscan( imglist, fn_in) != EOF) {
    
    # get rid of the extentions
    extsrm( fn_in, mainext, se_in ) | scanf( "%s", fn_in_root )
    # make file names 
    fn_out = fn_in_root//se_out//mainext
 
    if( !access( fn_in ) ){
    error( 1, "File "//fn_in//" not found !!" )
    }
    if ( access( fn_out ) && override == no ){
    error( 1, "# Output file "//fn_out//" exists. Abort" )
    }

    tmpfile0 = mktemp( "tmp$tmp_erasecosray0" )//".fits"
    tmpfile1 = mktemp( "tmp$tmp_erasecosray1" )//".fits"
    tmpfile2 = mktemp( "tmp$tmp_erasecosray2" )//".fits"
    tmpfile3 = mktemp( "tmp$tmp_erasecosray3" )//".fits"

    imcopy( fn_in, tmpfile0, ver- )

    print "Display "//fn_in

    while(yes){
        if( interactive == yes ){
            simg( osfn(tmpfile0) )
            print "Click region corners ( 2 points )"
            getregion | scanf( "%s", region )
	    imstatistics( tmpfile0//region, format-, field="midpt" ) | scanf("%f", bgfluc )
            printf( "# Region: %s\n", region )
            printf( "# Median of the region: %7.2f\n", bgfluc )
            printf( "Background threshold ( %6.4f ) ?", threshold )
	    scanf( "%s", s1 )
	    if( s1 != "" )
	    	threshold = real( s1 )
	    printf( "Threshold = %6.4f\n", threshold )
        }
	    
	imcopy( tmpfile0, tmpfile1, ver- )
	imcopy( tmpfile0, tmpfile3, ver- )
	imreplace( tmpfile1//region, 0.0 )
	imarith( tmpfile0, "-", tmpfile1, tmpfile2, ver- )
	imreplace( tmpfile2, 0.0, upper=threshold, lower=INDEF )

	hnbpfix( osfn(tmpfile3), sffixpix+, calbp-, calds-, dsall-, \
		 bpmask=osfn(tmpfile2), \
		 dsmask="", objsel-, fltrsel-, se_in="", se_out="", \
		 outlist="",\
		 mainext=".fits", over+ )
        imdelete( tmpfile1, ver- )
	imdelete( tmpfile2, ver- )

	if( interactive == yes ){
	    simg( osfn(tmpfile3) )
	    printf "Command? (y:OK, a:Addition, s:Skip, q:Quit, others:Undo) : "
	    scanf("%s", s1 )
	    if( s1 == "y"){
	    	skip=no
		break
	    }else if( s1 == "s" ){
	    	skip=yes
	        break
	    } else if ( s1 == "a" ){
	        again = yes
                imdelete( tmpfile0, ver- )
		imcopy( tmpfile3, tmpfile0, ver- )
	    } else if ( s1 == "q" ){
                imdelete( tmpfile0, ver- )
                imdelete( tmpfile3, ver- )
                delete( imgfiles, ver- )
                print "Quit !!"
		bye
	    } else {
	        again = yes
            }
        }
	imdelete( tmpfile3, ver- )
    }

    if( skip == no ){
        if ( access( fn_out ) ){
            print "# Output file "//fn_out//" exists. Override."
            if( fn_in != fn_out ){
    	        imdelete( fn_out, ver- )
            }
        }
        imcopy( tmpfile3, fn_out, ver- )
	printf("Processed: %s\n", fn_out )
    }else{
	print "Skip."
    }

    imdelete( tmpfile0, ver- )
    imdelete( tmpfile3, ver- )
    delete( imgfiles, ver- )
}

#print( "Cosmic ray correction finished." )


end

#end of the script

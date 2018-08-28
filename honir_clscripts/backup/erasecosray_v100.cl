#
# erasecosray.cl
# Ver 1.0 2014/07/17 H. Akitaya
#

procedure erasecosray( fn_in, fn_out, threshold )

string fn_in { prompt = "Input file name"}
string fn_out { prompt = "Output file name"}
real threshold { prompt = "Background threshold" }
bool override = no { prompt = "Override mode" }

begin

string region, tmpfile1, tmpfile2, dummy, fn_in_, fn_out_
real threshold_
fn_in_ = fn_in
fn_out_ = fn_out
threshold_ = threshold

print "Click region corners ( 2 points )"
getregion | scanf( "%s", region )
printf( "# Region: %s\n", region )

tmpfile1 = mktemp( "tmp$tmp_erasecosray1" )//".fits"
tmpfile2 = mktemp( "tmp$tmp_erasecosray2" )//".fits"

if ( access( fn_out_ ) && override == no ){
   error( 1, "# Output file "//fn_out_//" exists. Abort" )
}

imcopy( fn_in_, tmpfile1, ver- )
imreplace( tmpfile1//region, 0.0 )
imarith( fn_in_, "-", tmpfile1, tmpfile2, ver- )
imreplace( tmpfile2, 0.0, upper=threshold_, lower=INDEF )

if ( access( fn_out_ ) ){
   print "# Output file "//fn_out_//" exists. Override."
   imdelete( fn_out_, ver- )
}

imcopy( fn_in_, fn_out_, ver- )
hnbpfix( fn_out_, sffixpix+, calbp-, calds-, dsall-, bpmask=tmpfile2, \
	dsmask="", objsel-, fltrsel-, se_in="", se_out="", outlist="",\
	mainext=".fits", over+ )

#print( "Cosmic ray correction finished." )

imdelete( tmpfile1, ver- )
imdelete( tmpfile2, ver- )

end

#end of the script

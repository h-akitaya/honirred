#
#  hnpreproc.cl
#  HONIR preprocessor
#
#           Ver 1.00 2014/04/15 H.Akitaya
#           Ver 1.01 2014/04/16 H.Akitaya
#           Ver 1.10 2014/05/09 H.Akitaya ; Multiple dark images, clean mode, etc.
#           Ver 1.20 2014/06/02 H.Akitaya ; Without flattening mode (woflat)
#
#  input : file(s) or @list-file
#

procedure hnpreproc ( object )

string object { prompt = "Object Name" }
bool opt = yes
bool ira = yes
bool partial = no
string flat_sppol_irs = ""
bool clean = no
bool woflat = no

begin

    string objname
    string imgfiles, img, header_obj, header_expt, str_expt
    string fn_bias
    real expt_obj = 0.0
    real expt_array[999]
    int n_expt = 0
    bool expt_exist = no
    objname = object

    fn_bias = "bias_ave_bt.fits"
     
    if( opt == yes ){
        hntrimccd( "HN*opt00.fits",clean=clean )
	if( !access( fn_bias ) ){
	    hnmkbias("HN*opt00_bt.fits", fn_bias, 
	      skiptrim+, partial=partial, clean=clean )
        }
	hnbsub( "HN*opt00_bt.fits", template="bias_ave_bt.fits", \
	  over+, clean=clean )
        hedit( "*opt00_bt.fits", "DISPAXIS", 2, add+, ver-)
	if ( woflat == no ) {
        hnflatten( "HN*opt??_bs.fits", auto+, object=object, over+,\
	  se_in="_bs", clean=clean )
        }
    }
    if( ira == yes ){
        hntrimvirgo( "HN*ira??.fits", clean=clean, clean=clean )
        imgfiles = mktemp ( "tmp$tmp_hnpreproc1_" )
        sections( "HN*ira??_bt.fits", option="fullname", > imgfiles )
        list = imgfiles
	while( fscan( list, img ) != EOF ){
            hselect( img, "OBJECT", "yes", missing="INDEF" ) | scanf("%s", header_obj )
	    if( header_obj == object ){
	        hselect( img, "EXPTIME", yes, missing="0.0" ) | scanf("%s", header_expt )
		expt_obj = real( header_expt )
		expt_exist = no
		for(i=1; i<= n_expt; i+=1 ){
		    if ( expt_array[i] == expt_obj )
		        expt_exist = yes
		}
		if( expt_exist == no ){
		    n_expt += 1
		    expt_array[n_expt] = expt_obj
		}
 	    }
        }
	if( access( imgfiles ) )
	    delete( imgfiles, ver- )
	if( expt_obj == 0.0 ){
	    error(1, "No object image found !" )
        }
	if( n_expt >= 1 ){
	    for(i=1; i<= n_expt; i+=1 ){
	        printf( "%07.0f\n", expt_array[i]*100 ) | scanf( "%s", str_expt )
		if( !access( "darkave"//str_expt//".fits" ) ){
	            hnmkdark( "HN*ira??_bt.fits", "darkave"//str_expt//".fits", dksel+, etsel+, \
	                expt_select=expt_array[i], darklst="dark.lst", clean=clean )
                }
            }
	}
        hndsubv( "HN*ira??_bt.fits", darklst="dark.lst", object=object, \
            over+, clean=clean )
	if ( woflat == no ) {
            hnflatten( "HN*ira??_ds.fits", auto+, object=object, over+, clean=clean )
	hnbpfix( "HN*ira??_fl.fits", calbp+, calds+, object=object, over+, \
	    sffixpix+ )
        }
    }

    print("# Done. (hnpreproc.cl)" )

end

# end of the script

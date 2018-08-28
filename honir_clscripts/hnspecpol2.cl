#
#  hnspecpol1.cl
#  HONIR spectoropolarimety script 1
#
#           Ver 1.00 2014/04/15 H.Akitaya
#           Ver 1.01 2014/05/13 H.Akitaya
#
#  input : 
#

procedure hnspecpol1 ( object, spmode )

string object { prompt = "Object Name" }
string spmode { prompt = "Spectroscopy mode (irs|irl|opt)" }
string b_sample = "-33:-30,30:33" { prompt = "b_sample for apall" }
real aplower=-29
real apupper=29
string filter = "none" {prompt = "Filter" }
string nodpattern = "AB" {prompt = "Nodding pattern (e.g. ABA )" }
string usenodpos="" {prompt = "Nodding position to be used (e.g. A )" }
string extndir = "" {prompt = "extention for result directory" }
bool reidentify = yes
bool skipskysub = no
bool skipflat = no
bool skippol = no

begin
    string nodpos, nodpos_sk, se_in_flat, flat_fn, fn_in
    string nod_letter[99], nod_current, nod_pos
    string order
    int linefind, nod_num
    bool nlexist, useflag
    string t_sample

    flat_fn = "flat_sppol_"//spmode//"_allhwp.fits"
    t_sample="*"

    if ( spmode == "opt" ){
        linefind = 1200
	se_in_flat="_bs"
	order = "decreasing"
        t_sample="600,2400"
    }else{
        linefind = 1000
	flat_fn = "flat_sppol_"//spmode//"_allhwp.fits"
	se_in_flat="_ds"
	order = "increasing"
	if( spmode == "irs")
            t_sample="100,1100"
	else if ( spmode == "irl" )
            t_sample="100,1600"
    }

    if ( skipskysub == yes )
        goto spec

    # flattening 
    if( skipflat == no ) {
        if ( spmode == "opt" ){
            hnflatten( "HN*opt00_bs.fits", flat=flat_fn, \
	        grism=spmode, object=object,se_in=se_in_flat, )
        }else{
            hnflatten( "HN*ira00_ds.fits", flat=flat_fn, \
	        grism=spmode, object=object,se_in=se_in_flat, )
            hnbpfix( "HN*ira*_fl.fits", calbp+, calds+, over+ )
        }
    }
    # list file generation
    if ( spmode== "opt" ){
        hnlistgen( "HN*opt00_fl.fits", spmode//"_fl.lst", object=object, \
        grism=spmode, filter=filter, over+ )
    }else{
        hnlistgen( "HN*ira??_fl.fits", spmode//"_fl.lst", object=object, \
        grism=spmode, filter=filter, over+ )
    }
    # marking nodding letter
    hnmarknod( "@"//spmode//"_fl.lst", nodpattern )
    # subtracting nodding frame
    hnnodsub( "@"//spmode//"_fl.lst",  hwpchk+, over+, \
      outlist=spmode//"_sk.lst" )

    hnmknodlists( "@"//spmode//"_sk.lst", spmode//"_sk", over+ )
    hnmknodlists( "@"//spmode//"_fl.lst", spmode//"_fl", over+ )

spec:

    # analyze nodpattern letters
    nod_num=0
    for( i=0; i< strlen( nodpattern ); i+=1 ){
    	nlexist = no
	nod_current = substr( nodpattern, i+1, i+1)
        for( j=0; j<nod_num; j+=1 ){
	    if ( nod_letter[j+1] == nod_current )
	        nlexist = yes
	}
	if ( nlexist == no ){
	    nod_num += 1
	    nod_letter[nod_num] = nod_current
	}
    }
#    for( i=1; i<=nod_num; i+=1 ){
#        printf("%s\n", nod_letter[i] )
#    }

    # producing average image for each nodding positions
    for( i=1; i<=nod_num; i+=1 ){
    	nodpos = nod_letter[i]
	if( access( spmode//"_"//nodpos//"_fl_ave.fits" ) ){
	    printf( "Old %s exists. Override.\n", \
	      spmode//"_"//nodpos//"_fl_ave.fits" )
	    imdelete( spmode//"_"//nodpos//"_fl_ave.fits", ver- )
        }
        imcomb( "@"//spmode//"_fl_"//nodpos//".lst", \
	spmode//"_"//nodpos//"_fl_ave.fits", \
	mclip+, reject="sigclip", hsig=3, lsig=3 )
    }

    # tracing and extraction of object spectra
    for( i=1; i<=nod_num; i+=1 ){
    	nodpos = nod_letter[i]
	# checking for nodding positions for using in the analyse
        if ( strlen( usenodpos) != 0 ){
	   useflag = no
	   for (j=1; j<= strlen( usenodpos ); j=j+1 ){
	     if ( nodpos ==  substr( nodpattern, j, j) )
	       useflag = yes
	   }
	   if (useflag == no ) next
        }
    	fn_in=spmode//"_"//nodpos//"_fl_ave.fits"
	if( access( spmode//"_"//nodpos//"_fl_ave.ms.fits" ) ){
	    printf( "Old %s exists. Override.\n", \
	      spmode//"_"//nodpos//"_fl_ave.ms.fits" )
	    imdelete( spmode//"_"//nodpos//"_fl_ave.ms.fits",ver- )
        }
	apall( fn_in, \
       	  b_sample=b_sample, lower=aplower, upper=apupper, \
       	  line=linefind, background="median",\
       	  inter+, find+, recenter+, resize+, edit+, trace+, fittrace+, \
       	  extract+, extras-, shift+, npeaks=2, \
	  radius= 200.0, width= 20.0, \
	  nfind=2, order=order, minsep=150.0, maxsep=200.0, \
	  t_function="legendre", t_order=3, t_sample=t_sample )
	imdelete( "@"//spmode//"_sk.ms_"//nodpos//".lst", ver- )
        apall("@"//spmode//"_sk_"//nodpos//".lst", line=linefind, \
          ref=fn_in, inter-, find-, recenter-, resize-, edit-, \
          trace-, fittrace-, extract+, extras- )
    }

    # extracting sky spectra
    printf ("#nodnum=%d\n", nod_num )
    for( i=1; i<=nod_num; i+=1 ){
        nodpos = nod_letter[i]
	# checking for nodding positions for using in the analyse
        if ( strlen( usenodpos) != 0 ){
	   useflag = no
	   for (j=1; j<= strlen( usenodpos ); j=j+1 ){
	     if ( nodpos ==  substr( nodpattern, j, j) )
	       useflag = yes
	   }
	   if (useflag == no ) next
        }

	if ( i <= (nod_num-1) ){
	    j=i+1
	}else{
	    j=i-1
        }
	printf ("#j=%d\n", j )
	nodpos_sk= nod_letter[j]    
	head( spmode//"_sk_"//nodpos//".lst", \
	  nlines=1 ) | scanf( "%s", fn_in )
	if( access( "sky_"//spmode//"_"//nodpos//".ms.fits" ) ){
	    printf( "Old %s exists. Override.\n",\
	      "sky_"//spmode//"_"//nodpos//".ms.fits" )
        }
        apall( spmode//"_"//nodpos_sk//"_fl_ave.fits", ref=fn_in,
          out="sky_"//spmode//"_"//nodpos//".ms", inter-, find-, \
	  recenter-, resize-, edit-, trace-, fittrace-, extract+, \
	  extras-, background="none" )
        if ( reidentify == yes ){
            reidentify( "line_sppol_"//spmode//"_"//nodpos//".ms", \
	      "sky_"//spmode//"_"//nodpos//".ms.fits" )
            hedit( "@"//spmode//"_sk.ms_"//nodpos//".lst", "REFSPEC1", \
              "sky_"//spmode//"_"//nodpos//".ms",  add+, ver- )
        } else {
            hedit( "@"//spmode//"_sk.ms_"//nodpos//".lst", "REFSPEC1", \
              "line_sppol_"//spmode//"_"//nodpos//".ms",  add+, ver- )
	}
	imdelete( "@"//spmode//"_sk.dc_"//nodpos//".lst", ver- )
        dispcor ( "@"//spmode//"_sk.ms_"//nodpos//".lst", \
	  "@"//spmode//"_sk.dc_"//nodpos//".lst" )
        hnoediv( "@"//spmode//"_sk.dc_"//nodpos//".lst" )
    }
    
    if ( skippol == yes )
       goto scriptend
    #polarimetry
    if( access( spmode//"_oe.lst" ) )
        delete( spmode//"_oe.lst", ver- )
    sed( 's/_fl/_sk_o.dc/', spmode//"_fl.lst", > spmode//"_oe.lst" )
    sed( 's/_fl/_sk_e.dc/', spmode//"_fl.lst", >> spmode//"_oe.lst" )

    hnpcal( "@"//spmode//"_oe.lst" )

    if( !access( "result_"//spmode//extndir ) ){
        mkdir( "result_"//spmode//extndir )
    }else{
        imdelete( "result_"//spmode//extndir//"/pcal*fits", ver-)
    }
    move( "pcal*fits", "result_"//spmode//extndir )

scriptend:

    print("# Done. (hnspecpol2.cl)" )

end

# end of the script

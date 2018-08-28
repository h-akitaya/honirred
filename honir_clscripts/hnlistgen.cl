#
#  hnlistgen.cl
#  HONIR list file generator
# 
#
#           Ver 1.00 2014/04/07 H.Akitaya
#
#  usage: hnlistgen (images/list) (out_list) (option)
#
#

procedure hnlistgen( in_images, out_list )

string in_images { prompt = "Image Name"}
string out_list { prompt = "Output list file name" }
string object = ""
string filter = ""
string grism = "" { prompt = "irs|irl|opt"}
#string se_in = "_ds"
#string se_out = "_fl"
#string mainext = ".fits"
bool override = no

struct *imglist

begin
     string imgfiles, img, fn_in, images, list_fn
     string taskname
     string header_obj, header_arm, header_filter, header_grism, dummy
     int i,j, n_mainext
     real biasval
     bool objsel = no
     bool fltrsel = no
     bool grismsel = no

     taskname="hnlistgen.cl"

     images = in_images
     list_fn = out_list

     if( access( list_fn ) ){
         if( override == no ){
             error(1, "# Old list file "//list_fn//" exists. Aborted." )
         }else{
             printf("# Old list file "//list_fn//" exists. Override.\n" )
	     delete( list_fn, ver- )
        }
     }
     if ( object != "" )
       objsel = yes
     if ( filter != "" )
       fltrsel = yes
     if ( grism != "" )
       grismsel = yes

     print("# "//taskname )

     imgfiles = mktemp ( "tmp$tmp_hnlistgen_1" )
     sections( images, option="fullname", > imgfiles )

     imglist = imgfiles
     while( fscan( imglist, fn_in ) != EOF ){
     
	hselect( fn_in, "OBJECT", yes ) | scanf( "%s", header_obj )
 	if( objsel == yes && object != header_obj )
                next
        hselect( fn_in, "HN-ARM", yes ) | scanf( "%s", header_arm )
        if( header_arm == "ira" )
            hselect( fn_in, "WH_IRAF2", yes ) | scanf( "%s", header_filter )
        else if ( header_arm == "opt" )
            hselect( fn_in, "WH_OPTF2", yes ) | scanf( "%s", header_filter )
        else
            hselect( fn_in, "WH_IRAF2", yes ) | scanf( "%s", header_filter )
        if ( fltrsel == yes && filter != header_filter )
                next
        if( grismsel == yes ){
          if( header_arm == "ira" )
            hselect( fn_in, "WH_IRAF1", yes ) | scanf( "%s %s", dummy, header_grism )
          else if ( header_arm == "opt" )
            hselect( fn_in, "WH_OPTF1", yes ) | scanf( "%s %s", dummy, header_grism )
          else
            hselect( fn_in, "WH_OPTF1", yes ) | scanf( "%s %s", dummy, header_grism )
          if( grism == "irs" && header_grism != "IRshort\"" )
	    next
          else if( grism == "irl" && header_grism != "IRlong\"" )
	    next
	  else if( grism == "opt" && header_grism != "Opt\"" )
	    next
        }

	printf("%s (%3s %4s %s)\n", fn_in,  \
  	    header_arm, header_filter, header_obj )
        printf("%s\n", fn_in, >> list_fn )
     }

     # clean up
     delete( imgfiles, ver-, >& "dev$null" )
     printf("# list file : %s\n", list_fn )
     print("# Done. ("//taskname//")" )

end

# end of the script

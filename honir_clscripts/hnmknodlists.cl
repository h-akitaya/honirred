#
#  hnmknodlists.cl
#
#     Ver 1.00  2014/04/09  H. Akitaya
#

procedure hnmknodlists( images, fnroot )

string images {prompt = "Input image files"}
string fnroot {prompt = "list file name root" }
struct *imglist
bool override = no { prompt = "Override ?" }
string mainext=".fits"
#string se_in = "_sk"

begin

  string in_images, imgfiles, nodletter, img, in_fnroot, img_root
  string nodpos, lstname
  int n_nodptrn, index
  string nodlist[99]
  int nodnum = 0
  bool append
  string img_substr[99]
  int num_img_substr=5
  img_substr[1] =".ms"
  img_substr[2] =".dc"
  img_substr[3] ="_o.dc"
  img_substr[4] ="_e.dc"
  img_substr[5] =""

  in_images = images
  in_fnroot = fnroot

  imgfiles = mktemp ( "tmp$tmp_hnmknodlists1" )
  sections( in_images, option="fullname", > imgfiles )
  imglist = imgfiles

  while( fscan( imglist, img ) != EOF ){
      # get rid of the extentions
      extsrm( img, mainext, "" ) | scanf( "%s", img_root )
      printf( "%s\n", img )
      hselect( img, "NODPOS", yes, missing="NONE") | scanf( "%s", nodpos )
      if( nodpos == "NONE" ){
          printf( "NODPOS keyword not found. Skip.\n" )
	  next
      }
      append = no
      for( i=1; i<=nodnum; i+=1 ){
          if( nodpos == nodlist[i] )
	      append = yes
      }
      if ( append == no ){
   	 nodlist[nodnum+1] = nodpos
         nodnum += 1
      }
      for( i=1; i <= num_img_substr; i+=1 ){
          lstname= in_fnroot//img_substr[i]//"_"//nodpos//".lst"
          if( append == no && access( lstname ) ){
	      printf("Old list file %s exists.", lstname )
 	      if( override == yes ){
                  printf(" Override.\n")
		  delete( lstname, ver- )
              }else{
	          printf(" Skip.\n" )
		  next
              }
          }
	  printf( "%s\n", img_root//img_substr[i]//mainext, >> lstname )
	  printf( "%s -> %s\n", img_root//img_substr[i]//mainext, lstname )
      }
  }
  delete( imgfiles, ver- )

  print("# Done. (hnmknodlists.cl)" )

  bye

end

#end
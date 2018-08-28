#
#       HOWPol REDUCTION SUB ROUTINE
#
#       howossub.cl: Overscan subtraction and Merge 4 port images
#
#         HOW.list should include file lists like
#            HP0000001_0.fits
#            HP0000002_0.fits
#            HP0000003_0.fits
#                   :
#
procedure howossub

begin

  string inlist = "HOW.list"
  string fnhead[2000]
  string buf
  int n_list
  string fn1, fn2
  string tmp_fn1, tmp_fn2, tmp_fn3, tmp_fn4

  #Image+overscan region of 4 ports
  int x11 = 1
  int x12 = 536
  int x13 = 537
  int x14 = 1072
  int x15 = 1073
  int x16 = 1608
  int x17 = 1609
  int x18 = 2144
  int y11 = 1
  int y12 = 4241

  #Overscan region X-range of each image
  int x21 = 1
  int x22 = 8
  int x23 = 521
  int x24 = 536

  int x25 = 1
  int x26 = 16
  int x27 = 529
  int x28 = 536
  
  #Dimension of output image
  int x31 = 2048
  int x32 = 512
  int y31 = 4221

  #Image region of temporary files
  int x41 = 9
  int x42 = 520
  int x43 = 17
  int x44 = 528
  int y41 = 3
  int y42 = 4223

  task $sed = "$foreign" 
  tmp_fn1 = mktemp( "how.tmp." )//".fits"
  tmp_fn2 = mktemp( "how.tmp." )//".fits"
  tmp_fn3 = mktemp( "how.tmp." )//".fits"
  tmp_fn4 = mktemp( "how.tmp." )//".fits"

  if( access( tmp_fn1 ) == 1 )
    delete( tmp_fn1, ver- )
  if( access( tmp_fn2 ) == 1 )
    delete( tmp_fn2, ver- )
  if( access( tmp_fn3 ) == 1 )
    delete( tmp_fn3, ver- )
  if( access( tmp_fn4 ) == 1 )
    delete( tmp_fn4, ver- )

### Read list file ###

  if( access( inlist ) )
  {
    printf( "INLIST '%s' found. ", inlist )
  }
  else
  {
    while( access( inlist ) == 0 )
    {
      printf( "INLIST '%s' not found. Enter file name >> ", inlist )
      c = scan( inlist )
    }
    printf( "INLIST '%s' found. ", inlist )
  }

  sed( 's/\.fits//', inlist, > tmp_fn1 )

  n_list = 0
  list = tmp_fn1
  while( fscan( list, buf ) != EOF )
  {
    n_list += 1
    fnhead[n_list] = buf
  }
  delete( tmp_fn1, ver- )
  printf( "%d files registed.\n", n_list )

### mail routine ###

  for( i=1; i<=n_list; i+=1 )
  {
    fn1 = fnhead[i]//".fits"
    fn2 = fnhead[i]//".bs.fits"

    printf( "%s(", fn1 )

    if( access( fn1 ) == 0 )
    {
      printf( "Not found. Skipped.)  " )
      next
    }

    if( access( fn2 ) == 1 )
    {
      printf( "Overwrite..." )
      delete( fn2, ver- )
    }

### Read overscan/prescan regions  ###

    imgets( fn1, 'PORT1X1' )
    x11 = int( imgets.value )
    imgets( fn1, 'PORT1X2' )
    x12 = int( imgets.value )
    imgets( fn1, 'PORT2X1' )
    x13 = int( imgets.value )
    imgets( fn1, 'PORT2X2' )
    x14 = int( imgets.value )
    imgets( fn1, 'PORT3X1' )
    x15 = int( imgets.value )
    imgets( fn1, 'PORT3X2' )
    x16 = int( imgets.value )
    imgets( fn1, 'PORT4X1' )
    x17 = int( imgets.value )
    imgets( fn1, 'PORT4X2' )
    x18 = int( imgets.value )

    imgets( fn1, 'EFPYMIN1' )
    y11 = int( imgets.value )
    imgets( fn1, 'EFPYRNG1' )
    y12 = int( imgets.value ) + y11 - 1

    imgets( fn1, 'PSRE13X1' )
    x21 = int( imgets.value )
    imgets( fn1, 'PSRE13X2' )
    x22 = int( imgets.value )
    imgets( fn1, 'OSRE13X1' )
    x23 = int( imgets.value )
    imgets( fn1, 'OSRE13X2' )
    x24 = int( imgets.value )
    imgets( fn1, 'OSRE24X1' )
    x25 = int( imgets.value )
    imgets( fn1, 'OSRE24X2' )
    x26 = int( imgets.value )
    imgets( fn1, 'PSRE24X1' )
    x27 = int( imgets.value )
    imgets( fn1, 'PSRE24X2' )
    x28 = int( imgets.value )

    x31 = 0
    imgets( fn1, 'EFPXRNG1' )
    x32 = int( imgets.value )
    x31 += x32
    imgets( fn1, 'EFPXRNG2' )
    x31 += int( imgets.value )
    imgets( fn1, 'EFPXRNG3' )
    x31 += int( imgets.value )
    imgets( fn1, 'EFPXRNG4' )
    x31 += int( imgets.value )

    y31 = y12 - y11 + 1

    imgets( fn1, 'PSRE13X2' )
    x41 = int( imgets.value ) + 1
    imgets( fn1, 'OSRE13X1' )
    x42 = int( imgets.value ) - 1
    imgets( fn1, 'OSRE24X2' )
    x43 = int( imgets.value ) + 1
    imgets( fn1, 'PSRE24X1' )
    x44 = int( imgets.value ) - 1

    y41 = 1
    y42 = y31


### Processing ###

    printf(" Dividing... " )

    imcopy( fn1//"["//x11//":"//x12//","//y11//":"//y12//"]",\
            tmp_fn1, ver- )
    imcopy( fn1//"["//x13//":"//x14//","//y11//":"//y12//"]",\
            tmp_fn2, ver- )
    imcopy( fn1//"["//x15//":"//x16//","//y11//":"//y12//"]",\
            tmp_fn3, ver- )
    imcopy( fn1//"["//x17//":"//x18//","//y11//":"//y12//"]",\
            tmp_fn4, ver- )

    chpixtype( tmp_fn1, tmp_fn1, newpixtype="real", ver- )
    chpixtype( tmp_fn2, tmp_fn2, newpixtype="real", ver- )
    chpixtype( tmp_fn3, tmp_fn3, newpixtype="real", ver- )
    chpixtype( tmp_fn4, tmp_fn4, newpixtype="real", ver- )


    printf(" Subtracting... " )

    background( tmp_fn1, tmp_fn1, axis=1,\
                sample=x21//":"//x22//","//x23//":"//x24, naverage=1,\
                function="legendre", order=2, low_reject=2.5,\
                high_reject=1.0, niterate=3, interac- )
    background( tmp_fn2, tmp_fn2, axis=1,\
                sample=x25//":"//x26//","//x27//":"//x28, naverage=1,\
                function="legendre", order=2, low_reject=2.5,\
                high_reject=1.0, niterate=3, interac- )
    background( tmp_fn3, tmp_fn3, axis=1,\
                sample=x21//":"//x22//","//x23//":"//x24, naverage=1,\
                function="legendre", order=2, low_reject=2.5,\
                high_reject=1.0, niterate=3, interac- )
    background( tmp_fn4, tmp_fn4, axis=1,\
                sample=x25//":"//x26//","//x27//":"//x28, naverage=1,\
                function="legendre", order=2, low_reject=2.5,\
                high_reject=1.0, niterate=3, interac- )

    printf(" Combining... " )

    imcopy( fn1//"[1:"//x31//",1:"//y31//"]", fn2, ver- )
    chpixtype( fn2, fn2, newpixtype="real", ver- )

#printf( "\n x41=%d %d %d %d y41=%d %d x32=%d y31=%d\n",\
#        x41, x42, x43, x44, y41, y42, x32, y31 )

    imcopy( tmp_fn1//"["//x41//":"//x42//","//y41//":"//y42//"]" , \
             fn2//"["//(1-1)*x32+1//":"//1*x32//",1:"//y31//"]", ver- )
    imcopy( tmp_fn2//"["//x43//":"//x44//","//y41//":"//y42//"]" , \
             fn2//"["//(2-1)*x32+1//":"//2*x32//",1:"//y31//"]", ver- )
    imcopy( tmp_fn3//"["//x41//":"//x42//","//y41//":"//y42//"]" , \
             fn2//"["//(3-1)*x32+1//":"//3*x32//",1:"//y31//"]", ver- )
    imcopy( tmp_fn4//"["//x43//":"//x44//","//y41//":"//y42//"]" , \
             fn2//"["//(4-1)*x32+1//":"//4*x32//",1:"//y31//"]", ver- )

    delete( tmp_fn1, ver- )
    delete( tmp_fn2, ver- )
    delete( tmp_fn3, ver- )
    delete( tmp_fn4, ver- )

    printf( "Done)\n" )
  }
  
  printf( "\n" )

end


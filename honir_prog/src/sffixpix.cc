/*
  
  bad pixel correction (SFITSIO version)

  sffixpix.cc
  2014/03/03  Ver 1.00  H. Akitaya
  
  requirements:
    SLLIB, SFITSIO
    see http://www.ir.isas.jaxa.jp/~cyamauch/sli/index.ni.html

  compile:
    $ s++ sffixpix.cc -lsfitsio
*/


#include <stdio.h>
#include <string.h>
#include <sli/fitscc.h>

using namespace sli;

int help();
int bpfix( long y, long x_begin, long x_end, fits_image& image );
double linearfunc( double x, double x1, double x2, double z1, double z2 );

double linearfunc( double x, double x1, double x2, double z1, double z2 ){
  return (z1 + (z2-z1)/(x2-x1)*(x-x1));
}

int help(){
  printf("Usage: sffixpix (input file) (bad pix map file) (output file)\n");
  return 0;
}

int bpfix( long y, long x_begin, long x_end, fits_image& image ){
#ifdef DEBUG
  printf("y= %4ld, x_begin= %4ld, x_end=%4ld\n", y, x_begin, x_end );
#endif
  long x;
  double z1=0, z2=0;
  if( x_begin != 1) 
    z1 = image.dvalue( x_begin-1, y );
  if( x_end != image.row_length() )
    z2 = image.dvalue( x_end+1, y );
  for( x=x_begin; x<=x_end; x++){
    if( x_begin == 1 )
      image.assign( z2, x, y);
    else if( x_end == image.row_length() )
      image.assign( z1, x, y);
    else
      image.assign( linearfunc( x, x_begin-1, x_end+1, z1, z2 ), x, y);
  }
  return 0;
}

int main( int argc, char *argv[] ){
  fitscc in_fits, bpmask_fits, out_fits;
  ssize_t sz_in, sz_bp, sz_out;
  
  long x, y, naxis1, naxis2, n_bp=0;
  
  if ( argc != 4 ){
    help();
    exit(1);
  }
  
  const char *in_file = argv[1];
  const char *bpmask_file = argv[2];
  const char *out_file = argv[3];
  sz_in = in_fits.read_stream( in_file );
  sz_bp = bpmask_fits.read_stream( bpmask_file );
  
  
  if ( sz_in < 0 || sz_bp < 0) {
    fprintf( stderr, "[ERROR] fits.read_stream() failed\n" );
    exit( -1 );
  }
  
  fits_image &bpmask = bpmask_fits.image("Primary");
  fits_image &image = in_fits.image("Primary");
  
  naxis1 = bpmask.col_length();
  naxis2 = bpmask.row_length();
#ifdef DEBUG
  printf("NAXIS1 = %ld,  NAXIS2 = %ld\n", naxis1, naxis2 );
#endif
  
  // scanning bad pixel mask file and correction
  for(y=1; y<= naxis2; y++){
    bool flag_bp = false;
    long x_begin;
    x_begin=1;
    for(x=1; x<=naxis1; x++){
      if ( bpmask.dvalue( x, y ) != 0.0 ){
	n_bp++;
	if( flag_bp == false ){
	  x_begin = x;
	  flag_bp = true;
	}
      }else{
	if( flag_bp == true ){
	  bpfix( y, x_begin, x-1, image );
	  flag_bp = false;
	}
      }
    }
  }
  // write HISTORY header records
  char history1[255]; snprintf( history1, sizeof(history1)-1, "Bad pixel mask = %s", bpmask_file );
  char history2[255]; snprintf( history2, sizeof(history2)-1, "Number of corrected bad pixels : %ld", n_bp);
  image.header_append("HISTORY", "Bad pixels corrected by hnbpfix" );
  image.header_append("HISTORY", history1 );
  image.header_append("HISTORY", history2 );

  // write result image file
  sz_out = in_fits.write_stream( out_file );
  
  if ( sz_out < 0 ) {
    fprintf( stderr, "[ERROR] fits.write_stream() failed\n" );
    exit( -1 );
  }
  printf("# input file: %s\n", in_file );
  printf("# bad pix mask: %s\n", bpmask_file );
  printf("# output file: %s\n", out_file );
  printf("# %ld bad pixels corrected\n", n_bp );
  
}

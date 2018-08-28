#!/usr/local/bin/python
import sys
import numpy
import re
import math

CLIP_FACTOR=2.2

f=open( sys.argv[1], "r" )
w1= float( sys.argv[2] )
w2= float( sys.argv[3] )
wbin= float( sys.argv[4] )
errlim = float( sys.argv[5] )

if ( len(sys.argv) > 6 ):
    option = sys.argv[6]
else:
    option=""

wls=[]
signals =[]

for line in f:
    data=line[:-1].split()
    wls.append(float(data[0]) )
    signals.append( float(data[1]) )
  
wl=w1
while wl < w2:
#        print wl
        wl_c = wl + wbin/2.0
        if option == "atoum":
            wl_c /= 10000.0
        bin_signals=[]
        cliped_signals=[]
        for i in range( 0, len( signals ) ):
#            if( signals[i] < 0.35):
#                continue
            if ( wl < wls[i] and wls[i] <= (wl+wbin )):
                bin_signals.append( signals[i] )
        if len( bin_signals) == 0:
            wl+=wbin
            continue
        median = numpy.median( bin_signals )
        std = numpy.std( bin_signals )
        cliped_signals = numpy.clip( bin_signals, 
                                     median-CLIP_FACTOR*std, 
                                     median+CLIP_FACTOR*std )
        if len( cliped_signals ) == 0 :
            wl+=wbin
            continue
        average = numpy.average( cliped_signals )
        err = numpy.std( cliped_signals) / math.sqrt( len( cliped_signals ))
        if ( errlim == 0.0 or ( errlim != 0.0 and err < errlim )) :
            print "%13.7f %13.7f %13.7f" % (wl_c, average, err )
        wl+=wbin
#        print "#%f" % wl

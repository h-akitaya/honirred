#!/usr/local/bin/python
#
# Limiting Magnitude Calculator
#    2014/07/16 Ver 1.00  H. Akitaya
#

import sys
import math

class Photometry( object ):
    def __init__( self ):
        self.gain = 1.0
        self.pixscale = 1.0
        self.m0 = 0.0
    def setM0( self, m0 ):
        self.m0 = m0
    def getM0( self ):
        return self.m0
    def setGain( self, gain ):
        self.gain = gain
    def setPixScale( self, pixscale ):
        self.pixscale = pixscale
    def calcArea( self, diameter ):
        area = math.pi * ( diameter / 2.0 )**2 * (self.pixscale)**2
        return area
    def getSN( self, objsignal, bjfluc, diameter ):
        sn = objsignal*self.gain / \
             math.sqrt( (bjfluc*self.gain)**2*self.area( diameter )+ \
                        obgsignal*self.gain)
        return sn
    def calcMag( self, objsignal ):
        mag = self.m0 - 5.0/2.0*math.log10( objsignal )
        return mag
    def calcObjSignal( self, sn, bjfluc, diameter ):
        objsignal = 1.0/self.gain * \
                    (sn**2* math.sqrt( sn**4 + 4.0*(bjfluc*self.gain)**2*\
                                       self.calcArea( diameter ) ) ) /2.0
        return objsignal
    def calcLimMag( self, sn, bjfluc, diameter ):
        limmag = self.calcMag( self.calcObjSignal( sn, bjfluc, diameter) )
        return limmag

if __name__ == '__main__':
    if len( sys.argv ) < 5 :
        print "Usage: imglimmag.py m0[mag] bjfluc(ADU) diameter(arcsec) S/N"
        sys.exit()
    ph = Photometry()
    ph.setGain=11.0 # e-/ADU
    ph.setPixScale = 1.0/0.295 # pix/arcsec
    ph.setM0( float(sys.argv[1]) )

    bjfluc = float( sys.argv[2] )
    diameter = float( sys.argv[3] )
    sn = float( sys.argv[4] )
    print ph.calcLimMag( sn, bjfluc, diameter )

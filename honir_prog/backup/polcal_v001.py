#!/usr/local/bin/python
#
#  polcal.py
#    Imaging polarimetry for HONIR
#     Ver 0.01  2014/05/11 H. Akitaya
#

import sys
import math
import numpy

import photometry

class Polarimetry( object ):
    def __init__( self ):
        self.hwpdata={}
        self.hwpdata[0.0]=[]
        self.hwpdata[22.5]=[]
        self.hwpdata[45.0]=[]
        self.hwpdata[67.5]=[]
    def append( self, hwp, io, io_err, ie, ie_err ):
        if hwp in self.hwpdata:
            self.hwpdata[hwp].append([io, io_err, ie, ie_err])
    def showAllData( self ):
        print self.hwpdata[0.0]
        print self.hwpdata[22.5]
        print self.hwpdata[45.0]
        print self.hwpdata[67.5]
    def calcNormalizedQU( self, parameter_type ):
        if parameter_type == 'q' :
            hwp1, hwp2 = 0.0, 45.0
        elif parameter_type == 'u' :
            hwp1, hwp2  = 22.5, 67.5
        else:
            hwp1, hwp2 = 0.0, 45.0
        polarray = []
        poldevarray = []
        n_max = min( len(self.hwpdata[hwp1]), len(self.hwpdata[hwp2]) )
        for i in range( 0, n_max ):
            pol, pol_err = self.calcpol( self.hwpdata[hwp1][i], self.hwpdata[hwp2][i] )
            #print( "%11.6f" % pol )
            polarray.append( pol )
            poldevarray.append( pol_err*pol_err )
        pol_ave = numpy.mean(polarray)
        pol_staterr = math.sqrt( numpy.mean(poldevarray) / len(poldevarray) )
        pol_obserr = numpy.std(polarray)/math.sqrt( n_max )
        return pol_ave, pol_obserr, pol_staterr

    def calcpol( self, hwp1_ioie, hwp2_ioie ):
        kappa1 = hwp1_ioie[2]/hwp1_ioie[0]
        kappa2 = hwp2_ioie[2]/hwp2_ioie[0]
        dev_kappa1 = kappa1*kappa1* (
            (hwp1_ioie[3]*hwp1_ioie[3])/(hwp1_ioie[2]*hwp1_ioie[2] ) +
            (hwp1_ioie[1]*hwp1_ioie[1])/(hwp1_ioie[0]*hwp1_ioie[0] ) )
        dev_kappa2 = kappa2*kappa2* (
            (hwp2_ioie[3]*hwp2_ioie[3])/(hwp2_ioie[2]*hwp2_ioie[2] ) +
            (hwp2_ioie[1]*hwp2_ioie[1])/(hwp2_ioie[0]*hwp2_ioie[0] ) )
        a = math.sqrt( kappa1 / kappa2 )
        dev_a = (1.0/4.0)*(kappa1/kappa2)*(
            dev_kappa1 / (kappa1*kappa1) + dev_kappa2 / (kappa2*kappa2) )
        pol = ( 1.0 - a ) / ( 1.0 + a )
        pol_err = 2.0/(1.0+a)*math.sqrt( dev_a )
        return pol, pol_err
    @staticmethod
    def qu2p( q, qerr, u, uerr ):
        p = math.sqrt( q*q + u*u )
        perr = math.sqrt( qerr*qerr + uerr*uerr )
        return p, perr
    @staticmethod
    def qu2t( q, qerr, u, uerr ):
        t_atan = math.atan2( u, q ) # atan(u,q)-> -pi ~ +pi
        if( t_atan < 0 ):
            t_atan += (2.0 * math.pi) # -> 0 ~ +2*pi
        t = (0.5 * t_atan) / math.pi * 180.0
        p, perr = Polarimetry.qu2p( q, qerr, u, uerr )
        if p > (5.0 * perr):
            terr = 28.65 * perr / p
        else:
            terr = 51.96
        return t, terr

class ImpolData( object ):
    def __init__( self, fn ):
        self.poldata={}
        self.readdata( fn )
        self.band = ""

    def setBand( self, band ):
        self.band = band
    def readdata( self, fn ):
        f = open( fn, 'r' )
        for line in f:
            obsdata=line[:-1].split()
            hwp = float( obsdata[2] )
            io = float( obsdata[8] )
            io_err = float( obsdata[9] )
            ie = float( obsdata[11] )
            ie_err = float( obsdata[12] )
            band = obsdata[1]
            if (band in self.poldata ) == False :
                self.poldata[band]=Polarimetry()
            self.poldata[band].append( hwp, io, io_err, ie, ie_err )
#            print hwp
        f.close()
    def showAll( self ):
        print( self.poldata.keys() )
    def showData( self ):
        self.poldata[self.band].showAllData()
    def calcPol( self ):
        if( band not in self.poldata ):
            return
        q_ave, q_obserr, q_staterr = self.poldata[self.band].calcNormalizedQU( 'q' )
        u_ave, u_obserr, u_staterr = self.poldata[self.band].calcNormalizedQU( 'u' )
        p, p_obserr = Polarimetry.qu2p( q_ave, q_obserr, u_ave, u_obserr )
        dummy, p_staterr = Polarimetry.qu2p( q_ave, q_staterr, u_ave, u_staterr )
        t, t_obserr = Polarimetry.qu2t( q_ave, q_obserr, u_ave, u_obserr )
        dummy, t_staterr = Polarimetry.qu2t( q_ave, q_staterr, u_ave, u_staterr )
        print("%6s %10.4f %11.6f %11.6f %11.6f %11.6f  %11.6f %11.6f %11.6f %11.6f %11.6f %11.6f %11.6f %11.6f"
              % (self.band, photometry.getWofBand( self.band ), 
                 q_ave, q_obserr, q_staterr, u_ave, u_obserr, u_staterr, \
                 p, p_obserr, p_staterr, t, t_obserr, t_staterr ) )

if __name__ == '__main__':
    impoldata = ImpolData( sys.argv[1] )
    #impoldata.showAll()
    bands = iter( sys.argv[2].split(',') )
    for band in bands: 
        impoldata.setBand(band)
        #impoldata.showData()
        impoldata.calcPol()

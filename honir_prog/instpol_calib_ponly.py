#!/usr/local/bin/python
#
#  polcal.py
#    Imaging polarimetry for HONIR
#     Ver 0.01  2014/05/11 H. Akitaya
#

import sys
import math
import re
import numpy

import photometry

class PolData( object ):
    def __init__( self ):
        self.band = ''
        self.wl = None
        self.q = None
        self.u = None
        self.dq = None
        self.du = None
        self.p = None
        self.dp = None
        self.t = None
        self.dt = None
    def subNrmStokes( self, poldata ):
        self.q -= poldata.q
        self.u -= poldata.u
        self.qu2pt()
    def divDepolFactor( self, poldata ):
        self.q /= poldata.p
        self.u /= poldata.p
        self.dq /= poldata.p
        self.du /= poldata.p
        self.qu2pt()
    def qu2pt( self ):
        self.p, self.dp = PolData.qu2p( self.q, self.dq, self.u, self.dq )
        self.t, self.dt = PolData.qu2t( self.q, self.dq, self.u, self.dq )
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
        p, perr = PolData.qu2p( q, qerr, u, uerr )
        if p > (5.0 * perr):
            terr = 28.65 * perr / p
        else:
            terr = 51.96
        return t, terr
    def rotate( self, theta ):
        q_new = ( math.cos( 2.0*theta*math.pi/180.0) * self.q -
                  math.sin( 2.0*theta*math.pi/180.0) *self.u )
        u_new = ( math.sin( 2.0*theta*math.pi/180.0) * self.q +
                  math.cos( 2.0*theta*math.pi/180.0) *self.u )
        dq_new = math.sqrt( 
            math.cos( 2.0*theta*math.pi/180.0)**2 * self.dq**2 +
            math.sin( 2.0*theta*math.pi/180.0)**2 * self.du**2 ) 
        du_new = math.sqrt( 
            math.sin( 2.0*theta*math.pi/180.0)**2 * self.dq**2 +
            math.cos( 2.0*theta*math.pi/180.0)**2 * self.du**2 ) 
        self.q = q_new
        self.u = u_new
        self.dq = dq_new
        self.du = du_new
        self.qu2pt()

class PolDataSet( object ):
    INSTPOL_FN = "up_impol_statistics.xy"
    DEPOL_FN = "wg_impol_all_var.xy"
    PAORIGIN_FN = "paorigin.xy"
    def __init__( self, fn, errorsel="stat" ):
        self.errorsel = errorsel
        self.dataset=[]
        self.instpol=[]
        self.depol=[]
        self.paorigin=[]
        self.readPolData( fn )
        self.readInstPol( PolDataSet.INSTPOL_FN )
        self.readDepol( PolDataSet.DEPOL_FN )
        self.readPAOrigin( PolDataSet.PAORIGIN_FN )

    def readPolData( self, fn ):
        f = open( fn, 'r' )
        for line in f:
            if re.match( r'^#', line ) or re.match( r'^\s*$', line):
                continue
            data=line[:-1].split()
            poldata = PolData()
            poldata.band = data[0]
            poldata.wl = float( data[1] )
            poldata.q = float( data[2] )
            poldata.u = float( data[5] )
            poldata.p = float( data[8] )
            poldata.t = float( data[11] )
            poldata.p = float( data[8] )
            poldata.t = float( data[11] )
            if self.errorsel == 'stat':
                poldata.dq = float( data[4] )
                poldata.du = float( data[7] )
                poldata.dp = float( data[10] )
                poldata.dt = float( data[13] )
            elif self.errorsel == 'obs':
                poldata.dq = float( data[3] )
                poldata.du = float( data[6] )
                poldata.dp = float( data[9] )
                poldata.dt = float( data[12] )
            else:
                poldata.dq = float( data[4] )
                poldata.du = float( data[7] )
                poldata.dp = float( data[10] )
                poldata.dt = float( data[13] )
            self.dataset.append( poldata )

    def readInstPol( self, fn ):
        f = open( fn, 'r' )
        for line in f:
            if re.match( r'^#', line ) or re.match( r'^\s*$', line):
                continue
            data=line[:-1].split()
            poldata = PolData()
            poldata.band = data[0]
            poldata.wl = float( data[1] )
            poldata.q = float( data[2] )/100.0
            poldata.dq = float( data[4] )/100.0
            poldata.u = float( data[5] )/100.0
            poldata.du = float( data[7] )/100.0
            self.instpol.append( poldata )

    def readDepol( self, fn ):
        f = open( fn, 'r' )
        for line in f:
            if re.match( r'^#', line ) or re.match( r'^\s*$', line):
                continue
            data=line[:-1].split()
            poldata = PolData()
            poldata.band = data[0]
            poldata.p = float( data[2] )/100.0
            poldata.dp = float( data[3] )/100.0
            poldata.t = float( data[4] )
            poldata.dt = float( data[5] )
            self.depol.append( poldata )

    def readPAOrigin( self, fn ):
        f = open( fn, 'r' )
        for line in f:
            if re.match( r'^#', line ) or re.match( r'^\s*$', line):
                continue
            data=line[:-1].split()
            poldata = PolData()
            poldata.band = data[0]
            poldata.t = float( data[1] )
            poldata.dt = float( data[2] )
            self.paorigin.append( poldata )

    def calibInstPol( self ):
        for i in range(0, len( self.dataset ) ):
            instpol_list = iter( self.instpol )
            for instpoldata in instpol_list:
                if self.dataset[i].band == instpoldata.band:
                    self.dataset[i].subNrmStokes( instpoldata )

    def calibDepol( self ):
        for i in range(0, len( self.dataset ) ):
            depol_list = iter( self.depol )
            for depoldata in depol_list:
                if self.dataset[i].band == depoldata.band:
                    self.dataset[i].divDepolFactor( depoldata )

    def calibHWPPA( self ):
        for i in range(0, len( self.dataset ) ):
            depol_list = iter( self.depol )
            for depoldata in depol_list:
                if self.dataset[i].band == depoldata.band:
                    self.dataset[i].rotate( (-1.0)* depoldata.t )

    def calibPAOrigin( self ):
        band='R'
        paorigin = iter( self.paorigin )
        torg = 0.0
        for paorigindata in paorigin:
            if band == paorigindata.band:
                torg = paorigindata.t
                print paorigindata.band, torg

        for i in range(0, len( self.dataset ) ):
            self.dataset[i].rotate( (-1.0)*torg )

    def showData( self ):
        for i in range(0, len( self.dataset ) ):
            print("%6s %10.4f %11.6f %11.6f %11.6f %11.6f "\
                  "%11.6f %11.6f %11.6f %11.6f %11.6f %11.6f "\
                  "%11.6f %11.6f"
                  % (self.dataset[i].band, self.dataset[i].wl, 
                     self.dataset[i].q, 0.0, self.dataset[i].dq, self.dataset[i].u, 0.0, self.dataset[i].du, \
                     self.dataset[i].p, 0.0, self.dataset[i].dp, self.dataset[i].t, 0.0, self.dataset[i].dt ) )



if __name__ == '__main__':
    poldataset = PolDataSet( sys.argv[1], 'obs')
    poldataset.calibInstPol()
    poldataset.calibDepol()
    poldataset.calibPAOrigin()
    poldataset.calibHWPPA()
    poldataset.showData()
    

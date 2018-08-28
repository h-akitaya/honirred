#!/usr/local/bin/python
#
#  gethonirfile.py
#
#    Ver  0.10  2014/4/11  H. Akitaya
#    Ver  0.11  2014/4/14  H. Akitaya (bug fix for raw image)
#    Ver  0.12  2014/4/25  H. Akitaya (bias search in another date)
#    Ver  0.13  2014/6/2   H. Akitaya (bug fix for no-dark image dir.)
#    Ver  0.14  2014/11/17 H. Akitaya (for file length)
#    Ver  0.15  2015/02/10 H. Akitaya (multiple object name)
#
#   usage: gethonirfile.py (date) "obj1,obj2,..." (obsmode)
#     e.g: gethonirfile.py 20150208 PNS0059 Imaging
#     e.g: gethonirfile.py 20150208 "PNS0059,SNinM61" Imaging
#

import sys
import pyfits
import os.path
import glob
import copy
import datetime
import shutil
import re

BASE_DIR = "/obsdata/honir"
#BASE_DIR = "/mnt_auto/obsdata"

class HeaderInfo( object ):
    def __init__( self ):
        self.object = ""
        self.filter = ""
        self.hnarm = ""
        self.exptime = ""
        self.nprs = ""
        self.spv = ""
        self.obsmode = ""
        self.specmode = ""
    def readHeaderInfo( self, filename ):
        hdulist = pyfits.open( filename )
        if hdulist[0].header.has_key['OBJECT']:
            self.object = hdulist[0].header['OBJECT'] 
        if hdulist[0].header.has_key['HN-ARM']:
            self.hnarm = hdulist[0].header['HN-ARM'] 
        if hdulist[0].header.has_key['NPRS']:
            self.nprs = int( hdulist[0].header['NPRS'] )
        if hdulist[0].header.has_key['EXPTIME']:
            self.exptime = float( hdulist[0].header['EXPTIME'] )
        if hdulist[0].header.has_key['SPV']:
            self.spv = hdulist[0].header['SPV'] 
        if hdulist[0].header.has_key['OBSMODE']:
            self.obsmode = hdulist[0].header['OBSMODE']
        if ( hdulist[0].header.has_key['HN-ARM'] & hdulist[0][0].header.has_key['WH_IRAF2'] &
             hdulist[0].header.has_key['WH_OPTF2'] ):
            if hdulist[0].header['HN-ARM'] == 'ira' :
                self.filter = hdulist.header['WH_IRAF2']
            elif hdulist[0].header['HN-ARM'] == 'opt' :
                self.filter = hdulist.header['WH_OPTF2']
            if ( hdulist[0].header['WH_IRAF1'] == "grism IRshort" &
                 hdulist.header['HN-ARM'] == "ira" ):
                self.specmode = "irs"
            elif ( hdulist[0].header['WH_IRAF1'] == "grism IRlong" &
                   hdulist.header['HN-ARM'] == "ira" ):
                self.specmode = "irl"
            elif ( hdulist[0].header['WH_OPTF1'] == "grism Opt" &
                   hdulist.header['HN-ARM'] == "opt" ):
                self.specmode = "opt"
        hdulist.close()
        
class HonirFileList( object ):
    def __init__( self, date_str='' ):
        self.filelist = []
        self.selectedlist = []
        self.infolist = []
        self.datadir = ""
        self.date = datetime.date.today()
        self.setDate( date_str )
        self.initList()
    def readInfoList( self ):
        files= iter( self.selectedlist )
        for filename in files:
            headerinfo = HeaderInfo()
            self.infolist[ filename ] = headerinfo.readHeaderInfo( filename )
    def initList( self ):
        self.getFileList()
        self.resetSelectedList()
    def addDay( self, diff_day ):
        self.date = self.date + datetime.timedelta( days = diff_day )
        self.setDataDir()
    def setDate( self, date_str ):
        self.date = datetime.datetime.strptime( date_str, "%Y%m%d" )
        self.setDataDir()
    def getDateStr( self ):
        return self.date.strftime("%Y%m%d")
    def setDataDir( self ):
        self.datadir = os.path.join( BASE_DIR, self.getDateStr() )
    def getFileList( self ):
        self.filelist = sorted( glob.glob( os.path.join( self.datadir, "HN*[io][rp][at][0-9][0-9].fits" ) ) )
    def getSelectedList( self ):
        return self.filterdlist
    def resetSelectedList( self ):
        self.selectedlist = copy.deepcopy( self.filelist )
    def selectExpt( self, exptime ):
        self.select( "Expt", exptime )
    def selectObject( self, objname ):
        self.select( "Object", objname )
    def selectObsmode( self, obsmode ):
        self.select( "Obsmode", obsmode )
    def selectArm( self, arm ):
        self.select( "Arm", arm )
    def selectFilter( self, filtername ):
        self.select( "Filter", filtername )
#    def getHduHeader( hdulist, key ):
        return hdulist[0].header[key]
    def select( self, infotype, key1="", key2="" ):
        new_filelist=[]
        files= iter( self.selectedlist )
        for filename in files:
            hdulist = pyfits.open( os.path.join( self.datadir, filename) )
            if infotype == "Object":
                if hdulist[0].header['OBJECT'] == key1 : 
                    new_filelist.append( filename )
            elif infotype == "Obsmode":
                if hdulist[0].header['OBS-MODE'] == key1 :
                    new_filelist.append( filename )
            elif infotype == "Arm":
                if hdulist[0].header['HN-ARM'] == key1 :
                    new_filelist.append( filename )
            elif infotype == "Expt":
                if float( hdulist[0].header['EXPTIME'] ) == float( key1 ) :
                    new_filelist.append( filename )
            elif infotype == "Nprs":
                if int( hdulist[0].header['IRA-NPRS'] ) == int( key1 ):
                    new_filelist.append( filename )
            elif infotype == "SPV":
                if hdulist[0].header['SPV'] == key1 :
                    new_filelist.append( filename )
            elif infotype == "Filter":
                if hdulist[0].header['HN-ARM'] == 'ira' :
                    if hdulist[0].header['WH_IRAF2'] == key1 :
                        new_filelist.append( filename )
                elif hdulist[0].header['HN-ARM'] == 'opt' :
                    if hdulist[0].header['WH_OPTF2'] == key1 :
                        new_filelist.append( filename )
                else:
                    pass
            elif infotype == "SpecMode":
                specmode = key1
                if specmode == "irs":
                    if ( hdulist[0].header['WH_IRAF1'] == "grism IRshort" &
                         hdulist[0].header['HN-ARM'] == "ira" ):
                        new_filelist.append( filename )
                elif specmode == "irl":
                    if ( hdulist[0].header['WH_IRAF1'] == "grism IRlong" &
                         hdulist[0].header['HN-ARM'] == "ira" ):
                        new_filelist.append( filename )
                elif specmode == "opt":
                    if ( hdulist[0].header['WH_OPTF1'] == "grism Opt" &
                         hdulist[0].header['HN-ARM'] == "opt" ):
                        new_filelist.append( filename )
            hdulist.close()
        self.selectedlist = new_filelist

    def chkopt( self ):
        has_opt_flag = False
        files = iter( self.selectedlist )
        for filename in files:
            hdulist = pyfits.open( os.path.join( self.datadir, filename ) )
            if hdulist[0].header['HN-ARM'] == 'opt': 
                has_opt_flag = True
            hdulist.close()
        return has_opt_flag
    def showList( self ):
        files = iter( self.selectedlist )
        for filename in files:
            print filename
    def getExptArray( self, arm ):
        expt_array =[]
        files = iter( self.selectedlist )
        for filename in files:
            hdulist = pyfits.open( os.path.join( self.datadir, filename ) )
            expt = float( hdulist[0].header['EXPTIME'] )
            if expt in expt_array:
                pass
            else:
                if( (arm != "") & (arm != hdulist[0].header['HN-ARM'] )):
                    pass
                else:
                    expt_array.append( expt )
        return expt_array
    def empty( self ):
        self.selectedlist = []
    
    


##################################
# main routine
##################################

def main():
    argvs=sys.argv
    argc= len(argvs)

    date_str = argvs[1]

    datadir= os.path.join( BASE_DIR, date_str )
    if os.path.exists( datadir ) == False :
        print( 'Invalid data dir')
        quit()

    #print len(filelist)
    #files= iter( filelist )

    objname=argvs[2]
    objnames = re.split( r',', objname)
    obsmode=argvs[3]

    #filelist.selectObject( objname )

    list_all = []
    
    for objname in objnames:
        list_object = HonirFileList( date_str )
        print "# OBJECT:" + objname
        list_object.resetSelectedList
        list_object.selectObject( objname )
        list_object.selectObsmode( obsmode )

        print "# Object frames"
        list_object.showList()
        
        #files = iter( filelist.selectedlist )
        #for fn in files:
        #    print fn
    
        # opt image check
        #print filelist.has_opt
        print "# Bias frames"
        hasopt = list_object.chkopt()
        bias_list = HonirFileList( date_str )
        # 
        if hasopt:
            timeout=20
            while timeout > 0 :
                bias_list.initList()
                bias_list.selectArm( 'opt' )
                bias_list.selectObject( "BIAS" )
                #    print bias_list.selectedlist
                #    bias_list.showList()
                if len( bias_list.selectedlist ) != 0:
                    break
                    print( "# ** no bias images found in %s" % bias_list.getDateStr() )
                    print( "# ** Search previous date directory" )
                    bias_list.addDay( -1 )
                    timeout -= 1
        else:
            bias_list.empty()

        bias_list.showList()

        # dark image check
        expt_array = list_object.getExptArray("ira")
        #print u"Dark exposure time: %d" %  expt_array

        darklists =[]
        expts = iter( expt_array )
        for expt in expts:
            darklist = HonirFileList( date_str )
            darklist.selectArm( 'ira' )
            darklist.selectObject( 'DARK' )
            darklist.selectExpt( expt )
            darklists.append( copy.copy( darklist.selectedlist ) )

        print "# Dark frames"
        if len( darklists ) > 0 :
            darklist.showList()

        print "# Compile image names"
        #    darklists =[]    
        list_all.extend( list_object.selectedlist )
        list_all.extend( bias_list.selectedlist )
        if len( darklists ) > 0:
            lists = iter( darklists )
            for elem in lists:
                pass
                list_all.extend( elem )

    print "# Copy Images"
    list_all = sorted( list(set( list_all )) )

    for file in list_all:
        print u"cp %s ." % file
        shutil.copy2( file, "." )

# switching script mode or module mode
if __name__ == '__main__':
    main()

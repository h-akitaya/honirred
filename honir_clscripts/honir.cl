#
#       HONIR REDUCTION CL-script package
#
#       PACKAGE : honir
#
#       2011/08/31      H.Akitaya   Ver. 0.01
#       2011/10/21      H.Akitaya   Ver. 0.02
#       2012/10/19      H.Akitaya   Ver. 0.03
#       2013/01/27      H.Akitaya   Ver. 0.04
#       2013/01/29      H.Akitaya   Ver. 0.05
#       2013/02/04      H.Akitaya   Ver. 0.06
#       2013/02/27      H.Akitaya   Ver. 0.07
#       2013/03/26      H.Akitaya   Ver. 0.08
#       2013/06/08      H.Akitaya   Ver. 0.09
#       2013/06/10      H.Akitaya   Ver. 0.10
#       2013/06/19      H.Akitaya   Ver. 0.12
#       2013/06/24      H.Akitaya   Ver. 0.13
#       2013/07/11      H.Akitaya   Ver. 0.13 : Add hndsubvirgo.cl
#       2013/07/23      H.Akitaya   Ver. 0.14 :
#       2013/12/12      H.Akitaya   Ver. 0.15 : include howossub.cl
#       2014/02/10      H.Akitaya   Ver. 0.20 : 
#       2014/02/19      H.Akitaya   Ver. 0.21 : 
#       2014/03/03      H.Akitaya   Ver. 0.22 : include sffixpix
#       2014/03/18      H.Akitaya   Ver. 0.23 : include hnpcal
#       2014/03/30      H.Akitaya   Ver. 0.24
#       2014/04/07      H.Akitaya   Ver. 0.25 : hnlistgen, etc.
#       2014/04/14      H.Akitaya   Ver. 0.26 : bug fix, etc.
#       2014/04/17      H.Akitaya   Ver. 0.27 : hnpreproc etc.
#       2014/05/09      H.Akitaya   Ver. 0.28 : qlimpol etc.
#       2014/07/17      H.Akitaya   Ver. 0.29 : hngetimcur, getregion
#       2014/07/21      H.Akitaya   Ver. 0.30 : calclimmag
#       2014/11/30      H.Akitaya   Ver. 0.31 : hnmkpflvirgo
#       2014/12/18      H.Akitaya   Ver. 0.32 : hnspecpol2

printf("# package : honir (2014/12/18; Ver 0.32)\n" )

# load required packages
imred
onedspec
generic
rv
twodspec
apextract
crutil
noao
digiphot
apphot
digiphot
apphot
daophot
generic
keep

#--- entry of C-programs and other executable scripts

task    $sed = "$foreign"
task    $xpaset = "$foreign"
task    $sffixpix = "$foreign" # SFITSIO sffixpix
task    $imglimmag = "$foreign" #
task    $simg = "$foreign" #

### Directory of C-programs
  set progdir   = "home$progs/"

#--- entry of CL-script files
  set clscript_dir =  "home$honir_clscripts/"

package honir

task honirinit = clscript_dir$honirinit.cl

task hnpreproc = clscript_dir$hnpreproc.cl

task hntrimccd = clscript_dir$hntrimccd.cl
task hntrimvirgo = clscript_dir$hntrimvirgo.cl
#task hnbsub_ccd = clscript_dir$hnbsub_ccd.cl
task hnbsubccd = clscript_dir$hnbsubccd.cl
#task hntrimccd_y2500 = clscript_dir$hntrimccd_y2500.cl

#task hnflattenvirgo = clscript_dir$hnflattenvirgo.cl
task hnflatten = clscript_dir$hnflatten.cl
task hndsubvirgo = clscript_dir$hndsubvirgo.cl
#task hnskysubvirgo = clscript_dir$hnskysubvirgo.cl
task hnskysub = clscript_dir$hnskysub.cl
task hnstack = clscript_dir$hnstack.cl

task vgntest = clscript_dir$vgntest.cl

task hntrimvswp1 = clscript_dir$hntrimvswp1.cl
task hntrimcswp1 = clscript_dir$hntrimcswp1.cl

#task hnmkimgflat_virgo = clscript_dir$hnmkimgflat_virgo.cl
task hnbpfixvirgo = clscript_dir$hnbpfixvirgo.cl
task hnmkflatvirgo = clscript_dir$hnmkflatvirgo.cl
task hnmkpflvirgo = clscript_dir$hnmkpflvirgo.cl
task hnmkdarkvirgo = clscript_dir$hnmkdarkvirgo.cl
task hnmkimgflat_ccd = clscript_dir$hnmkimgflat_ccd.cl
task hnmkbias = clscript_dir$hnmkbias.cl

task qlimgvirgo = clscript_dir$qlimgvirgo.cl
task qldiffvirgo = clscript_dir$qldiffvirgo.cl
task qlphot = clscript_dir$qlphot.cl
task qlphot_old = clscript_dir$qlphot_old.cl
task qlpsfphot = clscript_dir$qlpsfphot.cl
task psfsub = clscript_dir$psfsub.cl
task hnskycombine = clscript_dir$hnskycombine.cl
task hnmskycomb = clscript_dir$hnmskycomb.cl
task hnmkskygrp = clscript_dir$hnmkskygrp.cl

task hnspecred = clscript_dir$hnspecred.cl
task hnmarknod = clscript_dir$hnmarknod.cl
task hnoediv = clscript_dir$hnoediv.cl
task apstr = clscript_dir$apstr.cl

task hnlistgen = clscript_dir$hnlistgen.cl

#spectroscopy
task hnnodsub = clscript_dir$hnnodsub.cl
task hnmknodlists = clscript_dir$hnmknodlists.cl

#polarimetry
task hnpcal = clscript_dir$hnpcal.cl
task hnxyout = clscript_dir$hnxyout.cl
task hnspecpol1 = clscript_dir$hnspecpol1.cl
task hnspecpol2 = clscript_dir$hnspecpol2.cl
task qlimpol= clscript_dir$qlimpol.cl

task ditherrotsub = clscript_dir$ditherrotsub.cl

task extrm = clscript_dir$extrm.cl
task extsrm = clscript_dir$extsrm.cl
task mkoffcoordlst = clscript_dir$mkoffcoordlst.cl

task $thoriinduc = clscript_dir$thoriinduc.cl
task $getimcur = clscript_dir$getimcur.cl
task $hngetimcur = clscript_dir$hngetimcur.cl
task $getregion = clscript_dir$getregion.cl
task objposfind = clscript_dir$objposfind.cl
task erasecosray = clscript_dir$erasecosray.cl
task calclimmag = clscript_dir$calclimmag.cl

task $howossub = clscript_dir$howossub.cl


clbye()

# end

#!/bin/sh
if [ $# -lt 1 ]; then
    echo "Usage: simg [file name]"
    exit
fi

fullfilename=$(cd $(dirname $1) && pwd)/$(basename $1)

if [ -e ${fullfilename} ]; then
    xpaset -p ds9 file ${fullfilename}
else
    echo "${fullfilename} not found !"
fi
# end

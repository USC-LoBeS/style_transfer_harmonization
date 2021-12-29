#!/bin/sh

DPATH=$1
SPATH=$2
CASES=$3

echo $CASES
       
for CASE in `cat ${CASES}`;do

echo $CASE
echo $DPATH 

gunzip ${DPATH}/${CASE}.nii.gz
binary/nii2mnc ${DPATH}/${CASE}.nii ${DPATH}/${CASE}.mnc

binary/mincresample -trilinear -nelements 256 256 256 -start -100 -120 -90 -step 0.8 0.8 0.8 ${DPATH}/${CASE}.mnc ${SPATH}/${CASE}_ds.mnc -clobber

binary/mnc2nii ${SPATH}/${CASE}_ds.mnc ${SPATH}/${CASE}_ds.nii

gzip ${SPATH}/${CASE}_ds.nii

rm ${SPATH}/${CASE}_ds.mnc
rm ${DPATH}/${CASE}.mnc

done


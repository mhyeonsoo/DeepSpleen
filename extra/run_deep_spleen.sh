#!/bin/bash

start=$(date +%s.%N)
# dicom to nifty
#rm -r /OUTPUTS/*
#mkdir /OUTPUTS/dicom2nifti
#/extra/dcm2nii -a y -r n -o /OUTPUTS/dicom2nifti/ /INPUTS/
#mv /OUTPUTS/dicom2nifti/*.nii.gz /OUTPUTS/dicom2nifti/target_img.nii.gz 

# reorient to standard before processing
./extra/fslreorient2std /OUTPUTS/dicom2nifti/*

# preprocessing for spleen
./extra/preprocessing
dur=$(echo "$(date +%s.%N) - $start" | bc)
printf "preprocessing time: %.6f seconds\n" $dur

start=$(date +%s.%N)
# generate deep segmentation
/root/miniconda/bin/python /extra/python/segment_test.py --model_name=model_spleen --network=206 --batchSize_lmk=4 --viewName=view3 --loss_fun=cross_entropy --lmk_num=2 
dur=$(echo "$(date +%s.%N) - $start" | bc)
printf "segmentation time: %.6f seconds\n" $dur

start=$(date +%s.%N)
#postprocessing for spleen
./extra/postprocessing

#generate pdf file
./extra/generate_pdf
#convert -density 600 OUTPUTS/FinalResult/result.pdf -quality 100 OUTPUTS/FinalResult/result.jpg

dur=$(echo "$(date +%s.%N) - $start" | bc)
printf "postprocessing time: %.6f seconds\n" $dur
#clean up
# rm -r /OUTPUTS/Data_2D
# rm -r /OUTPUTS/DeepSegResults
# rm -r /OUTPUTS/dicom2nifti
# rm -r /OUTPUTS/FinalSeg
# rm -r /OUTPUTS/FinalResult/tmp

<img align="right" width="180" height="150" src="https://github.com/moonh1/DeepSpleen/blob/master/extra/masilablogo.jpg">

# *DeepSpleen*

Clinical trial Spleen Segmentation pipeline using Deep learning

--------------------------------------------------------------------------------------------------------------

## *General procedures*
##### **Data Uploading & Storage**
(Optional Process for storage)
1. Getting Dicom clinical trial files
2. Automated dicom push access to xnat server 
3. Quality assurance for purposes

##### **Preprocessing**
4. Image resampling, format converting with preprocessing

     [preprocessing](https://github.com/moonh1/DeepSpleen/tree/master/matlab/prepro_spleen)

##### **Segmentation**
5. Running 'segmentation' using Convolutional neural network

     [Segmentation](https://github.com/moonh1/DeepSpleen/tree/master/extra/python)

##### **Postprocessing & Making PDF Views**
6. Resampling into original dimension, postprocessing afterwards

     [postprocessing](https://github.com/moonh1/DeepSpleen/tree/master/matlab/postpro_spleen)
  
7. Show PDF file for demonstration

     [pdfprocessing](https://github.com/moonh1/DeepSpleen/tree/master/matlab/makepdf_spleen)


--------------------------------------------------------------------------------------------------------------

## XNAT_Upload
send_disk bash script is an initial function for transferring dicom image to XNAT.
send_disk also includes process for commenting dicom header with 'Patient Comments' field for locating XNAT project directory. Data uploading process and overall pipeline are not exactly connected, so it needs to be improved as one combined procedure in the future. Python functions comment.py and storescu.py are for this process.

## extra
extra directory includes all the binary files from matlab codes to run on docker, and also the deep-lenaring python functions.
run_deep_spleen.sh script is called to run pipeline on docker.
each matlab process is converted into binary file with mcc command that should be typed in the matlab with sudo permit.

[fsl_510_eddy_511](https://github.com/moonh1/DeepSpleen/tree/master/extra/fsl_510_eddy_511) has newest version (measured on 1/18/2017) of fsl from standford. among fsl libraris, fslreorient2std and functions being called on it will be used to rotate input data into same orientation on purpose.

python directory has functions for learning-process, with the evaluating trained model on test dataset.

## matlab
matlab directory is largely composed with three procedures.
1. Pre-processing functions.
   - For training the data, you need to resample the original testsets according to the Network and trained model that you       want to use. Since every network has different dimensions of models, you have to make a function that deals with the         process.
    Besides, importantly, the input data going into segmentation function should be 2D images. So you can slice 3D nii files     into 2D images. (Both training and test set)

2. Post-processing functions.
   - After having segmentation result, we have to check wheter segmentation has been conducted well or not. For this, Post-       processing functions will play a role. You can get the final segmentation 3D nii files whose dimensions are exactly same as very-original files. The number of views you used will be merged into one 3D rengering image. If the segmentation was done perfectly, when you overlay the result nii files on the original nii files, you could see the segmented organ on the correct field of abdomen.

3. makepdf_spleen functions.
   - After post-processing step, we make output result as pdf documents so that the clinicians more easily demonstrate it. Generated result cannot be used as clinical purpose, but can be utilized as demonstration purpose.
   

--------------------------------------------------------------------------------------------------------------

## Docker
Docker is for making whole pipeline processes to be an image (not a real 'image') togehter.
For running pipeline, there exist a bunch of requirements and pre-installation process needed. These required packages oftenly could be more than some gigabytes, so that it takes lot of time and memories for user to search those packages and install them by theirselves.
Docker can reduce those time first of all. As a '[Dockerfile](https://github.com/moonh1/DeepSpleen/blob/master/Dockerfile)' shows, all the packages, softwares and even Operating Systems can be pre-included into this file. those 'pre-installed on the docker image' packages are stored on the [Dockerhub](https://hub.docker.com/) being managed by Amazon. Once the user build a docker and run it using docker command, they can get directly the result pdf demonstrations they need.

--------------------------------------------------------------------------------------------------------------

## Sample Output PDF
![](image/Scan_1.png)

(Optional) whole body segmentation: [pdfview_2.1.pdf](https://github.com/moonh1/Abdomen_seg_Pipeline/files/1584726/pdfview_2.1.pdf)


--------------------------------------------------------------------------------------------------------------

## History
- Dec 11, 2017
  - [x] Manual XNAT access 
  - [x] separated function calls and results

- Jan 18, 2018
  - [x] Added docker image to merge whole process
  - [x] Splitted pre & post processing functions
  - [x] No more need to install packages (Only have to build docker)

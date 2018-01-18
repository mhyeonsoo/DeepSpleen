% % % set the target filename
% orig_dir = '/share4/huoy1/RSNA/docker/OUTPUTS/dicom2nifti';
% input_dir = '/share4/huoy1/RSNA/docker/OUTPUTS/FinalSeg/keeplarge1_morpho1/GCN/cross_entropy/';
% % set the directory where all of the output information will be stored
% output_dir = '/share4/huoy1/RSNA/docker/OUTPUTS/FinalResult';

% set the target filename
orig_dir = '/OUTPUTS/dicom2nifti';
input_dir = '/OUTPUTS/FinalSeg/keeplarge1_morpho1/GCN/cross_entropy/';
% set the directory where all of the output information will be stored
output_dir = '/OUTPUTS/FinalResult';


% set the target filename
% input_dir = '/share4/huoy1/RSNA/docker/OUTPUTS/dicom2nifti';
% % set the directory where all of the output information will be stored
% output_dir = '/share4/huoy1/RSNA/docker/OUTPUTS/Data_2D';

% set the input directory where everything is installed
% import_dir = '/extra/fun_for_prepostProcessing/';

% set the important directories for running each component
%in_opts.niftyreg_loc = [in_dir, 'niftyreg/bin/'];
%in_opts.ants_loc = [in_dir, 'ANTs-bin/'];
%in_opts.atlas_loc = [in_dir, 'atlas-processing/'];
%in_opts.mni_loc = [in_dir, 'MNI/'];
%in_opts.mipav_loc = [in_dir, 'mipav/'];
%in_opts.ticv_atlas_loc = [in_dir, 'atlas-ticv/'];
%in_opts.ticv_atlas_type = 'BC1';
disp('Start Generating Results...');
try
    % run the pipeline
    makePDFviews(orig_dir,input_dir,output_dir);
catch e
    getReport(e)
end
disp('Finish Generating Results...');
exit

function oneviews_into_nifti(orig_dir,input_dir,output_dir)
% clc;clear;close all;
% tic
% addpath(genpath('/fs4/masi/hyeonsoo/code/'));
% addpath(genpath('/fs4/masi/huoy1/FS3_backup/software/full-multi-atlas/masi-fusion/src'));
% addpath('/fs4/masi/huoy1/FS3_backup/masimatlab/trunk/users/xuz8/ext/');
% addpath('/fs4/masi/huoy1/FS3_backup/masimatlab/trunk/users/xuz8/src/');

%output_root_accre_dir = '/fs4/masi/hyeonsoo/evaluate/EVAL_Resnet9block'; % output file
output_root_accre_dir = output_dir; % output file

orig_img_dir = orig_dir;  % before resample
resample_img_dir = orig_dir;   % we don't use resampled nifty

orig_img_files = get_fnames_dir(orig_img_dir,'*.nii.gz');
img_files = get_fnames_dir(resample_img_dir,'*.nii.gz');

% opts.printplot = 0;
% opts.cmap_mat='/fs4/masi/huoy1/FS3_backup/software/masimatlab/SpleenSeg_Localized/organ_cmap.mat';

% run_method = 'single';

large_morpho = [1 1];

% epochs = 7;
epochs = 4;

c = 1;

test(c).name = 'GCN';
test(c).path = input_dir;  %the deep learning output folder
% test(c).measure = 'Dice_norm';
test(c).measure = 'cross_entropy';
c = c+1;


for li = 1:size(large_morpho,1)
    opts.ifkeeplarge = large_morpho(li,1);
    opts.morphotype = large_morpho(li,2);
    
    output_dir_name = sprintf('keeplarge%d_morpho%d',opts.ifkeeplarge,opts.morphotype);
    output_root_dir = [output_root_accre_dir filesep output_dir_name];
    
    for ei = epochs
        
        epoch_name = '';
        
        for ti = 1:length(test)
            test_name = test(ti).name;
            test_dir = test(ti).path;
            test_measure = test(ti).measure;
            
            result_dir = [test_dir filesep test_measure filesep 'seg_output' filesep epoch_name];
            output_dir = [output_root_dir filesep test_name filesep test_measure filesep epoch_name];
            
            
            for ii = 1:length(img_files)
                
                orig_img_file = orig_img_files{ii};
                resampled_img_file = img_files{ii};
               
                subName = get_basename(resampled_img_file);
                
                result_sub_dir = [result_dir filesep subName];
                output_sub_dir = [output_dir filesep subName];
                try
                    if ~isdir(output_sub_dir);mkdir(output_sub_dir);end;
                catch
                    fprintf('opps %s\n',output_sub_dir);
                    continue;
                end
                            
                result_view_seg = [result_sub_dir filesep sprintf('%s_view3.nii.gz',subName)];
                
                combine_test_seg_HS(resampled_img_file,orig_img_file,result_view_seg,output_sub_dir,'view3',opts);
        
            end
        end
    end
end

% toc
end


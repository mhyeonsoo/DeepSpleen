% clc;clear all;close all;
% 
% seg_file = '/share4/huoy1/hen1538/seg_view3_orig_seg_man.nii.gz';
% estimate_spleen_by_lines(seg_file,1);
d = '/share4/hyeonsoo/SegPipeline/Dataset/OUTPUTS/';

subjects = dir(d);
count = 1;
for jS = 3:length(subjects)
    if(subjects(jS).isdir)
        %if isdir([dout subjects(jS).name])
        %else
        dd = [d subjects(jS).name filesep];
        
        scans = dir(dd);
        for jSS = 3:length(scans)
            disp([subjects(jS).name scans(jSS).name])
            if(scans(jSS).isdir)
                ddd = [dd scans(jSS).name filesep];
                f = dir([ddd 'dicom2nifti']);
                nii = load_untouch_nii_gz([ddd 'dicom2nifti' filesep f(3).name]);
                f = dir([ddd 'FinalSeg' filesep 'keeplarge1_morpho1' filesep 'GCN' filesep 'cross_entropy' filesep 'target_img' filesep '*man*']);
                if(length(f)<1)
                    f = dir([ddd 'FinalSeg' filesep 'keeplarge1_morpho1' filesep 'GCN' filesep 'cross_entropy' filesep 'target_img' filesep '*orig*']);
                end
                segfile = [ddd  'FinalSeg' filesep 'keeplarge1_morpho1' filesep 'GCN' filesep 'cross_entropy' filesep 'target_img' filesep f(1).name];
                [Vol_L,Vol_W,Vol_T,Vol_LDT,L,W,T,si]= estimate_spleen_by_lines(segfile,1);
%                 VolL(count) = Vol_L
%                 VolT(count) = Vol_T
%                 VolD(count) = Vol_W
%                 VolLDT(count) = Vol_LDT
                Length(count) = L;
                Thickness(count) = T;
                Depth(count) = W;
                count = count + 1;
                %                 if isdir([ddout filesep scans(jSS).name])
                %                 else
                %                     mkdir([ddout filesep scans(jSS).name]);
                %                     dddd = [ddout filesep scans(jSS).name];
                %
            end
        end
    end
end

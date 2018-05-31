% rawpath = '/share4/hyeonsoo/SegPipeline/Dataset/OUTPUTS/01-120-C5D1/201_NON_CONTRAST_iDose/dicom2nifti/target_img.nii.gz';
% locpath = '/share4/hyeonsoo/SegPipeline/Dataset/OUTPUTS/01-120-C5D1/201_NON_CONTRAST_iDose/FinalSeg/keeplarge1_morpho1/GCN/cross_entropy/target_img/seg_view3_orig_seg.nii.gz';
% 
% raw_nii = load_untouch_nii_gz(rawpath);
% raw_img = raw_nii.img;
% raw_hdr = raw_nii.hdr;
% 
% [slice_num] = draw_LDT(locpath,uint8(raw_img),1);
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
                im_save= draw_LDT(segfile,nii,1);
                filename = [subjects(jS).name '-' scans(jSS).name];
                imwrite(im_save,sprintf('/home/local/VANDERBILT/moonh1/Pictures/LDT3/%s',filename),'jpeg');
                count = count + 1;

            end
        end
    end
end
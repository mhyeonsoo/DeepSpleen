function prepare_organ_segmentation(input_dir,output_dir)

% addpath(genpath('/share4/hyeonsoo/SegPipeline/extra/fun_for_prepostProcessing'));
% addpath(genpath('/fs4/masi/huoy1/FS3_backup/software/full-multi-atlas/masi-fusion/src'));
% addpath('/fs4/masi/huoy1/FS3_backup/masimatlab/trunk/users/xuz8/ext/');
% addpath('/fs4/masi/huoy1/FS3_backup/masimatlab/trunk/users/xuz8/src/');

% Paths.
rawimg_CT_test_root_dir = input_dir;
rawimg_CT_test_output_dir = output_dir;

view = 'view3';

% Making 2D sliced test images.
generate_2D(rawimg_CT_test_root_dir,rawimg_CT_test_output_dir,view);    


end


function generate_2D(resample_img_dir,output_root_dir,view)

if ~isdir(output_root_dir);mkdir(output_root_dir);end;
output_dir = [output_root_dir];

output_img_dir = [output_dir filesep 'img'];
IfNorm = 1;

if ~isdir(output_img_dir);mkdir(output_img_dir);end;

img_files = get_fnames_dir(resample_img_dir,'*.nii.gz');

for i = 1:length(img_files)
    img_file = img_files{i};
    
    subName = get_basename(img_file);
    
    finish_flag1 = [output_img_dir filesep subName filesep 'view3' filesep 'slice_0040.png'];
    
    if ~exist(finish_flag1)
        img_nii = load_untouch_nii_gz(img_file);
        img_img = double(img_nii.img);
        img_img = img_img + img_nii.hdr.dime.scl_inter;
        
        save_2d_images_HS(output_img_dir,img_img,IfNorm,subName,view);
    end
end

end

function save_2d_images_HS(output_img_dir,img_img,IfNorm,subName,view)

if nargin<5
    view = 'view3';
end

[row col slice] = size(img_img);

% subName = sprintf('sub_%04d',i);



img_img(img_img>1000) = 1000;
img_img(img_img<-1000) = -1000;

min1=-1000;
max1=1000;

if strcmp(view,'viewall')
    view1_dir = [output_img_dir filesep subName filesep 'view1'];
    if ~isdir(view1_dir);mkdir(view1_dir);end;
    for ri = 1:row
        output_name = [view1_dir filesep sprintf('slice_%04d.png',ri)];
        if ~exist(output_name)
            img_2D = squeeze(img_img(ri,:,:));
            if IfNorm == 1
                img_2D = uint8(floor(((img_2D-min1).*255)./(max1-min1)));
            elseif IfNorm == 0
                img_2D = uint8(img_2D);
            elseif IfNorm == 2
                img_2D = uint8(img_2D==1);
            end
            imwrite(img_2D,output_name);
        end
    end

    view2_dir = [output_img_dir filesep subName filesep 'view2'];
    if ~isdir(view2_dir);mkdir(view2_dir);end;
    for ci = 1:col
        output_name = [view2_dir filesep sprintf('slice_%04d.png',ci)];
        if ~exist(output_name)
            img_2D = squeeze(img_img(:,ci,:));
            if IfNorm == 1
                img_2D = uint8(floor(((img_2D-min1).*255)./(max1-min1)));
            elseif IfNorm == 0
                img_2D = uint8(img_2D);
            elseif IfNorm == 2
                img_2D = uint8(img_2D==1);
            end
            imwrite(img_2D,output_name);
        end
    end
end

view3_dir = [output_img_dir filesep subName filesep 'view3'];
if ~isdir(view3_dir);mkdir(view3_dir);end;
for si = 1:slice
    output_name = [view3_dir filesep sprintf('slice_%04d.png',si)];
    if ~exist(output_name)
        img_2D = squeeze(img_img(:,:,si));
        if IfNorm == 1
            img_2D = uint8(floor(((img_2D-min1).*255)./(max1-min1)));
        elseif IfNorm == 0
            img_2D = uint8(img_2D);
        elseif IfNorm == 2
            img_2D = uint8(img_2D==1);
        end
        imwrite(img_2D,output_name);
    end
end


end








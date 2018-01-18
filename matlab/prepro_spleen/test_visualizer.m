function dv = prepare_corrected_slices(input_dir,output_dir)
%% Set environment
%addpath(genpath('~/masimatlab/trunk/users/blaberj/matlab/justinlib_v1_7_0'));
%addpath('~/masimatlab/trunk/users/blaberj/dwmri_libraries/dwmri_visualizer_v1_2_0/');
addpath('functionJ/niftilib/');
addpath('functionJ/NIFTI/');
addpath('functionJ/matlablib/');
addpath('functionJ/vollib');

%% Plot slices
input_dir = '/share4/hyeonsoo/SegPipeline/docker_spleen/OUTPUTS/dicom2nifti/';
output_dir = '/share4/hyeonsoo/SegPipeline/docker_spleen/OUTPUTS/spatial_corrected';
output_img_dir = [output_dir filesep 'img'];
if ~isdir(output_img_dir);mkdir(output_img_dir);end;
img_files = get_fnames_dir(input_dir,'*.nii.gz');

for ii = 1:length(img_files)
    img_file = img_files{ii};
    img_vol = nifti_utils.load_untouch_nii_vol_scaled(img_file,'double');
    xform_RAS = nifti_utils.get_voxel_RAS_xform(img_file);
    
    subName = get_basename(img_file);
    view = 'view3';
    
    [x,y,z] = size(img_vol);
    % axial scan input
    if xform_RAS == [-1  0   0; ...
                     0   1   0; ...
                     0   0   1]
        z = z;
    % coronal scan input             
    elseif xform_RAS == [-1  0   0; ... 
                         0   0  -1; ...
                         0   1   0]
        z = y;
    % sagittal scan input
    else
        z = x;
    end
    
    % Get visualizer
    dv = dwmri_visualizer([],...
        img_vol, ...
        img_vol, ...
        xform_RAS, ...
        'vol');
    
     for i = 1:z
        %         % Make a plot
        %         figure(ii)
        %
        %         dv.plot_slice(68,'axial','slice',[],subplot(1,3,1));
        %         title('axial')
        %         axis on
        %         ylabel('L')
        %         xlabel('P')
        %
        %         dv.plot_slice(256,'coronal','slice',[],subplot(1,3,2));
        %         title('coronal')
        %         axis on
        %         ylabel('L')
        %         xlabel('I')
        %
        %         dv.plot_slice(256,'sagittal','slice',[],subplot(1,3,3));
        %         title('sagittal')
        %         axis on
        %         ylabel('P')
        %         xlabel('I')
        
        bg_slice = dv.get_slice_in_plot_orientation(i,img_vol,'axial');
        mask_slice = dv.get_slice_in_plot_orientation(i,img_vol,'axial');
        left1 = 1;
        right1 = size(mask_slice,2);
        top1 = 1;
        bottom1 = size(mask_slice,1);
        
        bg_slice(bg_slice>1000) = 1000;
        bg_slice(bg_slice<-1000) = -1000;
        mask_slice(mask_slice>1000) = 1000;
        mask_slice(mask_slice<-1000) = -1000;
        
        min1=-1000;
        max1=1000;
        bg_slice = (bg_slice-min1)/(max1-min1);
        mask_slice = (mask_slice-min1)/(max1-min1);
        
        view_dir = [output_img_dir filesep subName filesep view];
        if ~isdir(view_dir);mkdir(view_dir);end
        output_name = [view_dir filesep sprintf('slice_%04d.png',i)];
        
        bg_slice = imrotate(bg_slice,-90);
        imwrite(bg_slice,output_name);
        
     end    
end



% figure(ii+2);
% imagesc(bg_slice1(top1:bottom1,left1:right1,5),[0 1]);colormap(gray);
%
% figure(ii+3);
% imagesc(bg_slice2(top2:bottom2,left2:right2,5),[0 1]);colormap(gray);


% % Make a plot
% figure(1)
%
% dv.plot_slice(256,'axial','slice',[],subplot(1,3,1));
% title('axial')
% axis on
% ylabel('L')
% xlabel('P')
%
% dv.plot_slice(68,'coronal','slice',[],subplot(1,3,2));
% title('coronal')
% axis on
% ylabel('L')
% xlabel('I')
%
% dv.plot_slice(256,'sagittal','slice',[],subplot(1,3,3));
% title('sagittal')
% axis on
% ylabel('P')
% xlabel('I')


end
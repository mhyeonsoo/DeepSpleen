function combine_test_seg_HS(resampled_img,orig_file,result_view_seg,output_sub_dir,view,opts)
seg_output_file = [output_sub_dir filesep sprintf('seg_%s.nii.gz',view)];
orig_nii = load_untouch_nii_gz(orig_file);
[ny nx nz] = size(orig_nii.img);

if ~exist(seg_output_file)
    template_nii = load_untouch_nii_gz(resampled_img);
    template_nii.hdr.dime.datatype = 2;
    template_nii.hdr.dime.bitpix = 8;
    template_nii.hdr.dime.glmax = 3;
    template_nii.hdr.dime.glmin = 0;
    template_nii.hdr.dime.scl_inter = 0;
    
    [my mx mz] = size(template_nii.img);
    
    raw_seg_file = result_view_seg;
    raw_nii = load_untouch_nii_gz(raw_seg_file);
    seg_output = raw_nii.img;
    
    %remove other labels
    seg_output(seg_output>3) = 0;
    seg_output = seg_output(:,:,1:nz);
    
    seg_show = seg_output*0;
    ui = 1;
    seg_output_one =seg_output==ui;
    seg_output_one = img_processing(seg_output_one,opts);
    seg_output_one = img_processing2(seg_output_one,opts);
    seg_show(seg_output_one == 1) = ui;
    
    output_nii = template_nii;
    %output_nii.img = seg_show;
    
    im = seg_show; %%% input image
    [y x z]=...
        ndgrid(linspace(1,size(im,1),my),...
        linspace(1,size(im,2),mx),...
        linspace(1,size(im,3),mz));
    imOut=interp3(im,x,y,z,'nearest');
    output_nii.img = imOut;
    %     save_untouch_nii_gz(seg_orig_nii,seg_orig_file);
    save_untouch_nii_gz(output_nii,seg_output_file);
end

%add labels
merged_seg = seg_output_file;

%inverse registration
file_bname = get_basename(merged_seg);
seg_orig_file = [output_sub_dir filesep file_bname '_orig_seg.nii.gz'];
seg_resample_nii = load_untouch_nii_gz(merged_seg);
seg_orig_nii = orig_nii;
seg_orig_nii.hdr.dime.datatype = 2;
seg_orig_nii.hdr.dime.bitpix = 8;
seg_orig_nii.hdr.dime.glmax = 3;
seg_orig_nii.hdr.dime.glmin = 0;
seg_orig_nii.hdr.dime.scl_inter = 0;
im=seg_resample_nii.img; %%% input image

[y x z]=...
    ndgrid(linspace(1,size(im,1),ny),...
    linspace(1,size(im,2),nx),...
    linspace(1,size(im,3),nz));
imOut=interp3(im,x,y,z,'nearest');
seg_orig_nii.img = imOut;
save_untouch_nii_gz(seg_orig_nii,seg_orig_file);

end

function img = Get_largest_Connect(img)

CC = bwconncomp(img,26);

ratio = 0.5;
CCsizes = cellfun(@length,CC.PixelIdxList);
MaxSize = max(CCsizes);
cw = 15; %center window

for ci = 1:length(CC.PixelIdxList)
    if CCsizes(ci) < MaxSize*ratio
        img(CC.PixelIdxList{ci})=0;
    end
end

end


function img = img_processing(img,opts)
if opts.morphotype >0
    se = strel('sphere', opts.morphotype);
    img = imdilate(img,se);
end
if opts.ifkeeplarge ==1
    img = Get_largest_Connect(img);
end
if opts.morphotype>0
    img = imerode(img,se);
end

end



function img = img_processing2(img,opts)
se = strel('sphere', opts.morphotype);
if opts.morphotype>0
    img = imerode(img,se);
end

if opts.ifkeeplarge ==1
    img = Get_largest_Connect(img);
end

if opts.morphotype >0
    img = imdilate(img,se);
end

end
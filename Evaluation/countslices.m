d = '/share4/huoy1/CycleAbdomen/CT_testing/seg/';
subjects = dir(d);
count = 1;
for jS = 3:length(subjects)
    seg_nii = load_untouch_nii_gz([d subjects(jS).name]);
    seg_img = seg_nii.img;
    seg_hdr = seg_nii.hdr;
    
    dim = seg_hdr.dime.dim(2:4);
    pixdim = seg_hdr.dime.pixdim(2:4);
    L = sum(seg_img(seg_img==1))/1000
%     spleen_z_voxel_num = squeeze((sum(sum(seg_img))));
%     L = sum(spleen_z_voxel_num>0).*pixdim(3)/10;
    volarr(count) = L;
    count = count +1;
end

d = '/fs4/masi/yaoy4/rawdata/rawlabel/train/';
subjects = dir(d);
for jS = 3:length(subjects)
    seg_nii = load_untouch_nii_gz([d subjects(jS).name]);
    seg_img = seg_nii.img;
    seg_hdr = seg_nii.hdr;
    
    dim = seg_hdr.dime.dim(2:4);
    pixdim = seg_hdr.dime.pixdim(2:4);
    
%     spleen_z_voxel_num = squeeze((sum(sum(seg_img))));
%     L = sum(spleen_z_voxel_num>0).*pixdim(3)/10;
    L = sum(seg_img(seg_img==1))/1000
    volarr(count) = L;
    count = count +1;
end

figure;
hist(volarr,30);
title('Spleen voulume distribution of Training dataset');
xlabel('Volume(cc)');
ylabel('The number of the scans');

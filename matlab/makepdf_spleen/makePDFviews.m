function makePDFviews(orig_dir,input_dir,output_dir)
% addpath(genpath('/fs4/masi/huoy1/FS3_backup/software/full-multi-atlas/masi-fusion/src'));
% addpath('/fs4/masi/hyeonsoo/code/makeview');
rawfn_path = orig_dir;
%segfn_path = '/fs4/masi/hyeonsoo/evaluate/EVAL_Resnet9block/keeplarge1_morpho1_good_result_backup/GCN/cross_entropy/epoch_0005';
segfn_path = input_dir;
% cmap_mat = '/fs4/masi/huoy1/FS3_backup/software/masimatlab/SpleenSeg_Localized/organ_cmap.mat';
if ~isdir(output_dir);mkdir(output_dir);end;
tmp_dir = [output_dir filesep 'tmp'];
if ~isdir(tmp_dir);mkdir(tmp_dir);end;
proj_name = 'DeepSpleenSeg';
subj_name = 'target_img';
expr_name = 'target_img';

spider_name = 'DeepSpleenSeg';

cmap = [1.0000         0         0; ...
    1.0000    1.0000         0; ...
         0    1.0000         0; ...
         0    0.9804    0.6039; ...
    0.1176    0.5647    1.0000; ...
    0.2941         0    0.5098; ...
    1.0000         0    1.0000; ...
    0.6275    0.3216    0.1765; ...
    0.8549    0.6471    0.1255; ...
         0    0.5020         0; ...
    0.1255    0.6980    0.6667; ...
    0.2549    0.4118    0.8824; ...
    0.5412    0.1686    0.8863];

rawfiles = get_fnames_dir(rawfn_path,'*.nii.gz');
for i = 1:length(rawfiles)
    rawfile = rawfiles{i};
    seghome_dir = get_basename(rawfile);
    segfile = [segfn_path filesep seghome_dir filesep 'seg_view3_orig_seg.nii.gz'];
    %segfile = [segfn_path filesep 'seg_view3_orig_seg_manual.nii.gz'];
    pdfname = [output_dir filesep sprintf('result%d.pdf',i)];
    scan_name = sprintf('Scan%d',i);
    generate_spleenseg_pdf_hs(rawfile, segfile, pdfname, cmap,...
    tmp_dir,proj_name, subj_name, expr_name, scan_name, spider_name, i, length(rawfiles))
end

end
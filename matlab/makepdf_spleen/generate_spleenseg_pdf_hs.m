function generate_spleenseg_pdf_hs(rawfn, segfn, pdffn, cmap,...
    tmp_dir,proj_name, subj_name, expr_name, scan_name, spider_name, filenum, totalnum)
% GENERATE_SPLEENSEG_PDF - Generates the summary PDF for spleen
%                           segmentation
%
% Input: rawfn - the raw (intensity image filename -- .nii.gz)
%        segfn - the estimated segmentation -- .nii.gz
%        pdffn - the final pdf filename
%        cmap_mat - the colormap of abdominal organs
%        tmp_dir - the directory to store temporary output
%        proj_name - the name of the project
%        subj_name - the name of the subject
%        expr_name - the name of the experiment
%        scan_name - the name of the scan
%        spider_name - the name of the spider
% Output: None.
%
% Zhoubing Xu, Sep 2015

% parameters
CLIM=[-200,200];
alpha=0.5;
alpha_bg=0.05;
alpha_organ=0.5;
organs={'spleen'};


% load colormap
cm=cat(1,[0,0,0],cmap);

% load images
RawNii=load_untouch_nii_gz(rawfn);
RawNii.img=double(RawNii.img+RawNii.hdr.dime.scl_inter);
SegNii=load_untouch_nii_gz(segfn);
voxdim=RawNii.hdr.dime.pixdim(2:4);
ar_axi=[1 voxdim(1)/voxdim(2) 1];
ar_cor=[1 voxdim(1)/voxdim(3) 1];
ar_sag=[1 voxdim(2)/voxdim(3) 1];
ar=1./voxdim;

% select slices to show
Lim=SegNii.img==1;
[ix,iy,iz]=ind2sub(size(Lim),find(Lim>0));

% sagittal
cx=median(ix);
img=rot90(squeeze(RawNii.img(cx,:,:)));
seg=rot90(squeeze(SegNii.img(cx,:,:)));
img=max(0,min(1,double(img-CLIM(1))/(CLIM(2)-CLIM(1))));
img_rgb=repmat(img,[1 1 3]);
seg_rgb=ind2rgb(uint8(seg==1),cm);
overlayim=alpha*img_rgb+(1-alpha)*seg_rgb;
fig=figure(filenum+totalnum);
%fig=figure(2);
imagesc(overlayim);
set(fig,'color','k');
set(fig,'units','pixels','position',[0 0 560 420]);
set(gca, 'Units', 'normalized', 'Position', [0 0 1 1]);
axis off;daspect(ar_sag);drawnow;
im_sag=frame2im(getframe(fig));

% coronal
cy=median(iy);
img=rot90(squeeze(RawNii.img(:,cy,:)));
seg=rot90(squeeze(SegNii.img(:,cy,:)));
img=max(0,min(1,double(img-CLIM(1))/(CLIM(2)-CLIM(1))));
img_rgb=repmat(img,[1 1 3]);
seg_rgb=ind2rgb(uint8(seg==1),cm);
overlayim=alpha*img_rgb+(1-alpha)*seg_rgb;
fig=figure(filenum+totalnum);
%fig=figure(2);
imagesc(overlayim);
set(fig,'color','k');
set(fig,'units','pixels','position',[0 0 560 420]);
set(gca, 'Units', 'normalized', 'Position', [0 0 1 1]);
axis off;daspect(ar_cor);drawnow;
im_cor=frame2im(getframe(fig));

% axial
cz=median(iz);
img=rot90(squeeze(RawNii.img(:,:,cz)));
%img=rot90(squeeze(RawNii.img(:,:,cz)),3);
seg=rot90(squeeze(SegNii.img(:,:,cz)));
% img = flipud(img);
% seg = flipud(seg);
%seg=rot90(squeeze(SegNii.img(:,:,cz)),3);
img=max(0,min(1,double(img-CLIM(1))/(CLIM(2)-CLIM(1))));
img_rgb=repmat(img,[1 1 3]);
seg_rgb=ind2rgb(uint8(seg==1),cm);
overlayim=alpha*img_rgb+(1-alpha)*seg_rgb;
fig=figure(filenum+totalnum);
%fig=figure(2);
imagesc(overlayim);
set(fig,'color','k');
set(fig,'units','pixels','position',[0 0 560 420]);
set(gca, 'Units', 'normalized', 'Position', [0 0 1 1]);
axis off;daspect(ar_axi);drawnow;
im_axi=frame2im(getframe(fig));

% 3D rendering
[X,Y,Z]=ndgrid(1:size(Lim,1),1:size(Lim,2),1:size(Lim,3));
iso_bg=isosurface(X,Y,Z,RawNii.img>=500,0);
iso_spleen=isosurface(X,Y,Z,SegNii.img==1,0);

fig=figure(filenum+totalnum);
%fig=figure(2);
h_bg=patch(iso_bg,'FaceColor','k','EdgeColor','none','FaceAlpha',alpha_bg);
h_spleen=patch(iso_spleen,...
    'FaceColor',cmap(1,:),'EdgeColor','none','FaceAlpha',alpha_organ);
set(fig,'color','w'); % make the figure background white
set(fig,'units','pixels','position',[0 0 560 420]);
set(gca, 'units', 'normalized', 'position', [0 0 1 1]);
axis vis3d manual off;
daspect(ar);
camlight;
lighting phong;
view(0,0);drawnow;
im_ren=frame2im(getframe(fig));

% volumes in cm3
spleen_vol=sum(SegNii.img(:)==1)*prod(voxdim)/1000;

%--------------------------------SNAPSHOTS Panel---------------------------%
% start plotting
fig_main = figure(filenum);
%fig_main=figure(1);
set(fig_main,'Units','Inches','Position',[0 0 8.5 11],'Color','w');
a_main=axes('position',[0.05 0.05 0.9 0.90]);axis(a_main,'off');
title(a_main,'Abdominal Organ Segmentation Overview','FontSize',20);
a_snapshots=axes('position',[0.1 0.35 0.8,0.6]);axis(a_snapshots,'off');
t_snapshots=text(-0.05,0.5,'SNAPSHOTS','horizontalalignment','center',...
    'parent',a_snapshots,'rotation',90,'fontsize',18);
r_snapshots=rectangle('position',[0 0 1 1],...
    'edgecolor',[0.3 0.3 0.3],'parent',a_snapshots);

wim=0.38;him=wim*420/560;
wband=(0.4-wim)/2;
hband=(0.3-him);hband_bottom=1/4*hband;

a_axi=axes('position',...
    [0.1+wband,0.35+hband+hband_bottom+him,wim,him]);
axis(a_axi,'off');
imshow(im_axi,'parent',a_axi);
title('axial','FontSize',12);
a_cor=axes('position',...
    [0.1+wband,0.35+hband_bottom,wim,him]);
axis(a_cor,'off');
imshow(im_cor,'parent',a_cor);
title('coronal','FontSize',12);
a_sag=axes('position',...
    [0.1+3*wband+wim,0.35+hband+hband_bottom+him,wim,him]);
axis(a_sag,'off');
imshow(im_sag,'parent',a_sag);
title('sagittal','FontSize',12);
a_ren=axes('position',...
    [0.1+3*wband+wim,0.35+hband_bottom,wim,him]);
axis(a_ren,'off');
imshow(im_ren,'parent',a_ren);
title('3D rendering','FontSize',12);

%-------------------------------VOLUMES Panel----------------------------%
a_volumes=axes('position',[0.1 0.195 0.8,0.15]);axis(a_volumes,'off');
t_volumes=text(-0.05,0.5,'VOLUMES','horizontalalignment','center',...
    'parent',a_volumes,'rotation',90,'fontsize',18);
r_volumes=rectangle('position',[0 0 1 1],...
    'edgecolor',[0.3 0.3 0.3],'parent',a_volumes);
k=1;
ll=0.1+(1/3*mod(k-1,3))*0.8;
bb=0.195+(1/5*(floor((15-k)/3)))*0.15;
t_spleen_vol=annotation('textbox',...
    'position',[ll bb 1/3*0.8 1/5*0.15],...
    'string',sprintf('%s: %0.2f cc',organs{k},spleen_vol),...
    'color',[0.95 0.95 0.95],'fontsize',8.5,'fontweight','bold',...
    'backgroundcolor',cmap(k,:),...
    'horizontalalignment','center',...
    'verticalalignment','middle');

indent=0.02;
DescriptionLine1 = 'Not for clinical use.';
DescriptionLine2 = 'Use of this service is for technical demonstration only.';
t_DescriptionLine1_content=text(indent,0.65,...
    DescriptionLine1,...
    'fontsize',9,...
    'interpreter','none');
t_DescriptionLine2_content=text(indent,0.55,...
    DescriptionLine2,...
    'fontsize',9,...
    'interpreter','none');

t_DemoTester=text(indent,0.30,...
    'Produced by:',...
    'fontsize',9,'fontweight','bold',...
    'interpreter','none');
et=get(t_DemoTester,'extent');
ns=et(1)+et(3);
t_DemoTester_content=text(indent,0.20,...
    'Hyeonsoo Moon, Yuankai Huo, Justin Blaber, Richard Abramson, Bennett Landman',...
    'fontsize',8,...
    'interpreter','none');

%MasiLogo = imread('/share4/hyeonsoo/SegPipeline/docker_spleen/extra/masilablogo.jpg');
MasiLogo = imread('/extra/masilablogo.jpg');
%imgPanel = axes('Parent',a_volumes, 'Position',[.1 .1 posX posY]);

imgPanel=axes('position',[0.62 0.20 0.30,0.11]);axis(imgPanel,'off');
%MasiLogo = imread('/fs4/masi/hyeonsoo/logos/MASI/masilablogo.jpg');
imshow(MasiLogo);

%--------------------------------INFO Panel-------------------------------%
a_info=axes('position',[0.1 0.05 0.8,0.14]);axis(a_info,'off');
t_info=text(-0.05,0.5,'INFO','horizontalalignment','center',...
    'parent',a_info,'rotation',90,'fontsize',18);
r_info=rectangle('position',[0 0 1 1],...
    'edgecolor',[0.3 0.3 0.3],'parent',a_info);

[~,rundate]=system('date');
%email='zhoubing.xu@vanderbilt.edu';
email='bennett.landman@vanderbilt.edu';
citation_line1=['Yuankai Huo et al. ',...
    '"Splenomegaly segmentation using global convolutional kernels ',...
    'and '];
citation_line2='conditional generative adversarial networks."';
citation_line3='in SPIE Medical Imaging, International Society for Optics and Photonics, 2018.';

indent=0.02;
t_projsubjexprscan_label=text(indent,0.92,...
    'Project/Subject/Experiment/Scan: ',...
    'fontsize',9,'fontweight','bold',...
    'interpreter','none');
et=get(t_projsubjexprscan_label,'extent');
ns=et(1)+et(3)+1*indent;
t_projsubjexprscan_content=text(ns,0.90,...
    sprintf('%s/%s/%s/%s',...
    proj_name,subj_name,expr_name,scan_name),...
    'fontsize',9,...
    'interpreter','none');

t_spidername_label=text(indent,0.75,...
    'Spider name: ',...
    'fontsize',9,'fontweight','bold',...
    'interpreter','none');
et=get(t_spidername_label,'extent');    
ns=et(1)+et(3)+1*indent;
t_spidername_content=text(ns,0.75,...
    spider_name,...
    'fontsize',9,...
    'interpreter','none');

t_citation_line1_label=text(indent,0.60,...
    'Citation: ',...
    'fontsize',9,'fontweight','bold',...
    'interpreter','none');
et=get(t_citation_line1_label,'extent');
ns=et(1)+et(3)+1*indent;
t_citation_line1_content=text(ns,0.60,...
    citation_line1,...
    'fontsize',9,...
    'interpreter','none');
t_citation_line2_content=text(indent,0.50,...
    citation_line2,...
    'fontsize',9,...
    'interpreter','none');
t_citation_line3_content=text(indent,0.40,...
    citation_line3,...
    'fontsize',9,...
    'interpreter','none');

t_email_label=text(indent,0.25,...
    'Contact: ',...
    'fontsize',9,'fontweight','bold',...
    'interpreter','none');
et=get(t_email_label,'extent');
ns=et(1)+et(3)+1*indent;
t_email_content=text(ns,0.25,...
    email,...
    'fontsize',9,...
    'interpreter','none');

t_rundate_label=text(indent,0.10,...
    'Date of run: ',...
    'fontsize',9,'fontweight','bold',...
    'interpreter','none');
et=get(t_rundate_label,'extent');
ns=et(1)+et(3)+1*indent;
t_rundate_content=text(ns,0.10,...
    rundate(1:end-1),...
    'fontsize',9,...
    'interpreter','none');

t_versionDate_label=text(indent+0.6,0.10,...
    'Version Date: ',...
    'fontsize',9,'fontweight','bold',...
    'interpreter','none');
et=get(t_versionDate_label,'extent');
ns=et(1)+et(3)+1*indent;
versionDate = 'Nov 14 2017';
t_versionDate_content=text(ns,0.10,...
    versionDate,...
    'fontsize',9,...
    'interpreter','none');

% temporarily write the result as postscript
set(fig_main,'PaperType','usletter', 'PaperPositionMode','auto');
temp_ps = [tmp_dir, '/temp.ps'];
print('-dpsc2','-r400', temp_ps, fig_main);

% conver the postscript to the file pdf file
cmmd = ['ps2pdf -dPDFSETTINGS=/prepress ' temp_ps ' ' pdffn];
[status,msg]=system(cmmd);
if status~=0
    fprintf('\n Could not cleanly create pdf file from ps.\n');
    disp(msg);
end


%save txt files
text_dir = fileparts(pdffn);
text_fname = [text_dir filesep 'SpleenVol.txt'];
fp = fopen(text_fname,'w+');
fprintf(fp,'Spleen Volume = %.2f cc',spleen_vol);
fclose(fp);


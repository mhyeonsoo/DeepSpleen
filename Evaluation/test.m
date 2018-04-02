% d = '/share4/hyeonsoo/SegPipeline/Dataset/OUTPUTS/02-201-b/3_AbdPel_a200_D2/FinalSeg/keeplarge1_morpho1/GCN/cross_entropy/target_img/seg_view3_orig_seg.nii.gz';
% [Vol_L,Vol_W,L,W]= estimate_spleen_by_lines(d,0);
clear;close all;

fileID1 = fopen('~/Desktop/after_man_edit','r');
formatSpec = '%f';
A_vol = fscanf(fileID1,formatSpec);

fileID2 = fopen('~/Desktop/estimated volume','r');
B = fscanf(fileID2,formatSpec);
B_vol = B(1:2:end,:);


fileID3 = fopen('~/Desktop/before_man_edit','r');
C_vol = fscanf(fileID3,formatSpec);


count = 1;
for i=1:165
    if A_vol(i) ~= C_vol(i)
        A_vol_only_edited(count) = A_vol(i);
        C_vol_only_edited(count) = C_vol(i);
        B_vol_only_edited(count) = B_vol(i);
        count = count + 1;
    end
end

corr_auto_and_pipe_only_edited = corr(A_vol_only_edited',C_vol_only_edited');
corr_est_and_pipe_only_edited = corr(A_vol_only_edited',B_vol_only_edited');
myFit3 = LinearModel.fit(A_vol_only_edited,C_vol_only_edited);
myFit4 = LinearModel.fit(A_vol_only_edited,B_vol_only_edited);
figure(3);
plot(A_vol_only_edited,C_vol_only_edited,'.'); hold on
plot(myFit3);
hold off
%%
figure(4);
plot(A_vol_only_edited,B_vol_only_edited,'.'); hold on
plot(myFit4);
hold off

figure(5);
BlandAltman(A_vol_only_edited,C_vol_only_edited,2);
title('before edit')

figure(6);
BlandAltman(A_vol_only_edited,B_vol_only_edited,2);
title('estimation')

cnt1=1;
cnt2=1;
cnt3=1;
for i = 1:37
    if A_vol_only_edited(i) < 2500
        A_new(cnt1) = A_vol_only_edited(i);
        B_new(cnt1) = B_vol_only_edited(i);
        C_new(cnt1) = C_vol_only_edited(i);
        cnt1 = cnt1+1;
    end
end

corr_auto_and_pipe_only_edited = corr(A_new',C_new');
corr_est_and_pipe_only_edited = corr(A_new',B_new');
myFit1 = LinearModel.fit(A_new,C_new);
myFit2 = LinearModel.fit(A_new,B_new);
figure(1);
plot(A_new,C_new,'.'); hold on
plot(myFit1);
xlim([0 500]);
ylim([0 500]);
hold off

figure(2);
plot(A_new,B_new,'.'); hold on
plot(myFit2);
xlim([0 500]);
ylim([0 500]);
hold off

% d = '/share4/hyeonsoo/SegPipeline/Dataset/OUTPUTS/02-201-b/3_AbdPel_a200_D2/FinalSeg/keeplarge1_morpho1/GCN/cross_entropy/target_img/seg_view3_orig_seg.nii.gz';
% [Vol_L,Vol_W,L,W]= estimate_spleen_by_lines(d,0);
clear;close all;

fileID1 = fopen('/home/local/VANDERBILT/moonh1/Documents/GroundTruth','r');
formatSpec = '%f';
GrdountTruth = fscanf(fileID1,formatSpec);

fileID2 = fopen('/share4/hyeonsoo/SegPipeline/Dataset/tmp/Autovolume','r');
Autovolume = fscanf(fileID2,formatSpec);

%fileID3 = fopen('/share4/hyeonsoo/SegPipeline/docker_spleen/matlab/makepdf_spleen/VolL','r');
fileID3 = fopen('/home/local/VANDERBILT/moonh1/Documents/VolL','r');
Length = fscanf(fileID3,formatSpec);

%fileID4 = fopen('/share4/hyeonsoo/SegPipeline/docker_spleen/matlab/makepdf_spleen/VolD2','r');
fileID4 = fopen('/home/local/VANDERBILT/moonh1/Documents/VolD2','r');
Depth = fscanf(fileID4,formatSpec);

%fileID5 = fopen('/share4/hyeonsoo/SegPipeline/docker_spleen/matlab/makepdf_spleen/VolT','r');
fileID5 = fopen('/home/local/VANDERBILT/moonh1/Documents/VolT3','r');
Thickness = fscanf(fileID5,formatSpec);

%fileID6 = fopen('/share4/hyeonsoo/SegPipeline/docker_spleen/matlab/makepdf_spleen/VolLDT','r');
fileID6 = fopen('/home/local/VANDERBILT/moonh1/Documents/VolLDT3','r');
RegressionVolume = fscanf(fileID6,formatSpec);

LD = Length.*Depth;

count = 1;
for i=1:165
    if GrdountTruth(i) ~= Autovolume(i)
        GrdountTruth_only_edited(count) = GrdountTruth(i);
        Autovolume_only_edited(count) = Autovolume(i);
        Length_only_edited(count) = Length(i);
        LD_only_edited(count) = LD(i);
        RegressionVolume_only_edited(count) = RegressionVolume(i);
        count = count + 1;
    end
end

corr_auto_and_gt = corr(GrdountTruth_only_edited',Autovolume_only_edited');
corr_regVol_and_gt = corr(GrdountTruth_only_edited',RegressionVolume_only_edited');
corr_regLength_and_gt = corr(GrdountTruth_only_edited',Length_only_edited');
corr_regLD_and_gt = corr(GrdountTruth_only_edited',LD_only_edited');


auto_and_gt = LinearModel.fit(GrdountTruth_only_edited,Autovolume_only_edited);
regVol_and_gt = LinearModel.fit(GrdountTruth_only_edited,RegressionVolume_only_edited);
regLength_and_gt = LinearModel.fit(GrdountTruth_only_edited,Length_only_edited);
regLD_and_gt = LinearModel.fit(GrdountTruth_only_edited,LD_only_edited);


figure(1);
plot(GrdountTruth_only_edited,Autovolume_only_edited,'.'); hold on
plot(auto_and_gt);
ylim([0 3000]);
title('auto_and_gt')
hold off

figure(2);
plot(GrdountTruth_only_edited,Length_only_edited,'.'); hold on
plot(regLength_and_gt);
ylim([0 3000]);
title('regLength_and_gt')
hold off

figure(3);
plot(GrdountTruth_only_edited,LD_only_edited,'.'); hold on
plot(regLD_and_gt);
title('regLD_and_gt')
hold off

figure(4);
plot(GrdountTruth_only_edited,RegressionVolume_only_edited,'.'); hold on
plot(regVol_and_gt);
ylim([0 3000]);
title('regVol_and_gt')
hold off

figure(5);
BlandAltman(GrdountTruth_only_edited,Autovolume_only_edited,2);
title('auto_and_gt')

figure(6);
BlandAltman(GrdountTruth_only_edited,Length_only_edited,2);
title('regLength_and_gt')

figure(7);
BlandAltman(GrdountTruth_only_edited,LD_only_edited,2);
title('regLD_and_gt')

figure(8);
BlandAltman(GrdountTruth_only_edited,RegressionVolume_only_edited,2);
title('regVol_and_gt')

% cnt1=1;
% cnt2=1;
% cnt3=1;
% for i = 1:37
%     if A_vol_only_edited(i) < 2500
%         A_new(cnt1) = A_vol_only_edited(i);
%         B_new(cnt1) = B_vol_only_edited(i);
%         C_new(cnt1) = C_vol_only_edited(i);
%         cnt1 = cnt1+1;
%     end
% end
% 
% corr_auto_and_pipe_only_edited = corr(A_new',C_new');
% corr_est_and_pipe_only_edited = corr(A_new',B_new');
% myFit1 = LinearModel.fit(A_new,C_new);
% myFit2 = LinearModel.fit(A_new,B_new);
% figure(1);
% plot(A_new,C_new,'.'); hold on
% plot(myFit1);
% xlim([0 500]);
% ylim([0 500]);
% hold off
% 
% figure(2);
% plot(A_new,B_new,'.'); hold on
% plot(myFit2);
% xlim([0 500]);
% ylim([0 500]);
% hold off

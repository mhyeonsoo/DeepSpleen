function [Vol_L,Vol_W,Vol_T,Vol_LDT,L,W,T,slice_num] = estimate_spleen_by_lines(spleen_seg_file,plot_slice)

seg_nii = load_untouch_nii_gz(spleen_seg_file);
seg_img = seg_nii.img;
seg_hdr = seg_nii.hdr;

dim = seg_hdr.dime.dim(2:4);
pixdim = seg_hdr.dime.pixdim(2:4);

spleen_z_voxel_num = squeeze((sum(sum(seg_img))));
L = sum(spleen_z_voxel_num>0).*pixdim(3)/10;

working_slices = find(spleen_z_voxel_num>0);

distCell = {};
for wi = 1:length(working_slices)
    si = working_slices(wi);
    slice_img = squeeze(seg_img(:,:,si));
    [B,Lb,N,A] = bwboundaries(slice_img);
    if (N>1)
%         error('more than one connected region');
    end
    
    coords = B{1};
    points = coords.*repmat(pixdim(1:2),size(coords,1),1); %take the voxel resolution into account
    
%     if plot_slice
%         imagesc(slice_img);hold on;
%         for k = 1:length(B)
%             boundary = B{k};
%             plot(boundary(:,2),boundary(:,1),'g');
%         end
%         hold off;
%     end
    
    [d,idx] = pdist2(points,points,'euclidean','Largest',1);
    idx1 = idx(d==max(d));
    [~,idx2] = find(d==max(d));
    
    p = {};
    maxCoor = {};
    for di=1:length(idx1)
        maxCoor{end+1} = [coords(idx1(di),1),coords(idx1(di),2),coords(idx2(di),1),coords(idx2(di),2)];
        p{end+1} = [points(idx1(di),1),points(idx1(di),2),points(idx2(di),1),points(idx2(di),2)];
    end
    
    
    pp=[];
    maxCoorr = [];
    for i=1:numel(p)
        for j=i+1:numel(p)
            if prod( double( [p{i}(3:4),p{i}(1:2)] == p{j}))
                pp(end+1)=j;
                maxCoorr(end+1) = j;
            end
        end
    end
    j=1;
    ppp={};
    maxCoorrr = {};
    for i=1:numel(p)-numel(pp)
        if j<=numel(pp)&&i~=pp(j)
            ppp{end+1}=p{i};
            maxCoorrr{end+1} = maxCoor{i};
            j=j+1;
        end
    end
    p_final = ppp;
    maxCorr_final = maxCoorrr;
    
    for ii=1:numel(maxCorr_final)
        Wsi(ii) = sqrt((p_final{ii}(2)-p_final{ii}(4))^2+(p_final{ii}(1)-p_final{ii}(3))^2);   
    end
    distCell{wi} = maxCoorrr;
    pointCloud_real{wi} = p_final;
    Ws(wi) = max(Wsi);
%     if  plot_slice
%         title(sprintf('slice#=%d ,maxlen=%f\n',si,Ws(wi)));
%         hold off;
%         pause(1);
%     end
    
end

%L and W 
W = max(Ws)/10;
Vol_L = (L-5.8006)/0.0126;
Vol_W = (W-8.1101)/0.0098;


% plot option
if plot_slice
    for i = 1:length(Ws)
        if(Ws(i) == max(Ws))
            coord = distCell{i};
            pcloud = pointCloud_real{i};
            si = working_slices(i);
            slice_num = si;
            slice_img = squeeze(seg_img(:,:,si));
            [B,Lb,N,A] = bwboundaries(slice_img);
            target_coord = B{1};
            target_points = target_coord.*repmat(pixdim(1:2),size(target_coord,1),1);
%             for ii=1:numel(coord)
%                 if  plot_slice
%                     imagesc(slice_img);hold on;
%                     for k = 1:length(B)
%                         boundary = B{k};
%                         plot(boundary(:,2),boundary(:,1),'g');
%                     end
%                     %hold off;
%                     line([coord{ii}(2), coord{ii}(4)], [ coord{ii}(1), coord{ii}(3)]);
%                     hdl = get(gca,'Children');
%                     set( hdl(1),'LineWidth',2);
%                     set( hdl(1),'color',[1 0 0]);
%                 end
%             end
        end
    end
end

% target D coord
%coord
maxT = 0;
for i = 1:length(target_points)
    for j = 1:length(target_points)
        v1 = [pcloud{1}(3),pcloud{1}(4)] - [pcloud{1}(1),pcloud{1}(2)];
        v2 = [target_points(j,1),target_points(j,2)] - [target_points(i,1),target_points(i,2)];
        angle_diff = mod( atan2( det([v1;v2]) ,dot(v1,v2) ), 2*pi);
        if angle_diff< 91/180*pi && angle_diff > 89/180*pi
            if sqrt((target_points(j,1)-target_points(i,1))^2+(target_points(j,2)-target_points(i,2))^2) > maxT
                maxT = sqrt((target_points(j,1)-target_points(i,1))^2+(target_points(j,2)-target_points(i,2))^2);
%                 i_for_draw = i;
%                 j_for_draw = j;
            end
        end
    end
end
% hold off;
% line([target_coord(j_for_draw,2),target_coord(i_for_draw,2)], [ target_coord(j_for_draw,1), target_coord(i_for_draw,1)]);
% hdl = get(gca,'Children');
% set( hdl(1),'LineWidth',2);
% set( hdl(1),'color',[1 0 0]);
% title(spleen_seg_file);
%pcloud

T = maxT;
Vol_T = (T-4.0811)/0.0061;
Vol_LDT = ((L*W*T)+6.5029)/2.4074;
%Vol_LDT = 30 + 0.58 * L * D * T;


end
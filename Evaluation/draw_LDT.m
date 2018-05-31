function [im_save] = draw_LDT(spleen_seg_file,raw_nii,plot_slice)
raw_img = raw_nii.img;
seg_nii = load_untouch_nii_gz(spleen_seg_file);
seg_img = seg_nii.img;
seg_hdr = seg_nii.hdr;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
CLIM=[-200,200];
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
    0.5412    0.1686    0.8863];alpha=0.5;
alpha_bg=0.05;
alpha_organ=0.5;
cm=cat(1,[0,0,0],cmap);

voxdim=raw_nii.hdr.dime.pixdim(2:4);
ar_axi=[1 voxdim(1)/voxdim(2) 1];
ar_cor=[1 voxdim(1)/voxdim(3) 1];
ar_sag=[1 voxdim(2)/voxdim(3) 1];
ar=1./voxdim;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
dim = seg_hdr.dime.dim(2:4);
pixdim = seg_hdr.dime.pixdim(2:4);

spleen_z_voxel_num = squeeze((sum(sum(seg_img))));
L = sum(spleen_z_voxel_num>0).*pixdim(3)/10;

working_slices = find(spleen_z_voxel_num>0);

distCell = {};
for wi = 1:length(working_slices)
    si = working_slices(wi);
    seg=rot90(squeeze(seg_img(:,:,si)));
    [B,Lb,N,A] = bwboundaries(seg);
    %if (N>1)
    %    error('more than one connected region');
    %end
    
    coords = B{1};
    points = coords.*repmat([pixdim(2),pixdim(1)],size(coords,1),1); %take the voxel resolution into account

    
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
    fig = figure;
    for i = 1:length(Ws)
        if(Ws(i) == max(Ws))
            coord = distCell{i};
            pcloud = pointCloud_real{i};
            si = working_slices(i);
            slice_num = si;
            img=rot90(squeeze(raw_img(:,:,slice_num)));
            seg=rot90(squeeze(seg_img(:,:,slice_num)));

            [B,Lb,N,A] = bwboundaries(seg);
            target_coord = B{1};
            target_points = target_coord.*repmat([pixdim(2),pixdim(1)],size(target_coord,1),1);
            for ii=1:numel(coord)
                if  plot_slice
                    img=max(0,min(1,double(img-CLIM(1))/(CLIM(2)-CLIM(1))));
                    img_rgb=repmat(img,[1 1 3]);
                    %seg_rgb=ind2rgb(uint8(seg==1),cm);
                    overlayim=alpha*img_rgb;
                    %+(1-alpha)*seg_rgb
                    imagesc(overlayim);hold on
                    set(fig,'color','k');
                    set(gca, 'Units', 'normalized', 'Position', [0 0 1 1]);
                    axis off;daspect(ar_axi);drawnow;
                    for k = 1:length(B)
                        boundary = B{k};
                        plot(boundary(:,2),boundary(:,1),'g');
                    end
                    %hold off;
                    line([coord{ii}(2), coord{ii}(4)], [ coord{ii}(1), coord{ii}(3)]);
                    hdl = get(gca,'Children');
                    set( hdl(1),'LineWidth',2);
                    set( hdl(1),'color',[1 0 0]);
                end
            end
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
        %angle_diff = mod( atan2( det([v1;v2]) ,dot(v1,v2) ), 2*pi);
        angle_diff=acos(sum(v1.*v2)/(norm(v1)*norm(v2)));
        anglearr(i,j) = abs(angle_diff);
        if angle_diff< 91/180*pi && angle_diff > 89/180*pi
            if sqrt((target_points(j,1)-target_points(i,1))^2+(target_points(j,2)-target_points(i,2))^2) > maxT
                maxT = sqrt((target_points(j,1)-target_points(i,1))^2+(target_points(j,2)-target_points(i,2))^2);
                i_for_draw = i;
                j_for_draw = j;
            end
        end
    end
end
hold off;
line([target_coord(j_for_draw,2),target_coord(i_for_draw,2)], [ target_coord(j_for_draw,1), target_coord(i_for_draw,1)]);
hdl = get(gca,'Children');
set( hdl(1),'LineWidth',2);
set( hdl(1),'color',[1 0 0]);
title(spleen_seg_file);

im_save=frame2im(getframe(fig));

end
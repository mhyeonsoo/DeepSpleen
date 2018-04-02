function [Vol_L,Vol_W,L,W] = estimate_spleen_by_lines(spleen_seg_file,plot_slice)

seg_nii = load_untouch_nii_gz(spleen_seg_file);
seg_img = seg_nii.img;
seg_hdr = seg_nii.hdr;

dim = seg_hdr.dime.dim(2:4);
pixdim = seg_hdr.dime.pixdim(2:4);

spleen_z_voxel_num = squeeze((sum(sum(seg_img))));
L = sum(spleen_z_voxel_num>0).*pixdim(3)/10;

working_slices = find(spleen_z_voxel_num>0);

if plot_slice
    figure
end
for wi = 1:length(working_slices)
    si = working_slices(wi);
    slice_img = squeeze(seg_img(:,:,si));
    [B,Lb,N,A] = bwboundaries(slice_img);
    if (N>1)
%         error('more than one connected region');
    end
    
    coords = B{1};
    points = coords.*repmat(pixdim(1:2),size(coords,1),1); %take the voxel resolution into account
    
    if plot_slice
        imagesc(slice_img);hold on;
        for k = 1:length(B)
            boundary = B{k};
            plot(boundary(:,2),boundary(:,1),'g');
        end
        hold off;
    end
    
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
    
    if  plot_slice
        hold on;
    end
    for ii=1:numel(maxCorr_final)
        if  plot_slice
            line([maxCorr_final{ii}(2), maxCorr_final{ii}(4)], [ maxCorr_final{ii}(1), maxCorr_final{ii}(3)]);
            hdl = get(gca,'Children');
            set( hdl(1),'LineWidth',2);
            set( hdl(1),'color',[1 0 0]);
        end
        Wsi(ii) = sqrt((p_final{ii}(2)-p_final{ii}(4))^2+(p_final{ii}(1)-p_final{ii}(3))^2);
        
    end
    Ws(wi) = max(Wsi);
    if  plot_slice
        title(sprintf('slice#=%d ,maxlen=%f\n',si,Ws(i)));
        hold off;
        pause(1);
    end
    
end

W = max(Ws)/10;

%L and W 
Vol_L = (L-5.8006)/0.0126;
Vol_W = (W-8.1101)/0.0098;

end
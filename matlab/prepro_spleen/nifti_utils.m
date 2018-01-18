classdef nifti_utils < handle
% Library for commonly used nifti utilities.

    methods (Static, Access = public)    
        
        function success = is_radiological_storage_orientation(nii_path, fsl_exec)
            % Tests if nifti has fsl's definition of radiological storage 
            % orientation.         
            
            if exist('fsl_exec','var')
                fslorient = system_utils.system_with_errorcheck([fsl_exec.get_path('fslorient') ' -getorient ' nii_path],'Failed to get FSL orientation');
            else
                fslorient = system_utils.system_with_errorcheck(['fslorient -getorient ' nii_path],'Failed to get FSL orientation');
            end
            
            if strcmp(fslorient(1:end-1),'RADIOLOGICAL')
                success = true;                
            else
                success = false;
            end
        end   
        
        function vol = load_untouch_nii_vol(nii_path,type)
            % Returns .img from load_untouch_nii. 'type' is optional, and
            % if provided, .img will get converted to this type. type is 
            % typically 'logical', 'double', etc... 
            
            if findstr('.gz',nii_path)
                nii = load_untouch_nii_gz(nii_path);
                vol = nii.img;
            else
                nii = load_untouch_nii(nii_path);         
                vol = nii.img;
            end
            if exist('type','var')
                type_fun = str2func(type);            
                vol = type_fun(vol);
            end
        end
                      
        function vol = load_untouch_nii_vol_scaled(nii_path,type)
            % Loads .img untouched, then scales with scl_slope and scl_inter.
            % Use this if merging niftis --or-- if the actual intensity
            % matters. type is mandatory since image intensity is scaled.
                            
            type_fun = str2func(type);                   
            
            nii_hdr = load_untouch_header_only(nii_path);           
            vol = nifti_utils.load_untouch_nii_vol(nii_path,type);  
            
            if nii_hdr.dime.scl_slope ~= 0
                vol = type_fun(vol .* type_fun(nii_hdr.dime.scl_slope) + type_fun(nii_hdr.dime.scl_inter));   
            end
        end
        
        function vol = load_untouch_nii4D_vol(nii_path,type)
            % Returns 4D volume which is fsl compatible, in that if the 
            % 4D info is stored in the 5th dimension, it gets permuted to 
            % the 4th. 'type' is optional, and if provided, .img will get 
            % converted to this type. type is typically 'logical', 
            % 'double', etc... 
                                 
            nii_hdr = load_untouch_header_only(nii_path);   
            vol = nifti_utils.load_untouch_nii_vol(nii_path);  
            if nii_hdr.dime.dim(1) == 5 && nii_hdr.dime.dim(5) == 1 && nii_hdr.dime.dim(6) ~= 1
                % 4th dimensional info stored in 5th dimension - permute it
                vol = permute(vol,[1 2 3 5 4]);
            end
            
            if exist('type','var')
                type_fun = str2func(type);            
                vol = type_fun(vol);
            end
        end
                      
        function vol = load_untouch_nii4D_vol_scaled(nii_path,type)
            % Loads .img untouched, then scales with scl_slope and scl_inter.
            % Use this if merging niftis --or-- if the actual intensity
            % matters. type is mandatory since image intensity is scaled.
            
            type_fun = str2func(type); 
            
            nii_hdr = load_untouch_header_only(nii_path);                       
            vol = nifti_utils.load_untouch_nii4D_vol(nii_path,type);     
            
            if nii_hdr.dime.scl_slope ~= 0
                vol = type_fun(vol .* type_fun(nii_hdr.dime.scl_slope) + type_fun(nii_hdr.dime.scl_inter));
            end
        end
        
        function save_untouch_nii_using_scaled_img_info(nii_path,nii,type)
            % Saves input nii using its img info and type. Always
            % sets scl_slope to 1 and scl_inter to 0.
            
            % First set dims
            nii.hdr.dime.dim(:) = 1;
            nii.hdr.dime.dim(1) = length(size(nii.img));
            nii.hdr.dime.dim(2:1+length(size(nii.img))) = size(nii.img);
            
            % Set datatype
            if strcmp(type,'double')
                nii.hdr.dime.datatype = 64;             % Double precision
                nii.hdr.dime.bitpix = 64;               % Double precision
            elseif strcmp(type,'logical')
                nii.hdr.dime.datatype = 2;              % uint8 - apparently there is a ubit1, but I doubt this works properly
                nii.hdr.dime.bitpix = 8;               
            else
                error(['Input type of: ' type ' is currently unsupported for save_untouch_nii_using_scaled_img_info()']);
            end
            
            % Set rest of relevant parameters.
            nii.hdr.dime.scl_slope = 1;
            nii.hdr.dime.scl_inter = 0;
            nii.hdr.dime.glmax = max(nii.img(:));
            nii.hdr.dime.glmin = min(nii.img(:));
            save_untouch_nii(nii,nii_path);            
        end
                  
        function idx_untouch_nii4D(nii_in_path,idxs,nii_out_path)
            % Loads nifti, applies idxs to 4th dimension, and then saves.
            % Uses FSL convention in that 4th dimension is used for
            % diffusion weighting.
            
            nii = load_untouch_nii(nii_in_path);
            nii.img = nifti_utils.load_untouch_nii4D_vol(nii_in_path);
            nii.img = nii.img(:,:,:,idxs);
            if size(nii.img,4) == 1
                nii.hdr.dime.dim(1) = 3;
            else
                nii.hdr.dime.dim(1) = 4;           % fsl convention
            end
            nii.hdr.dime.dim(5) = size(nii.img,4); % fsl convention
            nii.hdr.dime.dim(6) = 1;               % fsl convention
            nii.hdr.dime.glmax = max(nii.img(:));
            nii.hdr.dime.glmin = min(nii.img(:));
            save_untouch_nii(nii,nii_out_path);
        end
        
        function success = are_compatible(nii1_path,nii2_path)
            % Tests to see if input niftis are compatible. If they are
            % compatible, then they can be concatenated as long as the
            % datatype, bitpix, scl_slope, and scl_inter are taken into
            % account.
            
            [nii1_hdr,~,~,nii1_machine] = load_untouch_header_only(nii1_path);   
            [nii2_hdr,~,~,nii2_machine] = load_untouch_header_only(nii2_path);   
            
            if isequal(nii1_machine,nii2_machine) && ...
                    isequal(nii1_hdr.dime.dim(2:4),nii2_hdr.dime.dim(2:4)) && ...
                    isequal(nii1_hdr.dime.pixdim(1:4),nii2_hdr.dime.pixdim(1:4)) && ...
                    nii1_hdr.dime.xyzt_units == nii2_hdr.dime.xyzt_units && ...
                    nii1_hdr.hist.qform_code == nii2_hdr.hist.qform_code && ...
                    nii1_hdr.hist.quatern_b == nii2_hdr.hist.quatern_b && ...
                    nii1_hdr.hist.quatern_c == nii2_hdr.hist.quatern_c && ...
                    nii1_hdr.hist.quatern_d == nii2_hdr.hist.quatern_d && ...
                    nii1_hdr.hist.qoffset_x == nii2_hdr.hist.qoffset_x && ...
                    nii1_hdr.hist.qoffset_y == nii2_hdr.hist.qoffset_y && ...
                    nii1_hdr.hist.qoffset_z == nii2_hdr.hist.qoffset_z && ...
                    nii1_hdr.hist.sform_code == nii2_hdr.hist.sform_code && ...
                    isequal(nii1_hdr.hist.srow_x,nii2_hdr.hist.srow_x) && ...
                    isequal(nii1_hdr.hist.srow_y,nii2_hdr.hist.srow_y) && ...
                    isequal(nii1_hdr.hist.srow_z,nii2_hdr.hist.srow_z) && ...
                    isequal(nii1_hdr.hist.magic,nii2_hdr.hist.magic)
                success = true;
            else
                success = false;
            end               
        end   
        
        function merge_untouch_nii4D(nii_in_paths,nii_out_path)
            % Loads niftis, concatenates them, then saves to nii_out_path.
            % Input niftis should all be same except for scl_slope,
            % scl_inter, datatype, and bitpix. Slope and scale are applied,
            % and then datatype/bitpix are set to double.
            
            % See if niftis are compatible first
            for i = 2:length(nii_in_paths)
                % Issue a warning instead of an error since some niftis 
                % have slightly different qform/sforms
                if ~nifti_utils.are_compatible(nii_in_paths{1},nii_in_paths{i})
                    disp(['Warning: niftis : ' nii_in_paths{1} ' and ' ...
                        nii_in_paths{i} ' were found to be "incompatible". ' ...
                        'Please check to make sure sform/qform are very ' ...
                        'similar. Output nifti will have header ' ...
                        'information matching first input nifti: ' ...
                        nii_in_paths{1}]);
                end
            end
            
            % Load first nifti
            nii = load_untouch_nii(nii_in_paths{1});
            nii.img = nifti_utils.load_untouch_nii4D_vol_scaled(nii_in_paths{1},'double'); % Must be scaled with scl_slope and scl_inter
            for i = 2:length(nii_in_paths)
                % Load nifti
                nii_tmp = load_untouch_nii(nii_in_paths{i});         
                nii_tmp.img = nifti_utils.load_untouch_nii4D_vol_scaled(nii_in_paths{i},'double'); % Must be scaled with scl_slope and scl_inter
                
                % Concatenate
                nii.img = cat(4,nii.img,nii_tmp.img);
            end   
            nii.hdr.dime.datatype = 64;  % Double precision
            nii.hdr.dime.bitpix = 64;    % Double precision
            nii.hdr.dime.scl_slope = 1;
            nii.hdr.dime.scl_inter = 0;         
            if size(nii.img,4) == 1
                nii.hdr.dime.dim(1) = 3;
            else
                nii.hdr.dime.dim(1) = 4;           % fsl convention
            end
            nii.hdr.dime.dim(5) = size(nii.img,4); % fsl convention
            nii.hdr.dime.dim(6) = 1;               % fsl convention
            nii.hdr.dime.glmax = max(nii.img(:));
            nii.hdr.dime.glmin = min(nii.img(:));
            save_untouch_nii(nii,nii_out_path);
        end
                
        function mean_untouch_nii4D(nii_in_path,nii_out_path)
            % Calculates mean. Note this stores in whatever format the
            % input image is in, so decimals might get cast to integers.
            
            % Load
            nii = load_untouch_nii(nii_in_path);
            nii.img = nifti_utils.load_untouch_nii4D_vol(nii_in_path,'double'); % Does not need to be scaled for mean
            
            % Get mean
            nii.img = nanmean(nii.img,4);
            
            % Volume is 3D now
            nii.hdr.dime.dim(1) = 3;
            nii.hdr.dime.dim(5) = 1; 
            nii.hdr.dime.dim(6) = 1;    
            nii.hdr.dime.glmax = round(max(nii.img(:)));   
            nii.hdr.dime.glmin = round(min(nii.img(:)));     
            
            % Save
            save_untouch_nii(nii,nii_out_path);       
        end
        
        function copyexceptimginfo_untouch_header_only(nii1_path,nii2_path)
            % Copies nii1's header to nii2's header and saves the file,
            % except for the img related info (dim, datatype, bitpix, glmax,
            % glmin, scl_slope, and scl_inter). This is used when an image
            % is altered in FSL (bet, fslroi, etc...), but everything else 
            % (qform, sform, etc) should be the same.
            nii1 = load_untouch_nii(nii1_path);
            nii2 = load_untouch_nii(nii2_path);
            nii2_hdr_buf = nii2.hdr;
            
            % Copy header
            nii2.hdr = nii1.hdr;
            
            % Restore img info to header
            nii2.hdr.dime.dim = nii2_hdr_buf.dime.dim;
            nii2.hdr.dime.datatype = nii2_hdr_buf.dime.datatype;
            nii2.hdr.dime.bitpix = nii2_hdr_buf.dime.bitpix;
            nii2.hdr.dime.glmax = nii2_hdr_buf.dime.glmax;
            nii2.hdr.dime.glmin = nii2_hdr_buf.dime.glmin;
            nii2.hdr.dime.scl_slope = nii2_hdr_buf.dime.scl_slope;
            nii2.hdr.dime.scl_inter = nii2_hdr_buf.dime.scl_inter;
            
            % Save
            save_untouch_nii(nii2,nii2_path);            
        end
        
        function xform_RAS = get_RAS_xform(nii_path)
            % Returns 3x4 transformation from pixels to continuous RAS
            % coordinates. Attempts to use qform; if that is not available,
            % it will use the sform. If neither are available an error is
            % raised. Units are in mm.           
            nii_hdr = load_untouch_header_only(nii_path);       
            
            if nii_hdr.hist.qform_code > 0
                % https://brainder.org/2012/09/23/the-nifti-file-format/
                b = nii_hdr.hist.quatern_b;
                c = nii_hdr.hist.quatern_c;
                d = nii_hdr.hist.quatern_d;
                a = sqrt(1-b^2-c^2-d^2);
                
                % Initialize
                xform_RAS = [a^2+b^2-c^2-d^2    2*(b*c-a*d)         2*(b*d+a*c)
                             2*(b*c+a*d)        a^2+c^2-b^2-d^2     2*(c*d-a*b)
                             2*(b*d-a*c)        2*(c*d+a*b)         a^2+d^2-b^2-c^2];
                               
                % Scale by pixdim and q paramter
                q = nii_hdr.dime.pixdim(1); 
                xform_RAS = xform_RAS * diag([nii_hdr.dime.pixdim(2) nii_hdr.dime.pixdim(3) q * nii_hdr.dime.pixdim(4)]);              
                
                % Append translation to finish
                xform_RAS = [xform_RAS [nii_hdr.hist.qoffset_x; nii_hdr.hist.qoffset_y; nii_hdr.hist.qoffset_z]];
            elseif nii_hdr.hist.sform_code > 0
                % https://brainder.org/2012/09/23/the-nifti-file-format/
                xform_RAS = [nii_hdr.hist.srow_x;
                             nii_hdr.hist.srow_y;
                             nii_hdr.hist.srow_z];
            else
                % TODO: maybe support Analyze format?
                error('Analyze format not supported');
            end
        end
        
        function xform_RAS_voxel = get_voxel_RAS_xform(nii_path)
            % Gets the 3x3 transformation used to convert voxel coordinates 
            % into "voxel RAS orientation". I used a similar method that 
            % xform_nii() uses, except the tolerance is set to "1" by 
            % default here and I take the voxel scaling into account. 
            % No translational component is provided because this is 
            % basically used for plotting results without resampling.
            nii_hdr = load_untouch_header_only(nii_path);   
            
            % First, get xform_RAS
            xform_RAS = nifti_utils.get_RAS_xform(nii_path);
                        
            % First, remove the scaling component. 
            xform_scale = diag([nii_hdr.dime.pixdim(2:4) 1]);            
            xform_RAS_voxel = vertcat(xform_RAS,[0 0 0 1]) * xform_scale^-1;
            
            % Then, clear everything below the 3rd largest absolute value 
            % in the non-translational component of the transformation. 
            xform_RAS_voxel = xform_RAS_voxel(1:3,1:3);
            [~,idx_sort] = sort(abs(xform_RAS_voxel(:)));
            xform_RAS_voxel(idx_sort(1:end-3)) = 0;
            xform_RAS_voxel = sign(xform_RAS_voxel);            
            if det(xform_RAS_voxel) == 0
                % TODO: maybe a different method can prevent this?
                error('RAS voxel orientation matrix is singular.');
            end
        end
                
        function vol_RAS = load_untouch_nii_vol_RAS(nii_path,type)       
            % Does load_untouch_nii_vol() + converts to "voxel RAS
            % orientation"
            
            if exist('type','var')
                vol = nifti_utils.load_untouch_nii_vol(nii_path,type);
            else
                vol = nifti_utils.load_untouch_nii_vol(nii_path);
            end
            
            vol_RAS = vol_utils.convert_to_xform(vol,nifti_utils.get_voxel_RAS_xform(nii_path));            
        end
                      
        function vol_RAS = load_untouch_nii_vol_scaled_RAS(nii_path,type)
            % Does load_untouch_nii_vol_scaled() + converts to "voxel RAS 
            % orientation"    
            
            vol = nifti_utils.load_untouch_nii_vol_scaled(nii_path,type);
            
            vol_RAS = vol_utils.convert_to_xform(vol,nifti_utils.get_voxel_RAS_xform(nii_path));  
        end
        
        function vol_RAS = load_untouch_nii4D_vol_RAS(nii_path,type)
            % Does load_untouch_nii4D_vol + converts to "voxel RAS 
            % orientation"
            
            if exist('type','var')
                vol = nifti_utils.load_untouch_nii4D_vol(nii_path,type);
            else
                vol = nifti_utils.load_untouch_nii4D_vol(nii_path);
            end
                        
            vol_RAS = vol_utils.convert_to_xform(vol,nifti_utils.get_voxel_RAS_xform(nii_path));  
        end
                      
        function vol_RAS = load_untouch_nii4D_vol_scaled_RAS(nii_path,type)
            % Does load_untouch_nii4D_vol_scaled + converts to "voxel RAS
            % orientation"
            
            vol = nifti_utils.load_untouch_nii4D_vol_scaled(nii_path,type);
                        
            vol_RAS = vol_utils.convert_to_xform(vol,nifti_utils.get_voxel_RAS_xform(nii_path));  
        end
        
        function voxel_coords = get_voxel_coords(nii_path)
            % Returns coordinates of voxels in continuous RAS (mm). Same as
            % XYZ output in [~,XYZ] = spm_read_vols(V). Outputs are 
            % returned as a 3xn row vector format.
            
            % First, get xform_RAS
            xform_RAS = nifti_utils.get_RAS_xform(nii_path);
            
            % Get voxel coordinates; note that these will use zero based
            % indexing.
            nii_hdr = load_untouch_header_only(nii_path);  
            [I,J,K] = ndgrid(0:nii_hdr.dime.dim(2)-1, ...
                             0:nii_hdr.dime.dim(3)-1, ...
                             0:nii_hdr.dime.dim(4)-1);
                          
            % Get real coordinates of voxels
            voxel_coords = xform_RAS * [I(:)';J(:)';K(:)';ones(size(I(:)'))];            
        end
    end    
end
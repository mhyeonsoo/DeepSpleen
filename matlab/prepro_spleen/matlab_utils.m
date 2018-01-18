classdef matlab_utils < handle
% Library for commonly used matlab utilities

    methods (Static, Access = public)    
        
        % Structure related library --------------------------------------%        
        
        function s = add_unique_field(s, field, val)
            % Adds field to struct s and sets its value to val. Returns an 
            % error if field already exists.

            if ~isfield(s,field)
                s.(field) = val;
            else
                error(['Attempted to add field: ' field ' to struct, but it was not unique.']);
            end        
        end
        
        function s_merged = merge_structs(s1, s2)
            % Merges two input structures. Returns an error if one of the 
            % fields is not unique.

            % Initialize merged structure to s1
            s_merged = s1;

            fields_s2 = fieldnames(s2);
            for i = 1:length(fields_s2)
                s_merged = matlab_utils.add_unique_field(s_merged,fields_s2{i},s2.(fields_s2{i}));
            end
        end
        
        function s = replace_field(s, f1, f2)          
            % Replaces field f1 in s with f2
            val = s.(f1);
            s = rmfield(s,f1);
            s.(f2) = val;
        end
        
        function s = add_prefix(s, prefix)
            % Adds a prefix to input structure fields
            
            fields = fieldnames(s);
            for i = 1:length(fields)
                % Replace field with prefix'd field
                s = matlab_utils.replace_field(s,fields{i},[prefix fields{i}]);
            end            
        end    
        
        % Plot related library -------------------------------------------%
        
        function pos = plotboxpos(h)
            % PLOTBOXPOS Returns the position of the plotted axis region
            %
            % pos = plotboxpos(h)
            %
            % This function returns the position of the plotted region of an axis,
            % which may differ from the actual axis position, depending on the axis
            % limits, data aspect ratio, and plot box aspect ratio.  The position is
            % returned in the same units as the those used to define the axis itself.
            % This function can only be used for a 2D plot.  
            %
            % Input variables:
            %
            %   h:      axis handle of a 2D axis (if ommitted, current axis is used).
            %
            % Output variables:
            %
            %   pos:    four-element position vector, in same units as h

            % Copyright 2010 Kelly Kearney

            % Check input

            if nargin < 1
                h = gca;
            end

            if ~ishandle(h) || ~strcmp(get(h,'type'), 'axes')
                error('Input must be an axis handle');
            end

            % Get position of axis in pixels

            currunit = get(h, 'units');
            set(h, 'units', 'pixels');
            axisPos = get(h, 'Position');
            set(h, 'Units', currunit);

            % Calculate box position based axis limits and aspect ratios

            darismanual  = strcmpi(get(h, 'DataAspectRatioMode'),    'manual');
            pbarismanual = strcmpi(get(h, 'PlotBoxAspectRatioMode'), 'manual');

            if ~darismanual && ~pbarismanual

                pos = axisPos;

            else

                dx = diff(get(h, 'XLim'));
                dy = diff(get(h, 'YLim'));
                dar = get(h, 'DataAspectRatio');
                pbar = get(h, 'PlotBoxAspectRatio');

                limDarRatio = (dx/dar(1))/(dy/dar(2));
                pbarRatio = pbar(1)/pbar(2);
                axisRatio = axisPos(3)/axisPos(4);

                if darismanual
                    if limDarRatio > axisRatio
                        pos(1) = axisPos(1);
                        pos(3) = axisPos(3);
                        pos(4) = axisPos(3)/limDarRatio;
                        pos(2) = (axisPos(4) - pos(4))/2 + axisPos(2);
                    else
                        pos(2) = axisPos(2);
                        pos(4) = axisPos(4);
                        pos(3) = axisPos(4) * limDarRatio;
                        pos(1) = (axisPos(3) - pos(3))/2 + axisPos(1);
                    end
                elseif pbarismanual
                    if pbarRatio > axisRatio
                        pos(1) = axisPos(1);
                        pos(3) = axisPos(3);
                        pos(4) = axisPos(3)/pbarRatio;
                        pos(2) = (axisPos(4) - pos(4))/2 + axisPos(2);
                    else
                        pos(2) = axisPos(2);
                        pos(4) = axisPos(4);
                        pos(3) = axisPos(4) * pbarRatio;
                        pos(1) = (axisPos(3) - pos(3))/2 + axisPos(1);
                    end
                end
            end

            % Convert plot box position to the units used by the axis

            temp = axes('Units', 'Pixels', 'Position', pos, 'Visible', 'off', 'parent', get(h, 'parent'));
            set(temp, 'Units', currunit);
            pos = get(temp, 'position');
            delete(temp);
        end
    end    
end
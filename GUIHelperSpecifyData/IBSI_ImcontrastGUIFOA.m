function ImcontrastGUIFOA(AxialAxesHandle, Pos, flag_CT)

handle=AxialAxesHandle;

HandleGroup=AxialAxesHandle;

[imageHandle, axHandle, figHandle] = imhandles(handle);

if isempty(imageHandle)
    return;
end


% IMCONTRAST uses the first image if there are multiple.
imageHandle = imageHandle(1);
axHandle = ancestor(imageHandle, 'axes');

% Display the original image.
% - Use a DRAWNOW to work around a bug that forces imcontrast to the
%   background (geck #219657).
figure(figHandle); drawnow


% Create the histogram palette.
hHistFig = histogramPalette(imageHandle, Pos, flag_CT);

    function hFig = histogramPalette(imageHandle, Pos, flag_CT)


        [hImageIm, hImageAx, hImageFig] = imhandles(imageHandle);
        X = get(imageHandle, 'CData');
      
        % By default, round editbox values, and display with no decimal
        % places except for the center (which can be halfway between two
        % integers).
        editFormatFcn =   @(value) sprintf('%0.0f', value);
        centerFormatFcn = @(value) sprintf('%0.0f', value);
        valueFormatter = @round;
        wlMotionScale = 1;
        isDoubleData = false;

        xMin = min(X(:));
        xMax = max(X(:));

        % Compute Histogram for the image.
        switch (class(X))
            case 'uint8'

                nbins = 256;

                [counts, bins] = imhist(X, nbins);
                finalBins = bins;

            case {'int16', 'uint16'}

                nbins = 65536/4;
                wlMotionScale = 4;

                [counts, bins] = imhist(X, nbins);
                finalBins = bins;

            case {'double', 'single'}

                % Images with double CData often don't work well with IMHIST.
                % Convert all images to be in the range [0,1] and convert back
                % later if necessary.
                if (xMin >= 0) && (xMax <= 1)

                    nbins = 256;

                    % Don't round values and use 4 places of precision for all values.
                    valueFormatter = @(x) x;
                    editFormatFcn = @(value) sprintf('%0.4f', value);
                    centerFormatFcn = editFormatFcn;
                    wlMotionScale = 1/255;
                    isDoubleData = true;

                else

                    if ((xMax - xMin) > 1023)

                        wlMotionScale = 4;
                        nbins = 1024;

                    elseif ((xMax - xMin) > 255)

                        wlMotionScale = 2;
                        nbins = 256;

                    else

                        nbins =round( xMax - xMin + 1);

                    end

                    X = mat2gray(X);

                end

                [counts, bins] = imhist(X, nbins); %bins is in range [0,1]
                finalBins = round(bins .* (xMax - xMin) + xMin); %finalBins is in range
                %of original data.

            otherwise

                error('Images:imcontrast:classNotSupported', ...
                    'This image class is not yet supported.')

        end

        %cannot use xMin or xMax because X changed for the double images in
        %non-default range of [0,1]
        idx = find((bins >= min(X(:))) & (bins <= max(X(:))));
        mu = mean(counts(idx));
        counts(counts > (8 * mu)) = 8 * mu;

        % Create the histogram panel.
        if length(Pos) == 4
            TempPos=Pos;
        else
            TempPos=[0 0 800 150];
        end
        
        hFig = figure('visible', 'off', ...
            'toolbar', 'none', ...
            'menubar', 'none', ...
            'IntegerHandle', 'off', ...
            'NumberTitle', 'off', ...
            'Name', 'Window/Level Tool', ...
            'tag', 'imcontrast', ...
            'HandleVisibility', 'callback', ...
            'units', 'pixels', ...
            'renderer', 'zbuffer', ...  % Work around a patch clipping bug.
            'position', TempPos, ...
            'UserData', 'ChildFig', ...
            'Resize', 'off');
        
         set(hFig, 'visible', 'on');
%         set(hFig, 'Units', 'normalized');


        hPanelHist = uipanel('parent', hFig, ...
            'units', 'normalized', ...
            'position', [0.0, 0.21, 1.0, 0.78]);

        hAx = axes('parent', hPanelHist);

        switch (nbins)
            case 256

                hStem = stem(hAx, finalBins, counts);

                switch (class(X))
                    case {'double', 'single'}

                        minX = 0;
                        maxX = 1;

                    otherwise

                        minX = 0;
                        maxX = 255;

                end

                setappdata(hFig, 'bitdepth', 8);

            case {1024, 65536/4}

                hStem = stem(hAx, finalBins(idx), counts(idx));
                minX = finalBins(idx(1)) - 100;
                maxX = finalBins(idx(end)) + 100;

                setappdata(hFig, 'bitdepth', 16);

            otherwise

                % For unusual images with a limited dynamic range and few
                % distinct values, display 256 gray levels.
                hStem = stem(hAx, finalBins(idx), counts(idx));

                if (xMin < 0)

                    minX = min(xMin, -128);
                    maxX = minX + 255;

                else
                    %PT
                    maxX = max(xMax, 50);
                    minX = min(xMin,-5);

                end

                setappdata(hFig, 'bitdepth', 8);

        end

        maxY = max(counts);

        set(hStem, 'marker', 'none')
        set(hAx, 'ytick', [], 'Units', 'normalized', 'Position', [0.05,0.2,0.9,0.8]);
        axis(hAx, [minX, maxX, 0, maxY]);

        setappdata(hAx, 'HistXLim', [minX maxX]);
        
        % IBSI_mod
        if flag_CT
            temp = get(hAx, 'xtick');
            set(hAx, 'xticklabels', cellstr(num2str(temp'-1000)));
        end
        % IBSI_mod
        
        %
        % Add the CLim window to the histogram panel.
        %

        % If the clim is already in the region, use those values.
        origCLim = get(hImageAx, 'clim');
        newCLim = [minX maxX];

        if (origCLim(1) > minX)
            newCLim(1) = origCLim(1);
        end

        if (origCLim(2) < maxX)
            newCLim(2) = origCLim(2);
        end

        % Draw the current CLIM window behind the histogram.
        hPatch = patch([newCLim(1) newCLim(1) newCLim(2) newCLim(2)], ...
            [0 maxY maxY 0], [1 0.8 0.8], ...
            'parent', hAx, 'zData', [-2 -2 -2 -2], ...
            'tag', 'WindowPatch', ...
            'ButtonDownFcn', @patchButtonDown);

        hMinLine = line('parent', hAx, 'tag', 'MinLine', ...
            'xdata', [newCLim(1) newCLim(1)], 'ydata', [0 maxY], ...
            'ZData', [-1 -1], ...
            'color', [1 0 0], ...
            'LineWidth', 1, ...
            'ButtonDownFcn', @minLineButtonDown);

        XLim = get(hAx, 'XLim');
        YLim = get(hAx, 'YLim');

        hMaxLine = line('parent', hAx, 'tag', 'MaxLine', ...
            'xdata', [newCLim(2) newCLim(2)], 'ydata', [0 maxY], ...
            'ZData', [-1 -1], ...
            'color', [1 0 0], ...
            'LineWidth', 1, ...
            'ButtonDownFcn', @maxLineButtonDown);

        [width, center] = computeWindow(newCLim);
        hCenterLine = line('parent', hAx, 'tag', 'CenterLine', ...
            'xdata', [center center], 'ydata', [0 maxY], ...
            'zdata', [-2 -2], ...
            'color', [1 0 0], ...
            'LineWidth', 1, ...
            'LineStyle', '--', ...
            'ButtonDownFcn', @patchButtonDown);

        % Add handles to make moving the endpoints easier for very small windows.
        [XShape, YShape] = getSidePatchShape;
        hMinPatch = patch('parent', hAx, ...
            'XData', newCLim(1) - (XShape * (XLim(2) - XLim(1))), ...
            'YData', YShape * YLim(2), ...
            'ZData', ones(size(XShape)), ...
            'FaceColor', [1 0 0], ...
            'EdgeColor', [1 0 0], ...
            'tag', 'MinPatch', ...
            'ButtonDownFcn', @minPatchDown);

        hMaxPatch = patch('parent', hAx, ...
            'XData', newCLim(2) + (XShape * (XLim(2) - XLim(1))), ...
            'YData', YShape * YLim(2), ...
            'ZData', ones(size(XShape)), ...
            'FaceColor', [1 0 0], ...
            'EdgeColor', [1 0 0], ...
            'tag', 'MaxPatch', ...
            'ButtonDownFcn', @maxPatchDown);

        [XShape, YShape] = getTopPatchShape;
        hCenterPatch = patch('parent', hAx, ...
            'XData', center + XShape .* (XLim(2) - XLim(1)), ...
            'YData', YShape * (YLim(2) - YLim(1)), ...
            'ZData', ones(size(XShape)), ...
            'FaceColor', [1 0 0], ...
            'EdgeColor', [1 0 0], ...
            'tag', 'CenterPatch', ...
            'ButtonDownFcn', @patchButtonDown);

        %
        % Create the window center/width and clipping panel.
        %

        hWindowClipPanel = uipanel('parent', hFig, ...
            'units', 'normalized', ...
            'position', [0.0, 0.0, 1.0, 0.2]);

        figColor = get(hWindowClipPanel, 'BackgroundColor');

        set(hWindowClipPanel, 'units', 'characters');

        labelLeft = 0;
        editLeft = 0;


        hMinLabel = uicontrol('parent', hWindowClipPanel, ...
            'units', 'characters', ...
            'style', 'text', ...
            'string', 'Level: ', ...
            'FontName', 'Calibri', ...
            'FontSize', 11, ...
            'FontWeight', 'bold', ...
            'HorizontalAlignment', 'left', ...
            'BackgroundColor', figColor);

        hMinEdit = uicontrol('parent', hWindowClipPanel, ...
            'units', 'characters', ...
            'Style', 'Edit', ...
            'Tag', 'MinEdit', ...
            'HorizontalAlignment', 'right', ...
            'BackgroundColor', [1 1 1], ...
            'FontName', 'Calibri', ...
            'FontSize', 11, ...
            'FontWeight', 'bold', ...
            'TooltipString', 'The window''s minimum intensity value', ...
            'callback', @editboxCallback);


        hMaxLabel = uicontrol('parent', hWindowClipPanel, ...
            'units', 'characters', ...
            'style', 'text', ...
            'string', 'Maximum Value', ...
            'HorizontalAlignment', 'left', ...
            'BackgroundColor', figColor, ...
            'Visible', 'off');

        hMaxEdit = uicontrol('parent', hWindowClipPanel, ...
            'units', 'characters', ...
            'Style', 'Edit', ...
            'Tag', 'MaxEdit', ...
            'HorizontalAlignment', 'right', ...
            'BackgroundColor', [1 1 1], ...
            'TooltipString', 'The window''s maximum intensity value', ...
            'callback', @editboxCallback, ...
            'Visible', 'off');


        hWidthLabel = uicontrol('parent', hWindowClipPanel, ...
            'units', 'characters', ...
            'style', 'text', ...
            'string', 'Window: ', ...
            'FontName', 'Calibri', ...
            'FontSize', 11, ...
            'FontWeight', 'bold', ...
            'HorizontalAlignment', 'left', ...
            'BackgroundColor', figColor);

        hWidthEdit = uicontrol('parent', hWindowClipPanel, ...
            'units', 'characters', ...
            'Style', 'Edit', ...
            'Tag', 'WidthEdit', ...
            'FontName', 'Calibri', ...
            'FontSize', 11, ...
            'FontWeight', 'bold', ...
            'HorizontalAlignment', 'right', ...
            'BackgroundColor', [1 1 1], ...
            'TooltipString', 'The width of the intensity window', ...
            'callback', @editboxCallback);

        hCenterLabel = uicontrol('parent', hWindowClipPanel, ...
            'units', 'characters', ...
            'style', 'text', ...
            'string', 'Window Center', ...
            'HorizontalAlignment', 'left', ...
            'BackgroundColor', figColor, ...
            'Visible', 'off');

        hCenterEdit = uicontrol('parent', hWindowClipPanel, ...
            'units', 'characters', ...
            'Style', 'Edit', ...
            'Tag', 'CenterEdit', ...
            'HorizontalAlignment', 'right', ...
            'BackgroundColor', [1 1 1], ...
            'TooltipString', 'The center of the intensity window', ...
            'callback', @editboxCallback, ...
            'Visible', 'off');

        %
        % Position all of the uicontrols.
        %

        % First find the maximum extents of the labels.
        labelExtents = get([hMinLabel, hWidthLabel], 'extent');
        allExtents = [labelExtents{:}];
        maxExtentLength = max(allExtents(3:4:end));
        maxExtentHeight = max(allExtents(4:4:end));

        % Next, align the midlines of the edit box and labels.
        editboxHeight = 1.5;

        bottomOffset = 1.5/2 - maxExtentHeight/2;

        buttonSize = maxExtentHeight;

        % Set the positions.
        set(hWidthLabel, 'position', [5,0.001 , ...
            maxExtentLength, maxExtentHeight]);
        set(hMaxLabel, 'position', [1, 2 - 2*bottomOffset + 1.5, ...
            maxExtentLength, maxExtentHeight]);
        set(hWidthEdit,  'position', [4+ maxExtentLength, 0.04, ...
            10, 1.5]);
        set(hMaxEdit,  'position', [1 + maxExtentLength, 2 + 1.5, ...
            8, 1.5]);


        set(hMinLabel, 'position', [4+ 2.5*maxExtentLength, 0.001, ...
            maxExtentLength, maxExtentHeight]);
        set(hCenterLabel,  'position', [maxExtentLength + 13 + 2*buttonSize + 1, 2 - 2*bottomOffset + 1.5, ...
            maxExtentLength, maxExtentHeight]);
        set(hMinEdit,  'position', [4+ 3.18*maxExtentLength, 0.04, ...
            10, 1.5]);
        set(hCenterEdit,   'position', [2*maxExtentLength + 13 + 2*buttonSize + 1, 2 + 1.5, ...
            8, 1.5]);


        %
        % Set the values and get ready to go.
        %

        resetEditValues;
        setappdata(hFig, 'InitialWindow', newCLim);
        set(hWindowClipPanel, 'units', 'normalized');


        % INKY SAYS STORE IN APPDATA.
        setappdata(hAx, 'AllowNudging', false);

        %Set Figure position


        % Display the figure.
        set(hFig, 'visible', 'on');

        %Set Icon


        %Set position to half inital width
        if length(Pos) ~=4

            OldUnit=get(hFig, 'Units');

            set(hFig, 'Units', 'pixels');
            GcfPos=get(hFig, 'Position');

            set(0,'Units','pixels')
            scnsize = get(0,'ScreenSize');

            set(hFig, 'Position', [round((scnsize(3)-GcfPos(3))/2), round((scnsize(4)-GcfPos(4))/2), GcfPos(3)*24.5/48, GcfPos(4)]);

            set(hFig, 'Units', OldUnit);
        end

        %Change application Icon
        figure(hFig);
        drawnow;	  

        %Settop window
        TempName=get(hFig, 'name');
        SetTopWindow(TempName);


        %-----------------------------------------------------------------------------------------
        %------------------------------SubFunctions------------------------------------------

        function editboxCallback(varargin)

            minValue = getEditValue(hMinEdit);
            maxValue = getEditValue(hMaxEdit);
            centerValue = getEditValue(hCenterEdit);
            widthValue = getEditValue(hWidthEdit);
            
            maxValue=minValue+widthValue;
            centerValue=minValue+widthValue/2;
            
            set(hMaxEdit, 'string', editFormatFcn(maxValue));
            set(hCenterEdit, 'string', centerFormatFcn(centerValue));

            % Validate data.
            % - If invalid: display dialog, reset to last good value, stop.
            % - If valid: go to other callback processor.
            if (any([isempty(minValue), ...
                    isempty(maxValue), ...
                    isempty(widthValue), ...
                    isempty(centerValue)]))

                errordlg({'Edit box values must be numeric values.'}, ...
                    'Invalid edit value', ...
                    'modal')

                resetEditValues;
                return;

            elseif (minValue >= maxValue)

                errordlg({'Minimum value must be less than maximum value.'}, ...
                    'Invalid edit value', ...
                    'modal')

                resetEditValues;
                return;

            elseif (((widthValue < 1) && (~isDoubleData)) || ...
                    (widthValue <= 0))

                errordlg({'Window width must be greater than zero.'}, ...
                    'Invalid edit value', ...
                    'modal')

                resetEditValues;
                return;

            elseif ((floor(centerValue * 2) ~= centerValue * 2) && (~isDoubleData))

                errordlg({'Invalid window center value.'}, ...
                    'Invalid edit value', ...
                    'modal')

                resetEditValues;
                return;

            end

            % Values are acceptable.
            updater(varargin{:})

        end


        function updater(varargin)

            if (nargin == 3)

                newCLim = varargin{end};
                newMin = newCLim(1);
                newMax = newCLim(2);

            end

            % What triggered the update?
            if (isa(varargin{1}, 'schema.prop'))

                component = 'CData';

            else

                component = get(varargin{1}, 'tag');

            end

            % Determine new endpoints.
            switch (component)
                case 'CData'

                    newCData = get(varargin{2}, 'NewValue');
                    newMin = newCData(1);
                    newMax = newCData(2);

                case {'CenterEdit'}

                    centerValue = getEditValue(hCenterEdit);
                    widthValue = getEditValue(hWidthEdit);
                                        
                    [newMin, newMax] = computeCLim(widthValue, centerValue);

                    if ((newMin < XLim(1)) && (newMax > XLim(2)))

                        newMin = XLim(1);
                        newMax = XLim(2);

                    elseif (newMin < XLim(1))

                        newMin = XLim(1);
                        newMax = newMin + 2 * (centerValue - newMin);

                    elseif (newMax > XLim(2))

                        newMax = XLim(2);
                        newMin = newMax - 2 * (newMax - centerValue);

                    end


                case {'WidthEdit'}

                    centerValue = getEditValue(hCenterEdit);
                    widthValue = getEditValue(hWidthEdit);
                    
                    [newMin, newMax] = computeCLim(widthValue, centerValue);

                    if ((newMin < XLim(1)) && (newMax > XLim(2)))

                        newMin = XLim(1);
                        newMax = XLim(2);

                    elseif (newMin < XLim(1))

                        newMin = XLim(1);
                        newMax = newMin + widthValue;

                    elseif (newMax > XLim(2))

                        newMax = XLim(2);
                        newMin = newMax - widthValue;

                    end

                case {'MinEdit', 'MaxEdit', 'MinDropper', 'MaxDropper'}

                    newMin = getEditValue(hMinEdit);
                    newMax = getEditValue(hMaxEdit);

                case {'MinLine', 'MaxLine', 'CenterLine', 'MinPatch', 'MaxPatch'}

                    minXData = get(hMinLine, 'XData');
                    newMin = minXData(1);
                    maxXData = get(hMaxLine, 'XData');
                    newMax = maxXData(1);

                case {'WindowPatch'}

                    origWidth = getEditValue(hWidthEdit);

                    minXData = get(hMinLine, 'XData');
                    newMin = minXData(1);
                    maxXData = get(hMaxLine, 'XData');
                    newMax = maxXData(1);

                case {'AutoButton', 'ResetButton'}

                    newCLim = varargin{end};
                    newMin = newCLim(1);
                    newMax = newCLim(2);

                case {'imcontrast'}

                    % Why does this code path get called?
                    if (nargin ~= 3)

                        newCLim = get(hImageAx, 'CLim');
                        newMin = newCLim(1);
                        newMax = newCLim(2);

                    end

                otherwise

                    errordlg({'You have updated the contrast/brightness in an unexpected way.'}, ...
                        'Unexpected update', ...
                        'modal')

                    resetEditValues;
                    return;

            end

            % Prevent new endpoints from exceeding visible min or max.
            % Don't let window shrink when dragging the window patch.
            if (newMin < XLim(1))

                if (isequal(component, 'WindowPatch'))
                    newMin = XLim(1);
                    newMax = newMin + origWidth;
                else
                    newMin = XLim(1);
                end

            end

            if (newMax > XLim(2))

                if (isequal(component, 'WindowPatch'))
                    newMax = XLim(2);
                    newMin = newMax - origWidth;
                else
                    newMax = XLim(2);
                end

            end

            % Keep min < max
            if (((newMax - 1) < newMin) && (~isDoubleData))

                if (getappdata(hFig, 'allowNudging'))

                    % Nudge one of the values.
                    if (isequal(component, 'MinLine') || (newMax == XLim(1)))
                        % The min line was moved or the max line was moved to the min.
                        newMax = newMin + 1;
                    else
                        % The max line was moved or the min line was moved to the max.
                        newMin = newMax - 1;
                    end

                else

                    % Stop at limiting value.
                    CLim = get(hImageAx, 'CLim');
                    newMin = CLim(1);
                    newMax = CLim(2);

                end

                %Made this less than or equal to as a possible workaround to g226780
            elseif ((newMax <= newMin) && (isDoubleData))

                % Stop at limiting value.
                CLim = get(hImageAx, 'CLim');
                newMin = CLim(1);
                newMax = CLim(2);
            end

            % Update edit boxes with new values.
            set(hMinEdit, 'String', editFormatFcn(newMin));
            set(hMaxEdit, 'String', editFormatFcn(newMax));
            [width, center] = computeWindow([newMin newMax]);
            set(hWidthEdit, 'string', editFormatFcn(width));
            if (floor(center) == center)
                set(hCenterEdit, 'String', centerFormatFcn(center));
            else
                set(hCenterEdit, 'String', centerFormatFcn(center));
            end

            % Update patch display.
            updateHistogram('endpoints', [newMin newMax]);

            % Update image CLim.
            updateImage(hImageAx, [newMin newMax]);

        end


        function minLineButtonDown(varargin)
            setappdata(hAx, 'currentLine', hMinLine);
            lineButtonDown(varargin{:});
        end


        function maxLineButtonDown(varargin)
            setappdata(hAx, 'currentLine', hMaxLine);
            lineButtonDown(varargin{:});
        end


        function lineButtonDown(varargin)

            idButtonMotion = iptaddcallback(hFig, 'WindowButtonMotionFcn', @lineMove);
            idButtonUp = iptaddcallback(hFig, 'WindowButtonUpFcn', @lineUp);

            function lineUp(varargin)
                iptremovecallback(hFig, 'WindowButtonMotionFcn', idButtonMotion);
                iptremovecallback(hFig, 'WindowButtonUpFcn', idButtonUp);

                newLim = valueFormatter(get(hImageAx, 'CLim'));
                updater(varargin{1}, [], newLim);

            end

        end


        function lineMove(varargin)

            % Determine which line is being dragged and set appropriate values.
            hLine = getappdata(hAx, 'currentLine');

            cp = get(hAx, 'CurrentPoint');
            xpos = cp(1);

            if (hLine == hMaxLine)
                set(hMaxLine, 'XData', [xpos xpos]);
            elseif (hLine == hMinLine)
                set(hMinLine, 'XData', [xpos xpos]);
            end

            % Update the image, histogram, etc.
            updater(hLine);

        end


        function delta = computeMotionDelta(hObject)

            cp = get(hAx, 'CurrentPoint');

            % Don't register changes if the pointer is outside the W/L window.
            if (cp(1) <= XLim(1))

                cp(1) = XLim(1);

            elseif (cp(2) >= XLim(2))

                cp(1) = XLim(2);

            end

            % Determine how much to slide the window.
            motionOrigin = getappdata(hObject, 'motionOrigin');
            setappdata(hObject, 'motionOrigin', cp);

            delta = cp(1) - motionOrigin(1);

        end


        function patchButtonDown(varargin)

            setappdata(hPatch, 'motionOrigin', get(hAx, 'CurrentPoint'));
            setappdata(hAx, 'currentLine', hPatch);

            idButtonMotion = iptaddcallback(hFig, 'windowButtonMotionFcn', @patchMove);
            idButtonUp = iptaddcallback(hFig, 'WindowButtonUpFcn', @patchUp);


            function patchUp(varargin)

                iptremovecallback(hFig, 'WindowButtonMotionFcn', idButtonMotion);
                iptremovecallback(hFig, 'WindowButtonUpFcn', idButtonUp);

                newLim = valueFormatter(get(hImageAx, 'CLim'));
                updater(varargin{1}, [], newLim);

            end


            function patchMove(varargin)

                delta = computeMotionDelta(hPatch);

                % Set the window endpoints.
                set(hMinLine, 'XData', get(hMinLine, 'XData') + delta);
                set(hMaxLine, 'XData', get(hMaxLine, 'XData') + delta);

                updater(hPatch);

            end

        end


        function minPatchDown(varargin)

            setappdata(hMinPatch, 'motionOrigin', get(hAx, 'CurrentPoint'))

            idButtonMotion = iptaddcallback(hFig, 'WindowButtonMotionFcn', @patchMove);
            idButtonUp = iptaddcallback(hFig, 'WindowButtonUpFcn', @patchUp);


            function patchUp(varargin)
                iptremovecallback(hFig, 'WindowButtonMotionFcn', idButtonMotion);
                iptremovecallback(hFig, 'WindowButtonUpFcn', idButtonUp);

                newLim = valueFormatter(get(hImageAx, 'CLim'));
                updater(hMinPatch, [], newLim);

            end


            function patchMove(varargin)

                delta = computeMotionDelta(hMinPatch);

                % Set the window endpoints.
                set(hMinLine, 'XData', get(hMinLine, 'XData') + delta);
                updater(hMinPatch);

            end

        end


        function maxPatchDown(varargin)

            setappdata(hMaxPatch, 'motionOrigin', get(hAx, 'CurrentPoint'))

            idButtonMotion = iptaddcallback(hFig, 'WindowButtonMotionFcn', @patchMove);
            idButtonUp = iptaddcallback(hFig, 'WindowButtonUpFcn', @patchUp);


            function patchUp(varargin)
                iptremovecallback(hFig, 'WindowButtonMotionFcn', idButtonMotion);
                iptremovecallback(hFig, 'WindowButtonUpFcn', idButtonUp);

                newLim = valueFormatter(get(hImageAx, 'CLim'));
                updater(hMaxPatch, [], newLim);

            end


            function patchMove(varargin)

                delta = computeMotionDelta(hMaxPatch);

                % Set the window endpoints.
                set(hMaxLine, 'XData', get(hMaxLine, 'XData') + delta);
                updater(hMaxPatch);

            end

        end


        function updateHistogram(mode, newValues)

            sidePatchXData = getSidePatchShape * getPatchScale;
            topPatchXData = getTopPatchShape * getPatchScale;

            switch (mode)
                case 'endpoints'

                    currentMin = newValues(1);
                    currentMax = newValues(2);
                    [width, center] = computeWindow(newValues);

                    set(hMinLine, 'XData', [currentMin currentMin]);
                    set(hMaxLine, 'XData', [currentMax currentMax]);
                    set(hPatch, 'XData', [currentMin currentMin currentMax currentMax]);
                    set(hCenterLine, 'XData', [center center]);
                    set(hMinPatch, 'XData', currentMin - sidePatchXData);
                    set(hMaxPatch, 'XData', currentMax + sidePatchXData);
                    set(hCenterPatch, 'XData', center + topPatchXData);

                case 'delta'

                    delta = newValues;
                    set(hMinLine, 'XData', get(hMinLine, 'XData') + delta);
                    set(hMaxLine, 'XData', get(hMaxLine, 'XData') + delta);
                    set(hPatch, 'XData', get(hPatch, 'XData') + delta);
                    set(hCenterLine, 'XData', get(hCenterLine, 'XData') + delta);
                    set(hMinPatch, 'XData', get(hMinPatch, 'XData') + delta);
                    set(hMaxPatch, 'XData', get(hMaxPatch, 'XData') + delta);
                    set(hCenterPatch, 'XData', get(hCenterPatch, 'XData') + delta);

            end

        end


        function resetEditValues

            CLim = get(hImageAx, 'CLim');

            [widthValue, centerValue] = computeWindow([CLim(1) CLim(2)]);

            set(hMinEdit, 'string', editFormatFcn(CLim(1)))
            set(hMaxEdit, 'string', editFormatFcn(CLim(2)))
            set(hWidthEdit, 'string', editFormatFcn(widthValue))
            set(hCenterEdit, 'string', centerFormatFcn(centerValue))

        end


        function updateImage(hImage, clim)

            if clim(1) >= clim(2)
                eid = sprintf('Images:%s:internalError',mfilename);
                msg = 'Internal error - clim(1) is >= clim(2).';
                error(eid,'%s',msg);
            end

            set(HandleGroup, 'clim', clim);
            drawnow;

        end



        function [xFactor, yFactor] = getPatchScale

            XLim = get(hAx, 'XLim');
            YLim = get(hAx, 'YLim');

            xFactor = XLim(2) - XLim(1);
            yFactor = YLim(2) - YLim(1);

        end


        function value = getEditValue(hEdit)

            if (ishandle(hEdit))
                value = valueFormatter(sscanf(get(hEdit, 'string'), '%f'));
            else
                value = [];
            end

        end
    end



    function [minPixel, maxPixel] = computeCLim(width, center)
        %FINDWINDOWENDPOINTS   Process window and level values.

        minPixel = (center - width/2);        
        maxPixel = minPixel + width;
    end



    function [width, center] = computeWindow(CLim)

        width = CLim(2) - CLim(1);
        center = CLim(1) + width ./ 2;
    end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function [XData, YData] = getSidePatchShape

        XData = [0.00 -0.007 -0.007 0.00 0.01 0.02 0.02 0.01];
        YData = [0.40  0.42   0.58  0.60 0.60 0.56 0.44 0.40];

    end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function [XData, YData] = getTopPatchShape

        XData = [-0.015 0.015 0];
        YData = [1 1 0.95];
    end

end

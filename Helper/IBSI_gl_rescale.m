function [CDataSetInfo, Param] = IBSI_gl_rescale(CDataSetInfo, Param)

data_class = class(CDataSetInfo.ROIImageInfo.MaskData);
CurrentImg = double(CDataSetInfo.ROIImageInfo.MaskData);
CurrentMask = CDataSetInfo.ROIBWInfo.MaskData;
ImgROIVector = CurrentImg(CurrentMask == 1);

%----Max e Min inside the ROI if no re-segmentation range is provided
if isfield(CDataSetInfo.ROIImageInfo, 'GrayLimits')
    InputRange=CDataSetInfo.ROIImageInfo.GrayLimits;
else
    InputRange=[min(ImgROIVector), max(ImgROIVector)];
end

%----Rescale all Bounding Box
Param.Rescale = lower(Param.Rescale);
%----Discrete calibrated image intensities
wd = 1;
switch Param.Rescale
    case 'off'
        if isfield(CDataSetInfo.ROIImageInfo, 'Discretised')
            NumLevels = CDataSetInfo.ROIImageInfo.NumLevels;
            G = CDataSetInfo.ROIImageInfo.G;
            X_gl_d = CDataSetInfo.ROIImageInfo.X_gl_d;
            X_d = CDataSetInfo.ROIImageInfo.X_d;
        else
            NumLevels = max(ImgROIVector);
            G = InputRange;                                         % Total range
            X_gl_d = G(1):wd:G(2);                                  % Voxel set discretised
            X_d = X_gl_d;                                           % Bin Numbers [1:length(X_gl_d);]
        end

        %----Warnings
        if isempty(strfind(lower(data_class), 'int'))
            warning('a. Attention, the image should have integer values')
        end
    case 'fbn'
        InputRange=[min(ImgROIVector), max(ImgROIVector)]; % overwrite Max e Min
        idx_min = CurrentImg <= InputRange(1);
        idx_max = CurrentImg >= InputRange(2);

        G = [1 Param.BinNumber];                                % Total range
        % X_gl = unique(ImgROIVector);                          % Voxel set (not used)   
        X_d = 1:wd:Param.BinNumber;                             % Bin Numbers
        X_gl_d = X_d;                                           % Voxel set discretised [? min(ImgROIVector):wb:max(ImgROIVector)]

        %----Filter
        CurrentImg_fbn = CurrentImg;
        
        % % IBSIv6
        % CurrentImg_fbn(:) = ceil(Param.BinNumber*(CurrentImg(:)-InputRange(1))/(InputRange(2)-InputRange(1)));
        % % end IBSIv6
        
        % % IBSIv11
        CurrentImg_fbn(:) = floor(Param.BinNumber*(CurrentImg(:)-InputRange(1))/(InputRange(2)-InputRange(1)))+1;
        % % end IBSIv11
        
        CurrentImg_fbn(idx_min) = 1;
        CurrentImg_fbn(idx_max) = Param.BinNumber;
        CurrentImg = CurrentImg_fbn;
        NumLevels = max(CurrentImg_fbn(CurrentMask == 1));

        %----Warnings
        if isfield(CDataSetInfo.ROIImageInfo, 'Discretised')
            warning('b. Image was already discretised. Consider using ''off''')
        end
    case 'fbs'
        idx_min = CurrentImg <= InputRange(1);
        idx_max = CurrentImg > InputRange(2);
        
        %----Filter
        CurrentImg_fbs = CurrentImg;
        
        % % IBSIv6
        % CurrentImg_fbs(:) = ceil((CurrentImg(:)-InputRange(1))/Param.BinSize);
        % % end IBSIv6
        
        % % IBSIv11
        CurrentImg_fbs(:) = floor((CurrentImg(:)-InputRange(1))/Param.BinSize)+1;
        % % end IBSIv11
        
        CurrentImg_fbs(idx_min) = 1;
        CurrentImg_fbs(idx_max) = max(CurrentImg_fbs(CurrentMask == 1));
        CurrentImg = CurrentImg_fbs;
        NumLevels = max(CurrentImg_fbs(CurrentMask == 1));

        ImgROIVector_d = CurrentImg(CurrentMask == 1);
        % X_gl = InputRange(1):Param.BinSize:InputRange(2);     % Voxel set (not used)
        X_d = 1:wd:max(ImgROIVector_d);                         % Bin Numbers
        X_gl_d = InputRange(1)+(X_d-0.5)*Param.BinSize;         % Voxel set discretised
        G = [X_gl_d(1) X_gl_d(end)];                            % Total range

        %----Warnings
        if ~isempty(strfind(lower(CDataSetInfo.Modality), 'preprocess'))
            warning('c. fbs with aribitrary intensity values. Consider using ''fbn''')
        end
        if isfield(CDataSetInfo.ROIImageInfo, 'Discretised')
            warning('d. Image was already discretised. Consider using ''off''')
        end
    otherwise
        error('Select a correct discretisation method from {''fbn'', ''fbs'', ''off''}')
end

Param.NumLevels = NumLevels;
Param.G = G;
Param.X_d = X_d;
Param.X_gl_d = X_gl_d;

%----Update Image
ClassName=class(CDataSetInfo.ROIImageInfo.MaskData);
ClassFunc=str2func(ClassName);
CDataSetInfo.ROIImageInfo.MaskData=ClassFunc(CurrentImg);
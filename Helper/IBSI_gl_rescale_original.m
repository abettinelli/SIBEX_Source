function [CDataSetInfo, Param] = IBSI_gl_rescale(CDataSetInfo, Param)

CurrentImg = CDataSetInfo.ROIImageInfo.MaskData;
data_class = class(CurrentImg);
CurrentImg = double(CurrentImg);
CurrentMask = CDataSetInfo.ROIBWInfo.MaskData;

% Max e Min inside the ROI if no re-segmentation range is provided 
if isfield(CDataSetInfo.ROIBWInfo, 'GrayLimits')
    InputRange=CDataSetInfo.ROIBWInfo.GrayLimits;
else
    InputRange=[min(CurrentImg(CurrentMask == 1)), max(CurrentImg(CurrentMask == 1))];
end

% Rescale all Bounding Box
if isequal(lower(Param.Rescale), 'off')
	% CurrentImg = round(CurrentImg);
    
    CurrentImg = round(CurrentImg-InputRange(1)+1);
    NumLevels = max(CurrentImg(CurrentMask == 1));
    
    if (data_class ~= int8) && (data_class ~= uint8) && (data_class ~= int16) && (data_class ~= uint16)
        disp('Attention, the original image must have integer values')
    end
elseif isequal(lower(Param.Rescale), 'fbn')
    InputRange=[min(CurrentImg(CurrentMask == 1)), max(CurrentImg(CurrentMask == 1))]; % overwrite Max e Min
    
    idx_min = CurrentImg <= InputRange(1);
    idx_max = CurrentImg > InputRange(2);
    
    % Check BinNumber
    BinNumber = Param.BinNumber;
    
    %Filter
    CurrentImg_fbn = CurrentImg;
    CurrentImg_fbn(:) = ceil(BinNumber*(CurrentImg(:)-InputRange(1))/(InputRange(2)-InputRange(1)));
    CurrentImg_fbn(idx_min) = 1;
    CurrentImg_fbn(idx_max) = BinNumber;
    
    CurrentImg = CurrentImg_fbn;
    NumLevels = max(CurrentImg_fbn(CurrentMask == 1));
    
    if ~isfield(CDataSetInfo.ROIImageInfo, 'Discretised')
        disp('Image was already discretised. Consider using ''off''')
    end
elseif isequal(lower(Param.Rescale), 'fbs')
    
    idx_min = CurrentImg <= InputRange(1);
    idx_max = CurrentImg > InputRange(2);

    % CHeck bin Size
    BinSize = Param.BinSize;
    
	%Filter
    CurrentImg_fbs = CurrentImg;
    CurrentImg_fbs(:) = ceil((CurrentImg(:)-InputRange(1))/BinSize);
    CurrentImg_fbs(idx_min) = 1;
    CurrentImg_fbs(idx_max) = max(CurrentImg_fbs(CurrentMask == 1));
    
    CurrentImg = CurrentImg_fbs;
    NumLevels = max(CurrentImg_fbs(CurrentMask == 1));
    
    if contains(lower(CDataSetInfo.Modality), 'preprocess')
        disp('FBS with aribitrary intensity values. Consider using ''fbn''')
    end
    if isfield(CDataSetInfo.ROIImageInfo, 'Discretised')
        disp('Image was already discretised. Consider using ''off''')
    end
else
    error('Select a correct discretisation method from {''fbn'', ''fbs'', ''off''}')
end

Param.NumLevels = NumLevels;
% Update Image
ClassName=class(CDataSetInfo.ROIImageInfo.MaskData);
ClassFunc=str2func(ClassName);
CDataSetInfo.ROIImageInfo.MaskData=ClassFunc(CurrentImg);
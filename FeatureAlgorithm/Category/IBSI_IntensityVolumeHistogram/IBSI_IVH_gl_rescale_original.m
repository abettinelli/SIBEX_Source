function [ImgVector, ImgVector_d, G, Xd, Xd_gl] = IBSI_IVH_gl_rescale(CDataSetInfo, Param)

CurrentImg = double(CDataSetInfo.ROIImageInfo.MaskData);
CurrentMask = CDataSetInfo.ROIBWInfo.MaskData;
ImgVector = CurrentImg(CurrentMask == 1);

% Max e Min for rescale are calculated only for ROI voxels if no
% re-segmentation range is provided (or if the image was discretisized in the pre-processing)
if isfield(CDataSetInfo.ROIBWInfo, 'GrayLimits') && ~isfield(CDataSetInfo.ROIImageInfo, 'Discretised')
    InputRange=CDataSetInfo.ROIBWInfo.GrayLimits;
%     if isequal(CDataSetInfo.Modality, 'CT')
%         InputRange = InputRange-1000;
%     end
else
    InputRange = [min(ImgVector) max(ImgVector)];
end

% Rescale Image FBN/FBS solo dentro la maschera
wd = 1;
if isequal(lower(Param.Rescale), 'off') % Definite intensity units - discrete case
    
%     X_gl = min(ImgVector):1:max(ImgVector);
    
	ImgVector_d = round(ImgVector);
    G = InputRange;
    Xd_gl = G(1):wd:G(2);
    Xd = Xd_gl; % da sistemare
    
elseif isequal(lower(Param.Rescale), 'fbs') % Definite intensity units - continuous case
    
%     X_gl = min(ImgVector):Param.BinSize:max(ImgVector);
    
    %Discretisation
    ImgVector_d = ceil((ImgVector-InputRange(1))/Param.BinSize);
    ImgVector_d(ImgVector_d == 0) = 1;
    
    Xd = 1:wd:max(ImgVector_d);
    
    Xd_gl = InputRange(1)+(Xd-0.5)*Param.BinSize;
    G = [Xd_gl(1) Xd_gl(end)];
    
%     G = [InputRange(1)+0.5*Param.BinSize InputRange(2)-0.5*Param.BinSize];
%     Xd_gl2 = G(1):Param.BinSize:G(2);
    
elseif isequal(lower(Param.Rescale), 'fbn')  % Arbitrary Intensity Units
    InputRange = [min(ImgVector) max(ImgVector)];
    
    wb = (max(ImgVector)-min(ImgVector)+1)/Param.BinNumber;
    X_gl = min(ImgVector):wb:max(ImgVector);
    
    %Discretisation
    ImgVector_d = ceil(Param.BinNumber*(ImgVector-InputRange(1))/(InputRange(2)-InputRange(1)));
    ImgVector_d(ImgVector_d <= 0) = 1;
    ImgVector_d(ImgVector_d > Param.BinNumber) = Param.BinNumber;
    
    Xd = min(ImgVector_d):wd:max(ImgVector_d);
    
    G = [min(ImgVector_d), max(ImgVector_d)];
    Xd_gl = G(1):wd:G(2);
    
else
    error('Select a correct discretisation method from {''fbn'', ''fbs'', ''off''}')
end
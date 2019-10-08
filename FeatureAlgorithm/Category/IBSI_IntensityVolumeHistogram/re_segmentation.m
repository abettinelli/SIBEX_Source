function [CDataSetInfo] = re_segmentation(CDataSetInfo, Param)

CurrentImg = double(CDataSetInfo.ROIImageInfo.MaskData);
CurrentMask = CDataSetInfo.ROIBWInfo.MaskData;
    
GL = Param.GrayLimits;
if isempty(GL)
    GL = [min(CurrentImg(CurrentMask == 1)) max(CurrentImg(CurrentMask == 1))];
elseif numel(GL) ~= 2
    eid = sprintf('Images:%s:invalidGrayLimitsSize',mfilename);
    error(eid, 'GL must be a two-element vector.');
end
GL = double(GL);

% Update current mask
idx_abovemin = CurrentImg >= GL(1);
idx_belowmax = CurrentImg <= GL(2);
idx = (idx_abovemin & idx_belowmax) & CurrentMask;
CurrentMask = int32(idx);

% Update Mask and Image
ClassName=class(CDataSetInfo.ROIBWInfo.MaskData);
ClassFunc=str2func(ClassName);
CDataSetInfo.ROIBWInfo.MaskData = ClassFunc(CurrentMask);
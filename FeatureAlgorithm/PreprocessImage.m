function CDataSetInfo=PreprocessImage(TestStruct, CDataSetInfo)
PreprocessName={TestStruct.Name}';
for i=1:length(PreprocessName)
    fhandle=str2func(PreprocessName{i});
    
    [ROIImageInfo, ROIBWInfo]=fhandle(CDataSetInfo, TestStruct(i).Value);
    
    %Preprocess-Resample Voxel
    if isfield(ROIImageInfo, 'CDataSetInfo')
        CDataSetInfo=UpdateCDataSetInfo(CDataSetInfo, ROIImageInfo.CDataSetInfo);
        ROIImageInfo=rmfield(ROIImageInfo, 'CDataSetInfo');
    end
    
    %Update image type and max-min ROI
    [CDataSetInfo,ROIImageInfo]=UpdateModality(CDataSetInfo, ROIImageInfo);
    
    %Update summary
    [CDataSetInfo,ROIImageInfo]=UpdateSummary(CDataSetInfo, ROIImageInfo);
    
    %Update image type and max-min ROI
    CDataSetInfo.ROIMaxV = max(CDataSetInfo.ROIImageInfo.MaskData(CDataSetInfo.ROIBWInfo.MaskData == 1));
    CDataSetInfo.ROIMinV = min(CDataSetInfo.ROIImageInfo.MaskData(CDataSetInfo.ROIBWInfo.MaskData == 1));
    
    % Update ROI Image and Mask
    CDataSetInfo.ROIImageInfo=ROIImageInfo;
    CDataSetInfo.ROIBWInfo=ROIBWInfo;
end

function CDataSetInfo=UpdateCDataSetInfo(CDataSetInfo, NewCDataSetInfo)
CDataSetInfo.XDim=NewCDataSetInfo.XDim;
CDataSetInfo.YDim=NewCDataSetInfo.YDim;
CDataSetInfo.ZDim=NewCDataSetInfo.ZDim;

CDataSetInfo.ImageXDim=NewCDataSetInfo.XDim;
CDataSetInfo.ImageYDim=NewCDataSetInfo.YDim;
CDataSetInfo.ImageZDim=NewCDataSetInfo.ZDim;

CDataSetInfo.ROIXDim=size(CDataSetInfo.ROIBWInfo.MaskData, 2);
CDataSetInfo.ROIYDim=size(CDataSetInfo.ROIBWInfo.MaskData, 1);
CDataSetInfo.ROIZDim=size(CDataSetInfo.ROIBWInfo.MaskData, 3);

CDataSetInfo.XPixDim=NewCDataSetInfo.XPixDim;
CDataSetInfo.YPixDim=NewCDataSetInfo.YPixDim;
CDataSetInfo.ZPixDim=NewCDataSetInfo.ZPixDim;

CDataSetInfo.XStart=NewCDataSetInfo.XStart;
CDataSetInfo.YStart=NewCDataSetInfo.YStart;
CDataSetInfo.ZStart=NewCDataSetInfo.ZStart;

CDataSetInfo.structAxialROI=NewCDataSetInfo.structAxialROI;

function [CDataSetInfo,ROIImageInfo]=UpdateModality(CDataSetInfo, ROIImageInfo)

if isfield(ROIImageInfo, 'Summary')
    if ROIImageInfo.Summary.BreakIntensity == 1
        if isempty(strfind(lower(CDataSetInfo.Modality), 'preprocess'))
            CDataSetInfo.Modality=[CDataSetInfo.Modality '_PREPROCESS'];
        else
            % Already marked
        end
    end
end

function [CDataSetInfo,ROIImageInfo]=UpdateSummary(CDataSetInfo, ROIImageInfo)

if isfield(ROIImageInfo, 'Summary')
    if isfield(CDataSetInfo, 'Summary')
        CDataSetInfo.Summary(end+1) = ROIImageInfo.Summary;
    else
        CDataSetInfo.Summary = ROIImageInfo.Summary;
    end
    ROIImageInfo=rmfield(ROIImageInfo, 'Summary');
end
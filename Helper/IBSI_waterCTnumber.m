function CDataSetInfo = IBSI_waterCTnumber(CDataSetInfo)

%---- Only for CT modality
if strcmp(CDataSetInfo.Modality, 'CT')
    if ~isfield(CDataSetInfo, 'Pinnacle')
        CDataSetInfo.Pinnacle = true;
    end
else
    CDataSetInfo.Pinnacle = false;
end

if CDataSetInfo.Pinnacle
    CDataSetInfo.ROIImageInfo.MaskData = int16(CDataSetInfo.ROIImageInfo.MaskData)-1000;
    CDataSetInfo.ROIImageInfo.MaskData(CDataSetInfo.ROIImageInfo.MaskData < -1000) = -1000;
    CDataSetInfo.Pinnacle = false;
end
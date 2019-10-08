function structAxialROI=ROIImportMethod_Matlab(FileName, ImageDataInfo)

%Import
try
    load(FileName, '-mat');
    
    if ~exist('structAxialROI', 'var')        
        structAxialROI=[];
    end
catch
    structAxialROI=[];
end
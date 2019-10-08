function ReturnFlag=ROIExportMethod_Pinnacle(ExportPath, structAxialROI, BWMatInfo, PatInfo)
%%%Doc Starts%%%
%-Purpose: 
%ROIs are exported into the Pinnacle treatment planning system's ROI format.

%-Format Description:
%1.  Pinnacle ROI file is ASCII file. It can be opened by any text editors. 
%     Pinnacle ROI file describes ROI properties and 2D ROI curve's coordinates. 
%     It doesn't care patient's MRN and patient's name.  
%2.  ROI binary mask is not exported in this format. 

%-Revision:
%2014-09-19: The method is implemented.

%-Author:
%Joy Zhang, lifzhang@mdanderson.org
%%%Doc Ends%%%


%File Name
FileName=[PatInfo.LastName, '_', PatInfo.FirstName, '_', PatInfo.MRN, '_', datestr(now, 30), '.roi'];

[FileName, ExportPath]=uiputfile({'*.roi','Pinnacle ROI files (*.roi)'; '*.*','All Files (*.*)' }, 'Save file name', [ExportPath, '\', FileName]);

if isequal(FileName, 0) || isequal(ExportPath, 0)
    ReturnFlag=2;
    return;
end

%Export
try
    for i=1:length(structAxialROI)
        if isempty(structAxialROI(i).CurvesCor)
            structAxialROI(i).CurvesCor={};
        end
    end
    
    WriteROIStruct(structAxialROI, [ExportPath, '\', FileName], [0, 0], [PatInfo.LastName, '^', PatInfo.FirstName,  '^^^']);
    
    ReturnFlag=1;   
catch
    ReturnFlag=0;
end




function ReturnFlag=ROIExportMethod_Matlab(ExportPath, structAxialROI, BWMatInfo, PatInfo)

%%%Doc Starts%%%
%-Purpose: 
%ROIs are exported into Matlab format.

%-Format Description:
%1.  Variable 'structAxialROI':  contains the curve information of each ROI. Its data type  is structure. 
%     It has fields describing ROI name, 2D ROI curve's coordinates, curve's slice location.
%2.  Variable 'BWMatInfo':  contains the binary mask information of each ROI. Its data type  is structure. 
 %    It has fields describing the raw data of binary mask, binary mask's start point, its dimension, and its voxel size.
 %3. Variable 'PatInfo': contains the last name, the first name, and the MRN of the patient. 
 

%-Revision:
%2014-09-19: The method is implemented.

%-Author:
%Joy Zhang, lifzhang@mdanderson.org
%%%Doc Ends%%%

%File Name
FileName=[PatInfo.LastName, '_', PatInfo.FirstName, '_', PatInfo.MRN, '_', datestr(now, 30), '.mat'];

[FileName, ExportPath]=uiputfile({'*.mat','MATLAB MAT files (*.mat)'; '*.*','All Files (*.*)' }, 'Save file name', [ExportPath, '\', FileName]);

if isequal(FileName, 0) || isequal(ExportPath, 0)
    ReturnFlag=2;
    return;
end

%Export
try
    save('-mat', [ExportPath, '\', FileName], 'structAxialROI', 'BWMatInfo', 'PatInfo')
    ReturnFlag=1;    
catch
    ReturnFlag=0;
end









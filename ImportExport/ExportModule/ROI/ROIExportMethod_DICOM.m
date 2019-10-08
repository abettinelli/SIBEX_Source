function ReturnFlag=ROIExportMethod_DICOM(ExportPath, structAxialROI, BWMatInfo, PatInfo)
%%%Doc Starts%%%
%-Purpose: 
%ROIs are exported into the DICOM RT Struct format.

%-Format Description:
%1.  The Image UID information is perserved if available. 
%2.  The ROIs with no curvs are not exported.
%2.  If no image UIDs are available, the new image UIDs are generated. 
%Under this scenerio, the exported DICOM RT Struct file may not be able to be imported 
%dependent upon the individual DICOM importer. 

%-Revision:
%2014-09-22: The method is implemented.

%-Author:
%Joy Zhang, lifzhang@mdanderson.org
%%%Doc Ends%%%

%RS File Name
FileName=['RS_', PatInfo.LastName, '_', PatInfo.FirstName, '_', PatInfo.MRN, '_', datestr(now, 30), '.dcm'];

[FileName, ExportPath]=uiputfile({'*.dcm','DICOM files (*.dcm)'; '*.*','All Files (*.*)' }, 'Save file name', [ExportPath, '\', FileName]);

if isequal(FileName, 0) || isequal(ExportPath, 0)
    ReturnFlag=2;
    return;
end

%Export
try
    %Image UID Info
    ImgUIDInfo=GetImgUIDs(PatInfo);
    
    TempV=struct2cell(ImgUIDInfo);
    TempV=cellfun('isempty', TempV);
    
    if ~isempty(find(TempV))
        Answer = QuestdlgIFOA('New image UIDs will be created due to no available information. Continue?', 'Confirm','Continue','Cancel', 'Continue');
        if ~isequal(Answer, 'Continue')
            ReturnFlag=0;
            return;
        else
            NumSlice=PatInfo.Slices;
            ImgUIDInfo=NewDCMImageUID(NumSlice, PatInfo);
        end
    end
    
    %Status
    hFig=findobj(0, 'Type', 'figure', 'Name', 'Export ROIs');
    hStatus=StatusProgressTextCenterIFOA('IBEX', 'Exporting DICOM RS file ...', hFig);
    drawnow;
    
    hText=findobj(hStatus, 'Style', 'Text');
    
    %Write
    ReturnFlag=WriteRSDCM(structAxialROI, [ExportPath, '\', FileName], PatInfo, ImgUIDInfo, hText);
    
    delete(hStatus);
    drawnow;
catch
    ReturnFlag=0;
end





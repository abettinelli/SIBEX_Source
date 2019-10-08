function DisplayContourAxial(ROIIndex, PlanIndex, ROIName, ROIColor, ROILineStyle, ModeStr, handles)

%Off contour editing leftover
ResetContourNudge(handles);

%Off ROI
if isequal(ModeStr, 'Off')
    UserData{1}='Contour';
    UserData{2}=deblank([ROIName, num2str(PlanIndex)]);
    
    hLine=findobj(handles.AxesImageAxial, 'Type', 'line', 'UserData', UserData);
    
    if ~isempty(hLine)
        delete(hLine);
    end
    
    return;
end


%On ROI
ImageDataInfo=GetImageDataInfo(handles, 'Axial');

CurrentLoc=str2num(get(handles.TextZLoc, 'String'));

structCurveCor=GetCurveCor(ROIIndex, ROIName, CurrentLoc, handles.PlansInfo.structAxialROI{PlanIndex}, ImageDataInfo.ZPixDim);

 if ~isempty(structCurveCor)
        [RowNum, ColNum]=size(structCurveCor);
        for mm=1:ColNum
            UserData={};
            UserData{1}='Contour'; UserData{2}=deblank([ROIName, num2str(PlanIndex)]);
            
            LineData=structCurveCor(mm).LineData;     

            plot(handles.AxesImageAxial, LineData(:,1), LineData(:,2), ...,
                'Color', ROIColor, 'UserData', UserData, 'LineStyle',  ROILineStyle, 'LineWidth',  1.5);
        end
 end        


function structCurveCor=GetCurveCor(OrganIndex, OrganName, CurrentLoc, structViewROI, PlanZPixDim)
structCurveCor=[];
structNumber=0;

%Get ContourLoc by view type
ContourLoc=structViewROI(OrganIndex).ZLocation;

if ~isempty(ContourLoc)
    ContourIndex=find(abs(ContourLoc-CurrentLoc) < PlanZPixDim/2);

    if ~isempty(ContourIndex)
        %Deal with more than one contour
        for k=1:length(ContourIndex)
            %Get contour data
            TempIndex=ContourIndex(k);
            ContourData=structViewROI(OrganIndex).CurvesCor{TempIndex};
            
            %Store into structCurveCor
            structNumber=structNumber+1;
            structCurveCor(structNumber).OrganName=OrganName;
            structCurveCor(structNumber).LineData=ContourData;
        end
    end
end








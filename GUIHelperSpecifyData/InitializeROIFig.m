function InitializeROIFig(handles, Mode)


switch Mode
    case 0        
        %Specify Data figure
        %Set text on UI
        TextStr='<html><b><center><font size="4" face="Calibri" color="rgb(0,0,0)">Add to<br />Data Set</font></html>';
        set(handles.PushbuttonAddToDataSet, 'String', TextStr);
        
        TextStr='<html><b><center><font size="4" face="Calibri" color="rgb(0,0,0)">Edit<br />ROIs</font></html>';
        set(handles.PushbuttonEditROIMain, 'String', TextStr);
        
        TextStr='<html><b><center><font size="4" face="Calibri" color="rgb(0,0,0)">Off<br />All ROIs</font></html>';
        set(handles.PushbuttonOffAllROIs, 'String', TextStr);
        
        TextStr='<html><b><center><font size="4" face="Calibri" color="rgb(0,0,0)">On<br />All ROIs</font></html>';
        set(handles.PushbuttonOnAllROIs, 'String', TextStr);
                
        TextStr='<html><b><center><font size="4" face="Calibri" color="rgb(0,0,0)">Edit<br />ROIs</font></html>';
        set(handles.PushbuttonEditROI, 'String', TextStr);
        
        TextStr='<html><b><center><font size="4" face="Calibri" color="rgb(0,0,0)">Import<br />ROIs</font></html>';
        set(handles.PushbuttonImportROI, 'String', TextStr);
        
        TextStr='<html><b><center><font size="4" face="Calibri" color="rgb(0,0,0)">Export<br />ROIs</font></html>';
        set(handles.PushbuttonExportROI, 'String', TextStr);
        
        TextStr='<html><b><center><font size="4" face="Calibri" color="rgb(0,0,0)">Delete<br />ROIs</font></html>';
        set(handles.PushbuttonDeleteROI, 'String', TextStr);
        
        TextStr='<html><b><center><font size="4" face="Calibri" color="rgb(0,0,0)">Show<br />Data Set</font></html>';
        set(handles.PushbuttonShowDataSet, 'String', TextStr);
        
        TextStr='<html><b><center><font size="4" face="Calibri" color="rgb(0,0,0)">Show<br />Feature Set</font></html>';
        set(handles.PushbuttonShowFeatureSet, 'String', TextStr);
        
        TextStr='<html><b><center><font size="4" face="Calibri" color="rgb(0,0,0)">Change<br />Pat./Image</font></html>';
        set(handles.PushbuttonOpenIFOAPat, 'String', TextStr);
        
        TextStr='<html><b><center><font size="4" face="Calibri" color="rgb(0,0,0)">Save</font></html>';
        set(handles.PushbuttonSave, 'String', TextStr);
        
        TextStr='<html><b><center><font size="4" face="Calibri" color="rgb(0,0,0)">Export</font></html>';
        set(handles.PushbuttonExport, 'String', TextStr);
        
        TextStr='<html><b><center><font size="4" face="Calibri" color="rgb(0,0,0)">Exit</font></html>';
        set(handles.PushbuttonExit, 'String', TextStr);
        
        TextStr='<html><b><center><font size="4" face="Calibri" color="rgb(0,0,0)">Open<br />CAT Pat.</font></html>';
        set(handles.PushbuttonOpenCATPat, 'String', TextStr);
        
          
    case 1
        %EditROI figure
        [TempIcon, map]=imread('ContourNudge02.jpg');
        TempIcon=cat(3,TempIcon, TempIcon, TempIcon);
        set(handles.TogglebuttonContourNudge, 'CData', TempIcon);
        
        [TempIcon, map]=imread('ContourCut02.jpg');
        TempIcon=cat(3,TempIcon, TempIcon, TempIcon);
        set(handles.TogglebuttonContourCut, 'CData', TempIcon);
        
        [TempIcon, map]=imread('ContourDraw02.jpg');
        TempIcon=cat(3,TempIcon, TempIcon, TempIcon);
        set(handles.TogglebuttonContourDraw, 'CData', TempIcon);
        
        [TempIcon, map]=imread('ContourTrail.jpg');
        set(handles.TogglebuttonContourTrail, 'CData', TempIcon);
        
        [TempIcon, map]=imread('ContourNew02.jpg');
        TempIcon=cat(3,TempIcon, TempIcon, TempIcon);
        set(handles.PushbuttonContourNew, 'CData', TempIcon);
                
        [TempIcon, map]=imread('ContourInterp.jpg');
        set(handles.PushbuttonInterpolate, 'CData', TempIcon);
              
        [TempIcon, map]=imread('ContourCopy.jpg');
        TempIcon=cat(3,TempIcon, TempIcon, TempIcon);
        set(handles.PushbuttonContourCopy, 'CData', TempIcon);
        
        [TempIcon, map]=imread('ContourDelete.jpg');
        set(handles.PushbuttonDelete, 'CData', TempIcon);
        
        [SaveIcon, map]=imread('Save.jpg');
        set(handles.PushbuttonSave, 'CData', SaveIcon);
        
        [ExitBigIcon, map]=imread('ExitBig2.jpg');
        set(handles.PushbuttonExit, 'Cdata', ExitBigIcon);
        
        if isfield(handles, 'TogglebuttonAutoSegBound')
            [TempIcon, map]=imread('BoxSmall.jpg');
            set(handles.TogglebuttonAutoSegBound, 'Cdata', TempIcon);
        end
                
        if isfield(handles, 'PushbuttonUpdate')
            [SaveIcon, map]=imread('Update.jpg');
            set(handles.PushbuttonUpdate, 'CData', SaveIcon);
        end
        
         TextStr='<html><b><center><font size="4" face="Calibri" color="rgb(0,0,0)">Off<br />All ROIs</font></html>';
        set(handles.PushbuttonOffAllROIs, 'String', TextStr);               
                       
        set(handles.RadiobuttonROIModePoly, 'Enable', 'Off');
        set(handles.RadiobuttonROIModeContour, 'Enable', 'Off');       
        
end

set(handles.AxesImageAxialBack,'XTick', [], 'YTick', []);
set(handles.AxesImageCorBack,'XTick', [], 'YTick', []);
set(handles.AxesImageSagBack,'XTick', [], 'YTick', []);
    
set(handles.TextStatus, 'String', '', 'Visible', 'off');

%Button Pictures for image view
[ImageData, map]=imread('Zoom.jpg');
set(handles.TogglebuttonZoom, 'CData', ImageData);

[ImageData, map]=imread('Ruler.jpg');
set(handles.TogglebuttonRuler, 'CData', ImageData);

[ImageData, map]=imread('CTValue.jpg');
set(handles.TogglebuttonCTNum, 'Cdata', ImageData);

[ImageData, map]=imread('WL.jpg');
set(handles.PushbuttonWL, 'Cdata', ImageData);

[ImageData, map]=imread('Intersection3.jpg');
set(handles.TogglebuttonCross, 'CData', ImageData);

%Set W/L 
ConfigFile=[handles.ProgramPath, '\IFOA.INI'];
UserWL=GetUserWL(ConfigFile);

handles.WLRegionName=[{'Abdomen'}; {'Bone'}; {'Breast'};  {'Head'}; {'Lung'}; {'Pelvis'}; {'BAT'}; {'DIR'}; {'PETSUV'}];
handles.WLRegionMat=[400, 800, 1200; ...   %Abdomen
        1400, 700, 2100; ...    %Bone
        400, 750, 1150; ...      %Breast
        180, 950, 1130; ...      %Head
        1600, -300, 1300; ...   %Lung
        500, 750, 1250; ...      %Pelvis
        300, 925, 1225; ...      %BAT
        1400, 0, 1400; ...      %DIR
        10,0,10;...       %PETSUV
];

if ~isempty(UserWL)
    handles.WLRegionName=[handles.WLRegionName; UserWL.Name];
    
    WLData=[UserWL.Data, sum(UserWL.Data, 2)];
    handles.WLRegionMat=[handles.WLRegionMat; WLData];
end

set(handles.PopupmenuWL, 'String', handles.WLRegionName, 'Value', 1);

set(handles.UIButtonGroupPanel, 'SelectedObject', handles.RadiobuttonROIModePoly);      

%Colormap Popupmenu
ColorMapString=[{'Gray'}; {'Hot'}; {'HSV'}; {'Jet'}; {'Cool'}; {'Spring'}; {'Summer'}; {'Autumn'};  {'Winter'}];
set(handles.PopupmenuColorMap, 'String', ColorMapString);

%KeyPressFcn
AllUIHandle=[];
HandleT=findobj(handles.figure1, 'Style', 'pushbutton');
AllUIHandle=[AllUIHandle; HandleT];

HandleT=findobj(handles.figure1, 'Style', 'togglebutton');
AllUIHandle=[AllUIHandle; HandleT];
HandleT=findobj(handles.figure1, 'Style', 'radiobutton');
AllUIHandle=[AllUIHandle; HandleT];
HandleT=findobj(handles.figure1, 'Style', 'checkbox');
AllUIHandle=[AllUIHandle; HandleT];
HandleT=findobj(handles.figure1, 'Style', 'edit');
AllUIHandle=[AllUIHandle; HandleT];
HandleT=findobj(handles.figure1, 'Style', 'text');
AllUIHandle=[AllUIHandle; HandleT];
HandleT=findobj(handles.figure1, 'Style', 'slider');
AllUIHandle=[AllUIHandle; HandleT];
HandleT=findobj(handles.figure1, 'Style', 'frame');
AllUIHandle=[AllUIHandle; HandleT];
HandleT=findobj(handles.figure1, 'Style', 'popupmenu');
AllUIHandle=[AllUIHandle; HandleT];

set(AllUIHandle, 'KeyPressFcn', @KeyPressFcn_Callback);

guidata(handles.figure1, handles);


function FUserWL=GetUserWL(ConfigFile)
if ~exist(ConfigFile, 'file')
    FUserWL=[];
    return;
end

FID=fopen(ConfigFile, 'r');
TempContent=textscan(FID, '%s', 'delimiter', '\n');
fclose(FID);

cellFileInfo=TempContent{1};
clear('TempContent');

for i=1:length(cellFileInfo)
    eval(cellFileInfo{i});
end

if exist('UserWL', 'var')
    FUserWL.Name=UserWL(:, 1);
    FUserWL.Data=cell2mat(UserWL(:, 2:3));
else
    FUserWL=[];
    return;
end   
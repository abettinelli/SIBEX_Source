function InitializeROIFig(handles, Mode)


switch Mode
    case 0        
        %Specify Data figure
        %Set text on UI
        TextStr='<html><b><center><font size="4" face="Calibri" color="rgb(0,0,0)">Add to<br />Data Set</font></html>';
        set(handles.PushbuttonAddToDataSet, 'String', TextStr);
        
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
        
        TextStr='<html><b><center><font size="4" face="Calibri" color="rgb(0,0,0)">Save</font></html>';
        set(handles.PushbuttonSave, 'String', TextStr);
        
        TextStr='<html><b><center><font size="4" face="Calibri" color="rgb(0,0,0)">Exit</font></html>';
        set(handles.PushbuttonExit, 'String', TextStr);
        
          
    case 1
        %EditROI figure
        [TempIcon, map]=imread('ContourNudge02.png');
        TempIcon=cat(3,TempIcon, TempIcon, TempIcon);
        set(handles.TogglebuttonContourNudge, 'CData', TempIcon);
        
        [TempIcon, map]=imread('ContourCut02.png');
        TempIcon=cat(3,TempIcon, TempIcon, TempIcon);
        set(handles.TogglebuttonContourCut, 'CData', TempIcon);
        
        [TempIcon, map]=imread('ContourDraw02.png');
        TempIcon=cat(3,TempIcon, TempIcon, TempIcon);
        set(handles.TogglebuttonContourDraw, 'CData', TempIcon);
        
        [TempIcon, map]=imread('ContourTrail.png');
        set(handles.TogglebuttonContourTrail, 'CData', TempIcon);
        
        [TempIcon, map]=imread('ContourNew02.png');
        TempIcon=cat(3,TempIcon, TempIcon, TempIcon);
        set(handles.PushbuttonContourNew, 'CData', TempIcon);
                
        [TempIcon, map]=imread('ContourInterp.png');
        set(handles.PushbuttonInterpolate, 'CData', TempIcon);
              
        [TempIcon, map]=imread('ContourCopy.png');
        TempIcon=cat(3,TempIcon, TempIcon, TempIcon);
        set(handles.PushbuttonContourCopy, 'CData', TempIcon);
        
        [TempIcon, map]=imread('ContourDelete.png');
        set(handles.PushbuttonDelete, 'CData', TempIcon);
        
        [SaveIcon, map]=imread('Save.png');
        set(handles.PushbuttonSave, 'CData', SaveIcon);
        
        [ExitBigIcon, map]=imread('ExitBig2.png');
        set(handles.PushbuttonExit, 'Cdata', ExitBigIcon);
        
        if isfield(handles, 'TogglebuttonAutoSegBound')
            [TempIcon, map]=imread('BoxSmall.png');
            set(handles.TogglebuttonAutoSegBound, 'Cdata', TempIcon);
        end
                
        if isfield(handles, 'PushbuttonUpdate')
            [SaveIcon, map]=imread('Update.png');
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
configureButton(handles.TogglebuttonZoom,[handles.ProgramPath '\Pic\Zoom.png'],'')
configureButton(handles.TogglebuttonRuler,[handles.ProgramPath '\Pic\Ruler.png'],'')
configureButton(handles.TogglebuttonCTNum,[handles.ProgramPath '\Pic\CTValue.png'],'')
configureButton(handles.PushbuttonWL,[handles.ProgramPath '\Pic\WL.png'],'')
configureButton(handles.TogglebuttonCross,[handles.ProgramPath '\Pic\Intersection3.png'],'')

%Set W/L 
ConfigFile=[handles.ProgramPath, '\IFOA.INI'];
UserWL=GetUserWL(ConfigFile);
handles.WLRegionName=[{'Abdomen'}; {'Bone'}; {'Breast'};  {'Head'}; {'Lung'}; {'Pelvis'}; {'BAT'}; {'DIR'}; {'PETSUV'}];
handles.WLRegionMat=[400, 800, 1200; ...	%Abdomen
                    1400, 700, 2100; ...	%Bone
                    400, 750, 1150; ...     %Breast
                    180, 950, 1130; ...     %Head
                    1600, -300, 1300; ...	%Lung
                    500, 750, 1250; ...     %Pelvis
                    300, 925, 1225; ...     %BAT
                    1400, 0, 1400; ...      %DIR
                    10,0,10];               %PETSUV

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

function configureButton(p, CIcon_p, txt)

pxPos = getpixelposition(p);
% str = ['<html><div width="' num2str(pxPos(3)+50) 'px"; height="50px" align="left">&nbsp;&nbsp;<img src = "file:/', CIcon_p, '" style="vertical-align: middle;">&nbsp;&nbsp;' txt ''];
str = ['<html><img align="middle" src="file:/', CIcon_p, '">'];
set(p,'String', str, 'FontSize', 20);
function InitializeContourVars(handles)

%Display nudge size
% handles.ContourNudgeSize=8;
handles.ContourNudgeSize=round(100*handles.ImageDataAxialInfo.XPixDim*10)/10;  %Unit in mm

set(handles.EditDiameter, 'String', num2str(handles.ContourNudgeSize));

%Contour Edit Tool Flag
handles.ContourToolNudge=0;
handles.ContourToolCut=0;
handles.ContourToolDraw=0;
handles.ContourToolTrail=0;

handles.ContourEditFlag=0;     %Set when button is down; Reset when button is up
handles.ContourModifyFlag=0; %Set when bitmap is changed; Reset when editing is finished.
handles.ContourNudgeInside=[];
handles.ContourNum=1;


%Contour Cursor Shape
ContourCursor=imread('ContourPointer.bmp');
ContourCursor=double(ContourCursor);
ContourCursor(find(ContourCursor==2))=NaN;
ContourCursor(find(ContourCursor==1))=2;
ContourCursor(find(ContourCursor==0))=1;

handles.ContourCursor=ContourCursor;

handles.ContourNoArea=15;

%Intialize Nudge Line
Temp=handles.ContourNudgeSize/20;
FirstHalfX=-handles.ContourNudgeSize/20:0.005:-handles.ContourNudgeSize/40;
SecondHalfX=-handles.ContourNudgeSize/40:0.005:handles.ContourNudgeSize/40;
ThirdHalfX=handles.ContourNudgeSize/40:0.005:handles.ContourNudgeSize/20;

handles.NudgeHalfX=[FirstHalfX, SecondHalfX,ThirdHalfX]; 
handles.NudgeHalfY=sqrt(Temp*Temp-handles.NudgeHalfX.*handles.NudgeHalfX);

%Default Color
handles.PinnColorList={'red'; 'green'; 'blue'; 'purple'; 'cyan'};

guidata(handles.figure1, handles);






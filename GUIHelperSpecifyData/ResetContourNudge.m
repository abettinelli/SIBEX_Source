function ResetContourNudge(handles)
%Delete contour Cursor
TempH=findobj(handles.figure1, 'UserData', 'ContourNudge');
delete(TempH);

%Update handles
handles.ContourFirstPoint=[];
handles.ContourPrevPoint=[];
handles.ContourNextPoint=[];
handles.ContourPoint=0;

guidata(handles.figure1, handles);

function DisplayImageInit(handles)

%%%%%%%%%%%%%%%%%%%
% Display---Axial %
%%%%%%%%%%%%%%%%%%%

axes(handles.AxesImageAxial)

set(gca, 'CLim', [handles.GrayMin, handles.GrayMax]);

ImageDataInfo=GetImageDataInfo(handles, 'Axial');

if ~isfield(handles, 'SliceNum')
    CenterCut=round(size(ImageDataInfo.ImageData, 3)/2);
    handles.SliceNum=CenterCut;
end

AxesMargin_X=0;
AxesMargin_Y=0;
deltaX = ImageDataInfo.XLimMax - ImageDataInfo.XLimMin;
deltaY = ImageDataInfo.YLimMax - ImageDataInfo.YLimMin;
if deltaX > deltaY
    AxesMargin_Y = (deltaX-deltaY)/2;
else
    AxesMargin_X = (deltaY-deltaX)/2;
end

set(gca, 'XLimMode', 'manual', 'XLim', [ImageDataInfo.XLimMin-AxesMargin_X, ImageDataInfo.XLimMax+AxesMargin_X]);
set(gca, 'YLimMode', 'manual', 'YLim', [ImageDataInfo.YLimMin-AxesMargin_Y, ImageDataInfo.YLimMax+AxesMargin_Y]);
set(gca, 'DataAspectRatioMode', 'auto', 'PlotBoxAspectRatioMode', 'auto', 'CameraViewAngleMode', 'auto');
set(gca, 'Color', 'none');
set(gca, 'XDir', 'normal'), set(gca, 'YDir', 'normal');

set(gca, 'Box', 'on', 'XTickMode', 'auto', 'YTickMode', 'auto');

hold on,
image([ImageDataInfo.XLimMin, ImageDataInfo.XLimMax], [ImageDataInfo.YLimMin, ImageDataInfo.YLimMax],...
    ImageDataInfo.ImageData(:, :, handles.SliceNum), 'CDataMapping', 'scaled'),
caxis([handles.GrayMin, handles.GrayMax]);

axis equal

set(handles.TextZLoc, 'String', sprintf('%.3f', ImageDataInfo.TablePos(handles.SliceNum)));

guidata(handles.figure1, handles);

set(handles.AxesImageAxial, 'CLim', [handles.GrayMin, handles.GrayMax]);

set(gca,'color','k');

%%%%%%%%%%%%%%%%%%%%%
% Display---Coronal %
%%%%%%%%%%%%%%%%%%%%%

axes(handles.AxesImageCor)

set(gca, 'CLim', [handles.GrayMin, handles.GrayMax]);

ImageDataInfo=GetImageDataInfo(handles, 'Cor');

AxesMargin_X=0;
AxesMargin_Z=0;
deltaX = ImageDataInfo.XLimMax - ImageDataInfo.XLimMin;
deltaZ = ImageDataInfo.ZLimMax - ImageDataInfo.ZLimMin;
if deltaX > deltaZ
    AxesMargin_Z = (deltaX-deltaZ)/2;
else
    AxesMargin_X = (deltaZ-deltaX)/2;
end

set(gca, 'XLimMode', 'manual', 'XLim', [ImageDataInfo.XLimMin-AxesMargin_X, ImageDataInfo.XLimMax+AxesMargin_X]);
set(gca, 'YLimMode', 'manual', 'YLim', [ImageDataInfo.ZLimMin-AxesMargin_Z, ImageDataInfo.ZLimMax+AxesMargin_Z]);
set(gca, 'DataAspectRatioMode', 'auto', 'PlotBoxAspectRatioMode', 'auto', 'CameraViewAngleMode', 'auto');
set(gca, 'Color', 'none');
set(gca, 'XDir', 'normal'), set(gca, 'YDir', 'reverse');

set(gca, 'Box', 'on', 'XTickMode', 'auto', 'YTickMode', 'auto');
set(gca,'ytick', [], 'yticklabel', [])

if ~isfield(handles, 'SliceNumCor')
    CenterCutCor=round(ImageDataInfo.YDim/2);
    handles.SliceNumCor=CenterCutCor;
end

hold on,
CorImage=(squeeze(ImageDataInfo.ImageData(handles.SliceNumCor, :, :)))';

image([ImageDataInfo.XLimMin, ImageDataInfo.XLimMax], [ImageDataInfo.ZLimMin, ImageDataInfo.ZLimMax], CorImage,  'CDataMapping', 'scaled'),
caxis([handles.GrayMin, handles.GrayMax]);

axis equal

YLoc=(handles.SliceNumCor-1)*ImageDataInfo.YPixDim+ImageDataInfo.YLimMin;
set(handles.TextYLoc, 'String', sprintf('%.3f', YLoc));

set(gca,'color','k');

%%%%%%%%%%%%%%%%%%%%%%
% Display---Sagittal %
%%%%%%%%%%%%%%%%%%%%%%

axes(handles.AxesImageSag)

set(gca, 'CLim', [handles.GrayMin, handles.GrayMax]);

ImageDataInfo=GetImageDataInfo(handles, 'Sag');

AxesMargin_Y=0;
AxesMargin_Z=0;
deltaY = ImageDataInfo.YLimMax - ImageDataInfo.YLimMin;
deltaZ = ImageDataInfo.ZLimMax - ImageDataInfo.ZLimMin;
if deltaZ > deltaY
    AxesMargin_Y = (deltaZ-deltaY)/2;
else
    AxesMargin_Z = (deltaY-deltaZ)/2;
end

set(gca, 'XLimMode', 'manual', 'XLim', [ImageDataInfo.YLimMin-AxesMargin_Y, ImageDataInfo.YLimMax+AxesMargin_Y]);
set(gca, 'YLimMode', 'manual', 'YLim', [ImageDataInfo.ZLimMin-AxesMargin_Z, ImageDataInfo.ZLimMax+AxesMargin_Z]);
set(gca, 'DataAspectRatioMode', 'auto', 'PlotBoxAspectRatioMode', 'auto', 'CameraViewAngleMode', 'auto');
set(gca, 'Color', 'none');
set(gca, 'XDir', 'reverse'), set(gca, 'YDir', 'reverse');

set(gca, 'Box', 'on', 'XTickMode', 'auto', 'YTickMode', 'auto');
%set(gca,'xtick', [], 'xticklabel', [],'ytick', [], 'yticklabel', [])

if ~isfield(handles, 'SliceNumSag')
    CenterCutSag=round(ImageDataInfo.XDim/2);
    handles.SliceNumSag=CenterCutSag;
end

hold on,
SagImage=(squeeze(ImageDataInfo.ImageData(:, handles.SliceNumSag, :)))';

image([ImageDataInfo.YLimMin, ImageDataInfo.YLimMax], [ImageDataInfo.ZLimMin, ImageDataInfo.ZLimMax], SagImage, 'CDataMapping', 'scaled'),
caxis([handles.GrayMin, handles.GrayMax]);

axis equal

XLoc=(handles.SliceNumSag-1)*ImageDataInfo.XPixDim+ImageDataInfo.XLimMin;
set(handles.TextXLoc, 'String', sprintf('%.3f', XLoc));

set([handles.AxesImageAxial, handles.AxesImageSag, handles.AxesImageCor], 'CLim', [handles.GrayMin, handles.GrayMax]);
set(gca,'color','k');
set(gca,'YAxisLocation','right');

guidata(handles.figure1, handles);
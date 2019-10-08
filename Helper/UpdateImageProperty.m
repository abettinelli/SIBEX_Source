function ImageInfo=UpdateImageProperty(DataFormat)

if ~isempty(DataFormat.XStartV9)
    ImageInfo.XStart=DataFormat.XStartV9;
    ImageInfo.StartV9=1;
else
    ImageInfo.XStart=DataFormat.XStartV8;
    ImageInfo.StartV9=0;
end

if ~isempty(DataFormat.YStartV9)
    ImageInfo.YStart=DataFormat.YStartV9;
    ImageInfo.StartV9=1;
else
    ImageInfo.YStart=DataFormat.YStartV8;
    ImageInfo.StartV9=0;
end


ImageInfo.XStartV9=DataFormat.XStartV9;
ImageInfo.YStartV9=DataFormat.YStartV9;

ImageInfo.XStartV8=DataFormat.XStartV8;
ImageInfo.YStartV8=DataFormat.YStartV8;

ImageInfo.XDim=DataFormat.XDim;
ImageInfo.YDim=DataFormat.YDim;
ImageInfo.ZDim=DataFormat.ZDim;

ImageInfo.ZStart=DataFormat.ZStart;

ImageInfo.XPixDim=DataFormat.XPixDim;
ImageInfo.YPixDim=DataFormat.YPixDim;

ImageInfo.TablePos=DataFormat.TablePos;
if length(ImageInfo.TablePos) > 1
    ImageInfo.ZPixDim=abs(ImageInfo.TablePos(1)-ImageInfo.TablePos(2));
else
    ImageInfo.ZPixDim=DataFormat.ZPixDim;
end

XLimMin=ImageInfo.XStart;
XLimMax=(ImageInfo.XDim-1)*ImageInfo.XPixDim+ XLimMin;

ImageInfo.XLimMin=XLimMin;
ImageInfo.XLimMax=XLimMax;

YLimMin=ImageInfo.YStart;
YLimMax=(ImageInfo.YDim-1)*ImageInfo.YPixDim+YLimMin;

ImageInfo.YLimMin=YLimMin;
ImageInfo.YLimMax=YLimMax;

if length(ImageInfo.TablePos) > 1
    ImageInfo.ZLimMin=ImageInfo.TablePos(1);
    ImageInfo.ZLimMax=ImageInfo.TablePos(end);
else
    ImageInfo.ZLimMin=ImageInfo.TablePos(1);
    ImageInfo.ZLimMax=ImageInfo.TablePos(1)+ImageInfo.ZPixDim;
end

%ImageInfo.ScaleValue=DataFormat.ColorLUTScale*DataFormat.SUVScale;
ImageInfo.ScaleValue=1;

function [DXStart, DYStart]=GetDiffStartPoint(PinnV9, ImageInfo)
if abs(PinnV9-ImageInfo.StartV9) < 1||  PinnV9 > 1
    DXStart=0;
    DYStart=0;
else
    if PinnV9 > 0
        if ~isempty(ImageInfo.XStartV9)
            DXStart=ImageInfo.XStartV9-ImageInfo.XStartV8;
            DYStart=ImageInfo.YStartV9-ImageInfo.YStartV8;
        else
            DXStart=0;
            DYStart=ImageInfo.YPixDim*ImageInfo.YDim;
        end
    end
    
    if PinnV9  < 1
        DXStart=ImageInfo.XStartV8-ImageInfo.XStartV9;
        DYStart=ImageInfo.YStartV8-ImageInfo.YStartV9;
    end
end
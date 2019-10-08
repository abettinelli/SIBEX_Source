function BWMatInfo=ExtendBWMatDim(BWMatInfo, BWMatInfoSlice, Mode)

XStart=min(BWMatInfo.XStart, BWMatInfoSlice.XStart);
YStart=min(BWMatInfo.YStart, BWMatInfoSlice.YStart);
ZStart=min(BWMatInfo.ZStart, BWMatInfoSlice.ZStart);

XEnd=max(BWMatInfo.XStart+(BWMatInfo.XDim-1)*BWMatInfo.XPixDim, ...
    BWMatInfoSlice.XStart+(BWMatInfoSlice.XDim-1)*BWMatInfoSlice.XPixDim);

YEnd=max(BWMatInfo.YStart+(BWMatInfo.YDim-1)*BWMatInfo.YPixDim, ...
    BWMatInfoSlice.YStart+(BWMatInfoSlice.YDim-1)*BWMatInfoSlice.YPixDim);

ZEnd=max(BWMatInfo.ZStart+(BWMatInfo.ZDim-1)*BWMatInfo.ZPixDim, ...
    BWMatInfoSlice.ZStart+(BWMatInfoSlice.ZDim-1)*BWMatInfoSlice.ZPixDim);

XDim=round((XEnd-XStart)/BWMatInfo.XPixDim+1);
YDim=round((YEnd-YStart)/BWMatInfo.YPixDim+1);
ZDim=round((ZEnd-ZStart)/BWMatInfo.ZPixDim+1);

MaskData=zeros(YDim, XDim, ZDim, 'uint8');

for i=1:2
    switch i
        case 1
            CBWMatInfo=BWMatInfo;
        case 2
            CBWMatInfo=BWMatInfoSlice;
    end
    
    CYEnd=CBWMatInfo.YStart+(CBWMatInfo.YDim-1)*CBWMatInfo.YPixDim;
    RowStart=round(YDim-(CYEnd-YStart)/BWMatInfo.YPixDim);
    RowEnd=round(YDim-(CBWMatInfo.YStart-YStart)/BWMatInfo.YPixDim);
    
    CXEnd=CBWMatInfo.XStart+(CBWMatInfo.XDim-1)*CBWMatInfo.XPixDim;
    ColEnd=round((CXEnd-XStart)/BWMatInfo.XPixDim+1);
    ColStart=round((CBWMatInfo.XStart-XStart)/BWMatInfo.XPixDim+1);
    
    CZEnd=CBWMatInfo.ZStart+(CBWMatInfo.ZDim-1)*CBWMatInfo.ZPixDim;
    PageEnd=round((CZEnd-ZStart)/BWMatInfo.ZPixDim+1);
    PageStart=round((CBWMatInfo.ZStart-ZStart)/BWMatInfo.ZPixDim+1);
    
    %Order is import: first-orginal, then new slice
    if ~isempty(CBWMatInfo.MaskData)
        switch nargin
            case 2 %Replace by second mask
                MaskData(:, :, PageStart:PageEnd)=uint8(0);
                MaskData(RowStart:RowEnd, ColStart:ColEnd, PageStart:PageEnd)=CBWMatInfo.MaskData;
            case 3 
                if isequal(Mode, 'And')
                    MaskData(RowStart:RowEnd, ColStart:ColEnd, PageStart:PageEnd)=...
                        MaskData(RowStart:RowEnd, ColStart:ColEnd, PageStart:PageEnd)+CBWMatInfo.MaskData;
                end
                if isequal(Mode, 'Xor')
                    MaskData(RowStart:RowEnd, ColStart:ColEnd, PageStart:PageEnd)=...
                        xor(MaskData(RowStart:RowEnd, ColStart:ColEnd, PageStart:PageEnd), CBWMatInfo.MaskData);
                end                
        end
    end
end
    
BWMatInfo.XStart=XStart;
BWMatInfo.YStart=YStart;
BWMatInfo.ZStart=ZStart;

BWMatInfo.XDim=XDim;
BWMatInfo.YDim=YDim;
BWMatInfo.ZDim=ZDim;

BWMatInfo.MaskData=MaskData;
    
    
    
    
    
    
    
    

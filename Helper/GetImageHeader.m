function [Flag,  DataFormat]=GetImageHeader(HeaderFile)

Flag=1;
DataFormat=[];

try
    HeaderInfo=ReadPinnTextFile(HeaderFile);
catch
    Flag=0;
    disp('no header file.')
    return;
end

TempIndex=strmatch('x_dim', HeaderInfo);
if ~isempty(TempIndex)
    TempStr=HeaderInfo{TempIndex(1)};    
    eval(TempStr);
    
    XDim=x_dim;
else
    Flag=0;
    disp('no x_dim in the header file.')
    return;
end

TempIndex=strmatch('y_dim', HeaderInfo);
if ~isempty(TempIndex)
    TempStr=HeaderInfo{TempIndex(1)};    
    eval(TempStr);
    
    YDim=y_dim;
else
    Flag=0;
    disp('no y_dim in the header file.')
    return;
end

TempIndex=strmatch('z_dim', HeaderInfo);
if ~isempty(TempIndex)
    TempStr=HeaderInfo{TempIndex(1)};    
    eval(TempStr);
    
    ZDim=z_dim;
else
    Flag=0;
    disp('no z_dim in the header file.')
    return;
end

TempIndex=strmatch('x_pixdim', HeaderInfo);
if ~isempty(TempIndex)
    TempStr=HeaderInfo{TempIndex(1)};    
    eval(TempStr);
    
    XPixDim=x_pixdim;
else
    Flag=0;
    disp('no x_pixdim in the header file.')
    return;
end

TempIndex=strmatch('y_pixdim', HeaderInfo);
if ~isempty(TempIndex)
    TempStr=HeaderInfo{TempIndex(1)};    
    eval(TempStr);
    
    YPixDim=y_pixdim;
else
    Flag=0;
    disp('no y_pixdim in the header file.')
    return;
end

TempIndex=strmatch('z_pixdim', HeaderInfo);
if ~isempty(TempIndex)
    TempStr=HeaderInfo{TempIndex(1)};    
    eval(TempStr);
    
    ZPixDim=z_pixdim;
else
    Flag=0;
    disp('no z_pixdim in the header file.')
    return;
end

TempIndex=strmatch('z_start', HeaderInfo);
if ~isempty(TempIndex)
    TempStr=HeaderInfo{TempIndex(1)};    
    eval(TempStr);
    
    ZStart=z_start;
else
    Flag=0;
    disp('no z_start in the header file.')
    return;
end


TempIndex=strmatch('x_start_dicom', HeaderInfo);
if ~isempty(TempIndex)
    TempStr=HeaderInfo{TempIndex(1)};    
    eval(TempStr);
    
    XStartV9=x_start_dicom;
else
    XStartV9=[];
end

TempIndex=strmatch('x_start', HeaderInfo);
if ~isempty(TempIndex)
    TempStr=HeaderInfo{TempIndex(1)};
    eval(TempStr);
    
    XStartV8=x_start;
else
    Flag=0;
    disp('no x_start in the header file.')
    return;
end

TempIndex=strmatch('byte_order', HeaderInfo);
if ~isempty(TempIndex)
    TempStr=HeaderInfo{TempIndex(1)};
    eval(TempStr);
    
    ByteOrder=byte_order;
else
    Flag=0;
    disp('no byte_order in the header file.')
    return;
end

TempIndex=strmatch('y_start_dicom', HeaderInfo);
if ~isempty(TempIndex)
    TempStr=HeaderInfo{TempIndex(1)};    
    eval(TempStr);
    
    YStartV9=y_start_dicom;
else
    YStartV9=[];
end

TempIndex=strmatch('y_start', HeaderInfo);
if ~isempty(TempIndex)
    TempStr=HeaderInfo{TempIndex(1)};
    eval(TempStr);
    
    YStartV8=y_start;
else
    Flag=0;
    disp('no y_start in the header file.')
    return;
end

InfoFile=[HeaderFile(1:end-6), 'ImageInfo'];
if ~exist(InfoFile, 'file')
    ColorLUTScale=1;
    SUVScale=1;
    
    TempV=(1:ZDim)';
    TablePos=z_start+(TempV-1)*ZPixDim;
    
%     Flag=0;
%     disp('no ImageInfo file.')
%     return;
else
    [ColorLUTScale, SUVScale, TablePos]=GetImageScale(InfoFile);    
end



if ~isempty(XStartV9)
    if abs(XStartV9) < 0.000001 &&  abs(YStartV9) < 0.000001
        TempIndex=strmatch('Version', HeaderInfo);
        
        if ~isempty(TempIndex)
            TempStr=HeaderInfo{TempIndex(1)};
            TempStr=strtrim(TempStr);
            if length(TempStr < 9)
                XStartV9=[];
                YStartV9=[];
            end
        end
    end
end

DataFormat.Modality='CT';
TempIndex=strmatch('modality', HeaderInfo);
if ~isempty(TempIndex)
    TempStr=HeaderInfo{TempIndex(1)};
    
    TempIndex=strfind(TempStr, ':');
    if ~isempty(TempIndex)
        DataFormat.Modality=strtrim(TempStr(TempIndex(1)+1:end));        
    end
end

DataFormat.XDim=XDim;
DataFormat.YDim=YDim;
DataFormat.ZDim=ZDim;
DataFormat.XPixDim=XPixDim;
DataFormat.YPixDim=YPixDim;
DataFormat.ZPixDim=ZPixDim;
DataFormat.XStartV9=XStartV9;
DataFormat.XStartV8=XStartV8;
DataFormat.YStartV9=YStartV9;
DataFormat.YStartV8=YStartV8;
DataFormat.ZStart=ZStart;
DataFormat.ColorLUTScale=ColorLUTScale;
DataFormat.SUVScale=SUVScale;
DataFormat.TablePos=TablePos;
DataFormat.ByteOrder=ByteOrder;

function [ColorLUTScale, SUVScale, TablePos]=GetImageScale(InfoFile)
ColorLUTScale=1;
SUVScale=1;

TextInfo=ReadPinnTextFileOri(InfoFile);

TempIndex=strmatch('ColorLUTScale', TextInfo);
if ~isempty(TempIndex)
    TempStr=TextInfo{TempIndex(1)};
    eval(TempStr);    
end

TempIndex=strmatch('SUVScale', TextInfo);
if ~isempty(TempIndex)
    TempStr=TextInfo{TempIndex(1)};
    eval(TempStr);    
end

TableIndex=strmatch('TablePosition', TextInfo);

TablePos=[];
for i=1:length(TableIndex)
    eval(char(TextInfo{TableIndex(i)}));
    TablePos=[TablePos; TablePosition];
end


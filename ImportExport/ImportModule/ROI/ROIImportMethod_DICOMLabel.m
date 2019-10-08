function structAxialROI=ROIImportMethod_DICOMLabel(FileName, ImageDataInfo)

%Import
try
    %Folder Path
    DirPath=fileparts(FileName);
    
    LabelDICOMInfo=dicominfo(FileName);
    
    %Sanity Check 1
    if ~isfield(LabelDICOMInfo, 'Width') || ~isfield(LabelDICOMInfo, 'Height') || ~isfield(LabelDICOMInfo, 'SeriesInstanceUID')
        structAxialROI=[];
        return;
    end
    
    XDim=LabelDICOMInfo.Width;
    YDim=LabelDICOMInfo.Height;
    SeriesUID=LabelDICOMInfo.SeriesInstanceUID;
    
    FileList=GetFileList(DirPath);
    
    TLabelInfo={''};
    for i=1:length(FileList)
        FileName=[DirPath, '\', FileList{i}];
        try
            TempInfo=dicominfo(FileName);
            
            TSeriesUID=TempInfo.SeriesInstanceUID;
            if isequal(SeriesUID, TSeriesUID)
                TLabelInfo=[TLabelInfo; {TempInfo}];
            end
        catch
            
        end
    end
    TLabelInfo(1)=[];
    
    ZDim=length(TLabelInfo);
    
    %Sanity Check 2
    if (YDim ~= ImageDataInfo.YDim) || (XDim~= ImageDataInfo.XDim) || (ZDim ~= ImageDataInfo.ZDim)
        structAxialROI=[];
        return;
    end
    
    AxialImage=[]; DailyTablePos=[];
    for i=1:ZDim
        %Show Status
        TempInfo=TLabelInfo{i};
        if isfield(TempInfo, 'RescaleSlope')
            RescaleSlope=TempInfo.RescaleSlope;
        else
            RescaleSlope=1;
        end
        
        if isfield(TempInfo, 'RescaleIntercept')
            RescaleIntercept=TempInfo.RescaleIntercept;
        else
            RescaleIntercept=0;
        end
        
        if ~isfield(TempInfo, 'SliceLocation')
            DailyTablePos=[DailyTablePos; TempInfo.ImagePositionPatient(3)];
        else
            DailyTablePos=[DailyTablePos; TempInfo.SliceLocation];
        end
        
        %image data
        TempImageData=dicomread(TempInfo);
        TempImageData=uint16(double(TempImageData)*RescaleSlope+RescaleIntercept);
        
        AxialImage=cat(3, AxialImage, TempImageData);
    end  
    clear('TempImageData');
    
    [DailyTablePos, SortIndex]=sort(DailyTablePos, 'descend');
    AxialImage=AxialImage(:, :, SortIndex);
    
    %Sanity Check 3
    MinV=min(AxialImage(:));
    MaxV=max(AxialImage(:));
    
    TempIndex=find((AxialImage > MinV) & (AxialImage < MaxV));
    if ~isempty(TempIndex)
        
        structAxialROI=[];
        
        %Avzio
        if TempInfo.BitDepth == 8
            ROINum=0; ColorEnum={'red'; 'green'; 'blue'; 'yellow'; 'purple'; 'skyblue'; 'lavender'; 'orange'};
            for i=1:8
                TAxialImage=uint8(bitget(AxialImage, i));
                
                if max(TAxialImage(:)) > 0
                    ROINum=ROINum+1;
                    ROIName=['ROIDCM', num2str(ROINum)];
                    TstructAxialROI=GenerateStructAxialROI(TAxialImage, ImageDataInfo, ROIName, ColorEnum{i});
                    
                    structAxialROI=[structAxialROI, TstructAxialROI];
                end
            end            
        end  
       
    else
        AxialImage=uint8(logical(AxialImage));
        
        %Import ROI
        structAxialROI=GenerateStructAxialROI(AxialImage, ImageDataInfo);
    end
catch
    structAxialROI=[];
end


function   structAxialROI=GenerateStructAxialROI(MaskMat, ImageDataInfo, ROIName, ROIColor)

TempIndex=find(MaskMat);
[RowIndex, ColIndex, PageIndex]=ind2sub(size(MaskMat), TempIndex);

MinPage=min(PageIndex);
MaxPage=max(PageIndex);

ZLocation=[]; CurvesCor={[]};
for i=MinPage:MaxPage
    BWSlice=MaskMat(:, :, i);
    BWSlice=flipud(BWSlice);
    
    CurveContour = bwboundaries(BWSlice);
    
    if ~isempty(CurveContour)        
        
        for kk=1:length(CurveContour)
            SubSliceContour=CurveContour{kk};
            
            if length(SubSliceContour) >=5              
                
                YCor=floor(SubSliceContour(:, 1)); XCor=floor(SubSliceContour(:, 2));
                
                XCor2=ImageDataInfo.XStart+(XCor-1)*ImageDataInfo.XPixDim;
                YCor2=ImageDataInfo.YStart+(YCor-1)*ImageDataInfo.YPixDim;
                
                CurvesCor=[CurvesCor; {[XCor2, YCor2]}];
                ZLocation=[ZLocation; ImageDataInfo.ZStart+(i-1)*ImageDataInfo.ZPixDim];
            end
        end        
    end
end
CurvesCor(1)=[];

if nargin < 3
    structAxialROI(1).name='ROIDCM';
else
    structAxialROI(1).name=ROIName;
end
structAxialROI(1).OrganCurveNum=length(ZLocation);
structAxialROI(1).ZLocation=ZLocation;
structAxialROI(1).CurvesCor=CurvesCor;

if nargin < 4
    structAxialROI(1).Color='green';
else
    structAxialROI(1).Color=ROIColor;
end



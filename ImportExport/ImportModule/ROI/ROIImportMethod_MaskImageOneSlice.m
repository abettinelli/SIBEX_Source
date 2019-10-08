function structAxialROI=ROIImportMethod_MaskImageOneSlice(FileName, ImageDataInfo)

%Import one slice Mask image if only image is also one slice
try
    MaskMat=imread(FileName);
    MaskMat=uint8(MaskMat);
    
    MinV=min(MaskMat(:));
    MaxV=max(MaskMat(:));
    
    TempIndex=find(MaskMat > MinV & MaskMat < MaxV);    
    
    if size(MaskMat, 3) >1 || ~isempty(TempIndex) ||...
            (size(MaskMat, 1) ~= ImageDataInfo.YDim) || (size(MaskMat, 2) ~= ImageDataInfo.XDim) 
        structAxialROI=[];
        return;
    end   
       
        
    %Import ROI
    MaskMatFinal=zeros(ImageDataInfo.YDim, ImageDataInfo.XDim, ImageDataInfo.ZDim, 'uint8');    
    hFig=findobj(0, 'Type', 'figure', 'Name', 'Specify Data');
    handlesFig=guidata(hFig);
    
    MaskMat=uint8(~logical(MaskMat));    
    MaskMatFinal(:, :, handlesFig.SliceNum)=MaskMat;
    
    structAxialROI=GenerateStructAxialROI(MaskMatFinal, ImageDataInfo);        
    
catch
     structAxialROI=[];
end
 
function   structAxialROI=GenerateStructAxialROI(MaskMat, ImageDataInfo)

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

structAxialROI(1).name='ROIImage';
structAxialROI(1).OrganCurveNum=length(ZLocation);
structAxialROI(1).ZLocation=ZLocation;
structAxialROI(1).CurvesCor=CurvesCor;
structAxialROI(1).Color='red';

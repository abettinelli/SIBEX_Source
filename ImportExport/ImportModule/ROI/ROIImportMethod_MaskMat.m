function structAxialROI=ROIImportMethod_MaskMat(FileName, ImageDataInfo)

%Import
try
    load(FileName, '-mat');
    
    VarList=who;
    
    %Sanity Check 1
    if length(VarList) == 3
        %Sanity Check 2
        TempIndex=strmatch('FileName', VarList, 'exact');
        VarList(TempIndex)=[];
        
        TempIndex=strmatch( 'ImageDataInfo', VarList, 'exact');
        VarList(TempIndex)=[];
        
        eval(['MaskMat=', VarList{1}, ';']);
        
        %FFS
%         MaskMat=flipdim(MaskMat, 3);
        
        %Sanity Check 3
        MaskSize=size(MaskMat);
        if MaskSize(1) == ImageDataInfo.YDim && MaskSize(2) == ImageDataInfo.XDim && MaskSize(3) == ImageDataInfo.ZDim
            MaskMat=uint8(MaskMat);            
            
            %Import ROI
            structAxialROI=GenerateStructAxialROI(MaskMat, ImageDataInfo);
        else
            structAxialROI=[];
        end
    else
        structAxialROI=[];
    end
    
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

structAxialROI(1).name='ROIMat';
structAxialROI(1).OrganCurveNum=length(ZLocation);
structAxialROI(1).ZLocation=ZLocation;
structAxialROI(1).CurvesCor=CurvesCor;
structAxialROI(1).Color='red';

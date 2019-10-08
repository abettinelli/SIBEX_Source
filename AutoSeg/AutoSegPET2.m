function SegMask=AutoSegPET2(ImageData, BoxMask, Para)

%Initialization
levels = Para.LowerThres:0.01:Para.HigherThres;

[RowStart, RowEnd, ColStart, ColEnd]=GetBoxBound(BoxMask);
ImageDataSub=ImageData(RowStart:RowEnd, ColStart:ColEnd, :);
BoxMaskSub=BoxMask(RowStart:RowEnd, ColStart:ColEnd);
SegMaskSub=zeros(size(ImageDataSub), 'uint8');

%SUVmax
BoxMaskT=repmat(BoxMask, [1, 1, size(ImageData, 3)]);
%SUVMax=max(ImageData(BoxMaskT));
SUVMax=PercentileArea(ImageData(BoxMaskT), 0.97);


%Do......
hx = fspecial('sobel');
hy = hx';

for SliceNum = 1:size(ImageDataSub, 3);
    I = ImageDataSub(:, :, SliceNum);    
    I=I.*BoxMaskSub;    
        
        
    %1. Go through each SUV levels to find SUVPerimMean, EdgePerimMean
    Iy = imfilter(double(I), hy, 'replicate');
    Ix = imfilter(double(I), hx, 'replicate');
    gradmag = sqrt(Ix.^2 + Iy.^2);
       
    for i = 1:length(levels)
        mask = zeros(size(I), 'uint8');
    
        TempIndex=find(I > levels(i)*SUVMax);   
        if ~isempty(TempIndex)
            mask(TempIndex) = 1;      
            mask = imfill(mask);            
            MaskPerim=bwperim(mask,8);
            
            gradient_perim(i)=mean(gradmag(MaskPerim));
            SUVperimmean(i) = mean(I(MaskPerim));
        else
            gradient_perim(i)=0;
            SUVperimmean(i)=0;
        end
    end
    
    %2: A. SUVPerimMean can't too be big;  B. Edge need to be strong
    gradient_perim=gradient_perim.*(SUVperimmean<0.6*SUVMax);%%%avoids fitting high gradient near peaks in tumor
    [MaxV, MaxGradIndex]=max(gradient_perim);
    MaxGradIndex=MaxGradIndex(1);
    
    %3. Get rough binary mask, fill holes, remove small objects
    ROI = zeros(size(I), 'uint8');
    if SUVMax > 0
        ROI(I>levels(MaxGradIndex)*SUVMax) = 1;
        
        ROI = imfill(ROI);
        ROI=bwareaopen(ROI, 3);  %Remove small islands
    end
    
    %4. keep the biggest one
    ROI=KeepMaxAreaObject(ROI);
        
    %5. Get the edge envelop. Based on conv hull to smooth the envelop ---
    %apply this within gradient detection portion?
    ROIbuild = zeros(size(ROI));
    
    [labels,Numobj]=bwlabeln(ROI);
    
    for obj = 1:Numobj
        ROItemp = labels==obj;
        
        hull = bwconvhull(ROItemp);
        voids = hull-ROItemp;
        
        [mat,N]=bwlabeln(voids);
        [counts,~]=hist(nonzeros(mat),1:N);
        
        if(~isempty(find(counts>10)))
            
            [MaxV, voidnum]=max(counts);
            
            void = mat ==voidnum;                       
            
            MAL=regionprops(void,'MajorAxisLength');
            MAL = round(MAL.MajorAxisLength);
            
            ROItemp = padarray(ROItemp,[MAL,MAL]);
            ROItemp=imerode(imdilate(ROItemp,ones(MAL)),ones(MAL));
            ROItemp = ROItemp(1+MAL:end-MAL,1+MAL:end-MAL);
        end
        
        ROIbuild = ROIbuild+ROItemp;
    end
    
%     figure, imagesc(ImageData(:, :, SliceNum)), colormap(gray);
%     figure, imagesc(BoxMask), colormap(gray);
%     figure, imagesc(I), colormap(gray);
    %figure, imagesc(flipud(ROIbuild)), colormap(gray);
    
    SegMaskSub(:, :, SliceNum)=logical(ROIbuild);     
end

SegMaskSub = KeepMaxAreaObject(SegMaskSub);
SegMask=zeros(size(ImageData), 'uint8');
SegMask(RowStart:RowEnd, ColStart:ColEnd, :)=SegMaskSub;


%-----------------------------------------------------------------%
function ROI=KeepMaxAreaObject(ROI)
[BWLabel,NumObj]=bwlabeln(ROI);

if NumObj < 2
    return;
end

Stats=regionprops(BWLabel, 'Area');

[TempV, MaxIndex]=max(cell2mat({Stats.Area}'));

TempIndex=find(BWLabel<MaxIndex | BWLabel>MaxIndex);
BWLabel(TempIndex)=0;

ROI=logical(BWLabel);



function Value=PercentileArea(ImageData, Percentile)
Percentile=Percentile*100;

%Histogram
BinLoc=double(0:0.5:50);
[p, BinCenter] = hist(ImageData, BinLoc);
p = p ./ sum(p);

HistData=[BinCenter', p'];

HistBin=HistData(:, 1);
HistCount=HistData(:, 2);

HistCountCum=cumsum(HistCount, 1);
HistCountCum=HistCountCum*100/HistCountCum(end);

[HistCountCumUnique, TIndex]=unique(HistCountCum, 'first');
HistBinUnique=HistBin(TIndex);

try
    Value=interp1(HistCountCumUnique, HistBinUnique, Percentile);
catch
    Value=repmat(NaN, length(Percentile), 1);
end


function [RowStart, RowEnd, ColStart, ColEnd]=GetBoxBound(BoxMask)
[RowIndex, ColIndex]=find(BoxMask);
RowStart=min(RowIndex);
RowEnd=max(RowIndex);
ColStart=min(ColIndex);
ColEnd=max(ColIndex);


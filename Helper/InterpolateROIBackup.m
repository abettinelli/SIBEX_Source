function ResultCurve=InterpolateROI(BWInfo, InterpTablePos, ContourZLoc)

%Parameters
pts_num_thresh  = 3;
ResultCurve=[];

%Closest slices
BMMask=BWInfo.MaskData;

ContourZLoc=sort(ContourZLoc);

Distance=ContourZLoc-InterpTablePos;

TempIndexTop=find(Distance < 0);
TempIndexBottom=find(Distance > 0);

if isempty(TempIndexTop) || isempty(TempIndexBottom)
    return;
end

%Binary mask of closest slices
TopLoc=ContourZLoc(TempIndexTop(end));
BottomLoc=ContourZLoc(TempIndexBottom(1));

TempIndexTop=round((TopLoc-BWInfo.ZStart)/BWInfo.ZPixDim+1);
TempIndexBottom=round((BottomLoc-BWInfo.ZStart)/BWInfo.ZPixDim+1);

BW1=BMMask(:, :,TempIndexTop);
BW2=BMMask(:, :,TempIndexBottom);

BW1B = BW1;
BW2B = BW2;

BW1C= bwconncomp(BW1);
BW2C= bwconncomp(BW2);

BW1C.NumObjects=2;
BW2C.NumObjects=2;

%Align to center and then interploate if both slice have 1 object
if BW1C.NumObjects < 2 && BW2C.NumObjects < 2  
    %Area Center
    [RowIndex, ColIndex]=find(BW1);
    BW1C = [mean(RowIndex), mean(ColIndex)];
    [RowIndex, ColIndex]=find(BW2);
    BW2C = [mean(RowIndex), mean(ColIndex)];
    
    %Bourndary BW
    BW1=bwperim(BW1);
    BW2=bwperim(BW2);   
       
    [RowN, ColN]=size(BW1);
    Offset1=[RowN/2-BW1C(1), ColN/2-BW1C(2)];
    Offset2=[RowN/2-BW2C(1), ColN/2-BW2C(2)];
    
    %Center BW1
    [RowIndex, ColIndex]=find(BW1);
    RowIndex1=round(RowIndex+Offset1(1));
    ColIndex1=round(ColIndex+Offset1(2));
    
    %Center BW2
    [RowIndex, ColIndex]=find(BW2);
    RowIndex2=round(RowIndex+Offset2(1));
    ColIndex2=round(ColIndex+Offset2(2));
    
    MinRowIndex=min([RowIndex1; RowIndex2]);
    MaxRowIndex=max([RowIndex1; RowIndex2]);
    
    MinColIndex=min([ColIndex1; ColIndex2]);
    MaxColIndex=max([ColIndex1; ColIndex2]);
    
    FinalRow=MaxRowIndex-MinRowIndex+4;
    FinalCol=MaxColIndex-MinColIndex+4;
    
    %Expand Shift
    RowIndex1=RowIndex1-MinRowIndex+2;
    ColIndex1=ColIndex1-MinColIndex+2;
    
    RowIndex2=RowIndex2-MinRowIndex+2;
    ColIndex2=ColIndex2-MinColIndex+2;
    
    BW1=logical(zeros(FinalRow, FinalCol));
    IND = sub2ind([FinalRow, FinalCol], RowIndex1, ColIndex1);
    BW1(IND)=1;
    
    BW2=logical(zeros(FinalRow, FinalCol));
    IND = sub2ind([FinalRow, FinalCol], RowIndex2, ColIndex2);
    BW2(IND)=1;
    
    %figure, imshow(BW1);
    %figure, imshow(BW2);
    
    %Fill
    BW1B = imfill(BW1,'holes');
    BW2B = imfill(BW2,'holes');
    
    %Distance Map
    BW1=bwdist(BW1);
    BW1(BW1B)=BW1(BW1B)*-1;
    BW2=bwdist(BW2);
    BW2(BW2B)=BW2(BW2B)*-1;
    
    BWI=double(BW1)*abs(BottomLoc-InterpTablePos)/abs(TopLoc-BottomLoc) +...
        double(BW2)*abs(TopLoc-InterpTablePos)/abs(TopLoc-BottomLoc);
    
    BWIC =double(BW1C)*abs(BottomLoc-InterpTablePos)/abs(TopLoc-BottomLoc) +...
        double(BW2C)*abs(TopLoc-InterpTablePos)/abs(TopLoc-BottomLoc);
    
    %Interpolated Center
    [RowIndex, ColIndex]=find(BWI <= 0);
    InterpCCenterT=[mean(RowIndex), mean(ColIndex)];    
    
    OffsetX=(BWIC(2)-InterpCCenterT(2))*BWInfo.XPixDim;
    OffsetY=(BWIC(1)-InterpCCenterT(1))*BWInfo.YPixDim;   
    
    InterpBW = BWI <= 0.5;       
else
    %Bourdary BW
    BW1=bwperim(BW1);
    BW2=bwperim(BW2);
    
    BW1B = xor(BW1B,BW1);
    BW2B = xor(BW2B,BW2);
    
    %Interpolate through distance map
    BW1=bwdist(BW1);
    BW1(BW1B)=BW1(BW1B)*-1;
    
    BW2=bwdist(BW2);
    BW2(BW2B)=BW2(BW2B)*-1;
    
    BWI=double(BW1)*abs(BottomLoc-InterpTablePos)/abs(TopLoc-BottomLoc) +...
        double(BW2)*abs(TopLoc-InterpTablePos)/abs(TopLoc-BottomLoc);
    
    OffsetX=0;
    OffsetY=0;   
    
    InterpBW = BWI <= 0.5;
end

%Get Curves in matrix coordinates
Tempboundary= bwboundaries(InterpBW);
Tempboundary=CleanOutCurve(Tempboundary, pts_num_thresh);

%Get Curves in physical coordinates
ResultCurve=ConvertCurveToPhysical(Tempboundary, BWInfo, OffsetX, OffsetY);

function ResultCurve=ConvertCurveToPhysical(Tempboundary, BWInfo, OffsetX, OffsetY)
ResultCurve=[];

num_curve = length( Tempboundary);
for cur_ind = 1:num_curve
    
    InterpC = Tempboundary{cur_ind};
    
    InterpYCor=InterpC(:,1);
    InterpXCor=InterpC(:,2);
    
    InterpXCor=BWInfo.XStart+(InterpXCor-1)*BWInfo.XPixDim+OffsetX;
    InterpYCor=BWInfo.YStart+(BWInfo.YDim-InterpYCor)*BWInfo.YPixDim+OffsetY;
    
    ResultCurve=[ResultCurve; {[InterpXCor, InterpYCor]}];
end


function Tempboundary=CleanOutCurve(Tempboundary, pts_num_thresh)
%Close curve and Remove false curves
false_cur_ind = [];
for jj = 1:length(Tempboundary)
    temp_curve = Tempboundary{jj};
    temp_curve = temp_curve(1:2:end,:);
    
    if (temp_curve(1,1)~= temp_curve(end,1)) |  (temp_curve(1,2)~= temp_curve(end,2))
        temp_curve= [temp_curve;temp_curve(1,:)];
    end
    Tempboundary{jj} = temp_curve;
    
    if length(temp_curve)<=pts_num_thresh
        false_cur_ind = [false_cur_ind; jj];
    end
    
end
Tempboundary(false_cur_ind) = [];

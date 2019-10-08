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

function BWMatInfo=BWFillROINoZPix(BWMatInfo, structAxialROI)

%keyboard

BWMatInfo.XStart=[];
BWMatInfo.YStart=[];
BWMatInfo.ZStart=[];

BWMatInfo.XDim=[];
BWMatInfo.YDim=[];
BWMatInfo.ZDim=[];

BWMatInfo.MaskData=[];

ContourZLoc={structAxialROI.ZLocation}';
ContourZLoc=cell2mat(ContourZLoc);

if isempty(ContourZLoc)
    return;
end

%Get Limit box
MinZ=min(ContourZLoc);
MaxZ=max(ContourZLoc);

BWMatInfo.ZPixDim=GetZPixDim(ContourZLoc);

MinX=9999999;
MinY=9999999;
MaxX=-9999999;
MaxY=-9999999;

ContourNum=length(structAxialROI.CurvesCor);

for i=1:ContourNum
    ContourData=structAxialROI.CurvesCor{i};
    
    if ~isempty(ContourData)
        MinX=min(MinX, min(ContourData(:, 1)));
        MaxX=max(MaxX, max(ContourData(:, 1)));
        
        MinY=min(MinY, min(ContourData(:, 2)));
        MaxY=max(MaxY, max(ContourData(:, 2)));
    end
end

BWMatInfo.XStart=MinX;
BWMatInfo.YStart=MinY;
BWMatInfo.ZStart=MinZ;

% Round
BWMatInfo.XStart = round(BWMatInfo.XStart*10000)/10000;
BWMatInfo.YStart = round(BWMatInfo.YStart*10000)/10000;
BWMatInfo.ZStart = round(BWMatInfo.ZStart*10000)/10000;
BWMatInfo.XPixDim = round(BWMatInfo.XPixDim*10000)/10000;
BWMatInfo.YPixDim = round(BWMatInfo.YPixDim*10000)/10000;
BWMatInfo.ZPixDim = round(BWMatInfo.ZPixDim*10000)/10000;

% Idx Cols Rows and Pages
MinRow=1;
MaxRow=round((MaxY-BWMatInfo.YStart)/BWMatInfo.YPixDim+1);
MinCol=1;
MaxCol=round((MaxX-BWMatInfo.XStart)/BWMatInfo.XPixDim+1);
MinPage=1;
MaxPage=round((MaxZ-BWMatInfo.ZStart)/BWMatInfo.ZPixDim+1);

%Fill
Y_RowNum=MaxRow-MinRow+1;
X_ColNum=MaxCol-MinCol+1;
Z_PageNum=MaxPage-MinPage+1;

TablePos=BWMatInfo.ZStart+(0:Z_PageNum-1)*BWMatInfo.ZPixDim;
TablePos=TablePos';

BWMat=zeros(Y_RowNum, X_ColNum, Z_PageNum, 'uint8');
Y_row_grid = 1:Y_RowNum;
X_col_grid = 1:X_ColNum;
[A, B] = meshgrid(X_col_grid, Y_row_grid);

[ContourZLoc_unique,~, idx_unique] = unique(ContourZLoc, 'stable');

%tic
for i=1:length(ContourZLoc_unique)
    
    idxs_ZLoc = find(idx_unique == i);
    ContourData = [];
    edge = [];
    
    % Concatenate multiple contour per single slice
    for id = 1:length(idxs_ZLoc)
        pointer = size(ContourData,1);
        TempZLocation=ContourZLoc(idxs_ZLoc(id));    %ZLocation
        ContourData_temp=structAxialROI.CurvesCor{idxs_ZLoc(id)};
        
        [a, b] = IBSI_close_ROI(ContourData_temp(:,1), ContourData_temp(:,2));
        ContourData = [ContourData; a b];
        edge_temp = [(1:size(b,1)-1)', (2:size(a,1))'];
        edge = [edge; edge_temp+pointer];
        
    end
    
    %If curve is in image domain
    BWSlice_MATLAB = zeros(Y_RowNum, X_ColNum, 'uint8');
    if  min(abs(TablePos-TempZLocation)) <= (BWMatInfo.ZPixDim/3)
        
        X_BWC=ContourData(:,1);
        Y_BWR=ContourData(:,2);
        % Round
        X_BWC = round(X_BWC*10000)/10000;
        Y_BWR = round(Y_BWR*10000)/10000;
        
        X_CIndex=(X_BWC-MinX)/BWMatInfo.XPixDim+1;
        Y_RIndex=(Y_BWR-MinY)/BWMatInfo.YPixDim+1;
        
        node = [X_CIndex, Y_RIndex];
        edge = [edge(:,1), edge(:,2)];
        [stat,bnds] = IBSI_inpoly([A(:), B(:)], node, edge);
        BWSlice_MATLAB(stat | bnds) = 1;
        
        [~, ZIndex]=min(abs(TablePos-TempZLocation));
        
        BWMat(:,:,ZIndex)=BWSlice_MATLAB;
    end
end

% %Square Len for MKroipoly
% SquareLen=max(RowNum, ColNum);
% 
% for i=1:ContourNum    
%     TempZLocation=ContourZLoc(i)  ;    %ZLocation
%     ContourData=structAxialROI.CurvesCor{i};
%            
%     if  min(abs(TablePos-TempZLocation)) <= (BWMatInfo.ZPixDim/3)      %if curve is in image domain
%         
%         BWC=ContourData(:,2); BWR=ContourData(:,1);
%         
%         CIndex=round((BWC-MinY)/BWMatInfo.YPixDim)+1;
%         RIndex=round((BWR-MinX)/BWMatInfo.XPixDim)+1;
%         
%         %Method 1---MATLAB
% %         TempImage=uint8(zeros(RowNum, ColNum, 'uint8'));
% %         BWSlice=roipoly(TempImage, RIndex, CIndex);        
%         
%         %Method 2---MKRoipoly
%         TempImage=uint8(zeros(SquareLen, SquareLen, 'uint8'));
%         
%         x=BWR-single(MinX); x=(x/single(BWMatInfo.XPixDim))+1;
%         y=BWC-single(MinY); y=(y/single(BWMatInfo.YPixDim))+1;
%         BWSlice=MKroipoly(TempImage, x, y);
%         BWSlice=BWSlice(1:RowNum, 1:ColNum);
%                        
%         [MinT, ZIndex]=min(abs(TablePos-TempZLocation));
%         
%         BWMat(:,:,ZIndex)=xor(BWMat(:,:,ZIndex), BWSlice);
%     end        
% end
% Create ROI BW Mask

BWMat=flip(BWMat, 1);

BWMatInfo.XDim=size(BWMat, 2);
BWMatInfo.YDim=size(BWMat, 1);
BWMatInfo.ZDim=size(BWMat, 3);

BWMatInfo.MaskData=BWMat;

function ZPixDim=GetZPixDim(ContourZLoc)
ContourZLoc=sort(ContourZLoc);

DiffKernal=[1, -1]';

DiffZLoc=conv(ContourZLoc, DiffKernal);
DiffZLoc(1)=[];
DiffZLoc(end)=[];

DiffZLoc=abs(DiffZLoc);

%Same slice
TempIndex=find(DiffZLoc < 0.00000001);
if ~isempty(TempIndex)
    DiffZLoc(TempIndex)=[];
end

%only one slice
if isempty(DiffZLoc)
    ZPixDim=0.3;
    return;
end

ZPixDim=min(DiffZLoc);

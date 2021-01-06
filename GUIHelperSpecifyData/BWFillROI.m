function BWMatInfo=BWFillROI(ROIIndex, PlanIndex, handles, ZLocation, LineX, LineY)
%%% USED during GUI Specify Data to display contour (will be saved in dataset file (and resampling))

BWMatInfo.XStart=[];
BWMatInfo.YStart=[];
BWMatInfo.ZStart=[];

BWMatInfo.XDim=[];
BWMatInfo.YDim=[];
BWMatInfo.ZDim=[];

BWMatInfo.XPixDim=[];
BWMatInfo.YPixDim=[];
BWMatInfo.ZPixDim=[];

BWMatInfo.MaskData=[];

%Preprocess--resample
if isfield(handles, 'ZStart')
    ResampleFlag=1;
else
    ResampleFlag=0;
end

if ResampleFlag <1
    %SpecifyData, ROIEditor, ROIEditorDataSet
    ImageDataInfoAxial=GetImageDataInfo(handles, 'Axial');
else
    %Preprocess--resample
    ImageDataInfoAxial=handles;
    ImageDataInfoAxial.TablePos=handles.ZStart+((1:handles.ZDim)-1)*handles.ZPixDim;
    structViewROI=handles.structAxialROI;
end

switch nargin
    case 3
        if ~isempty(PlanIndex)
            structViewROI=handles.PlansInfo.structAxialROI{PlanIndex};
        end
        
        ContourNum=length(structViewROI(ROIIndex).CurvesCor);
        ContourZLoc=structViewROI(ROIIndex).ZLocation;
    case 4
        structViewROI=handles.PlansInfo.structAxialROI{PlanIndex};
        structViewROI=structViewROI(ROIIndex);
        ContourZLoc=structViewROI.ZLocation;
        
        TempIndex=find(abs(ContourZLoc-ZLocation) < ImageDataInfoAxial.ZPixDim/3);
        if isempty(TempIndex)
            return;
        end
        
        structViewROI.ZLocation=structViewROI.ZLocation(TempIndex);
        structViewROI.CurvesCor=structViewROI.CurvesCor(TempIndex);
        
        ContourNum=length(structViewROI.CurvesCor);
        ContourZLoc=structViewROI.ZLocation;
        
        ROIIndex=1;
    case 6
        structViewROI.CurvesCor(1)={[LineX', LineY']};
        ContourNum=length(structViewROI.CurvesCor);
        ContourZLoc=ZLocation;
        
        ROIIndex=1;
end

if isempty(ContourZLoc)
    return;
end

%Skip dilation
if isfield(handles, 'skip_expantion')
    SkipFlag=true;
else
    SkipFlag=false;
end

%Get Limit box
if ResampleFlag <1
    MinZ=min(ContourZLoc);
    MaxZ=max(ContourZLoc);
    
    % Bettinelli - single
    MinX=double(9999999);
    MinY=double(9999999);
    MaxX=-double(9999999);
    MaxY=-double(9999999);
    
    for i=1:ContourNum
        
        ContourData=structViewROI(ROIIndex).CurvesCor{i};
        
        if ~isempty(ContourData)
            MinX=min(MinX, min(ContourData(:, 1)));
            MaxX=max(MaxX, max(ContourData(:, 1)));
            
            MinY=min(MinY, min(ContourData(:, 2)));
            MaxY=max(MaxY, max(ContourData(:, 2)));
        end
    end
else
    %Preprocess--resample
    MinX=ImageDataInfoAxial.XStart;
    MaxX=ImageDataInfoAxial.XStart+(ImageDataInfoAxial.XDim-1)*ImageDataInfoAxial.XPixDim;
    
    MinY=ImageDataInfoAxial.YStart;
    MaxY=ImageDataInfoAxial.YStart+(ImageDataInfoAxial.YDim-1)*ImageDataInfoAxial.YPixDim;
    
    MinZ=ImageDataInfoAxial.ZStart;
    MaxZ=ImageDataInfoAxial.ZStart+(ImageDataInfoAxial.ZDim-1)*ImageDataInfoAxial.ZPixDim;
%     SkipFlag = true;
end

% Find ROI borders - index
X_MinCol=max(round((MinX-ImageDataInfoAxial.XStart)/ImageDataInfoAxial.XPixDim)+1,1);
X_MaxCol=round((MaxX-ImageDataInfoAxial.XStart)/ImageDataInfoAxial.XPixDim)+1;
Y_MinRow=max(round((MinY-ImageDataInfoAxial.YStart)/ImageDataInfoAxial.YPixDim)+1,1);
Y_MaxRow=round((MaxY-ImageDataInfoAxial.YStart)/ImageDataInfoAxial.YPixDim)+1;
Z_MinPage=max(round((MinZ-ImageDataInfoAxial.ZStart)/ImageDataInfoAxial.ZPixDim)+1,1);
Z_MaxPage=round((MaxZ-ImageDataInfoAxial.ZStart)/ImageDataInfoAxial.ZPixDim)+1;

%Update MinX, MinY, MinZ according to ROI borders and GRIDs
MinX=ImageDataInfoAxial.XStart + (X_MinCol-1)*ImageDataInfoAxial.XPixDim;
MinY=ImageDataInfoAxial.YStart + (Y_MinRow-1)*ImageDataInfoAxial.YPixDim;
MinZ=ImageDataInfoAxial.ZStart + (Z_MinPage-1)*ImageDataInfoAxial.ZPixDim;
%MinZ=ImageDataInfoAxial.TablePos(Z_MinPage+1);

%Fill
X_ColNum=X_MaxCol-X_MinCol+1;
Y_RowNum=Y_MaxRow-Y_MinRow+1;
Z_PageNum=Z_MaxPage-Z_MinPage+1;

TablePos=ImageDataInfoAxial.TablePos(Z_MinPage:Z_MaxPage);

% Create ROI BW Mask
BWMat_MATLAB=zeros(Y_RowNum, X_ColNum, Z_PageNum, 'uint8');
Y_row_grid = 1:Y_RowNum;
X_col_grid = 1:X_ColNum;
[A, B] = meshgrid(X_col_grid, Y_row_grid);

% Y_mm = (0:Y_RowNum-1)*(ImageDataInfoAxial.YPixDim)+single(round(MinY*1000)/1000);
% X_mm = (0:X_ColNum-1)*(ImageDataInfoAxial.XPixDim)+single(round(MinX*1000)/1000);
% [A_mm, B_mm] = meshgrid(X_mm, Y_mm);

%ContourZLoc_sorted = sort(ContourZLoc, 'descend');
[ContourZLoc_unique,~, idx_unique] = unique(ContourZLoc, 'stable'); %_sorted

%tic
for i=1:length(ContourZLoc_unique)
    
    idxs_ZLoc = find(idx_unique == i);
    ContourData = [];
    edge = [];
    % Concatenate multiple contour per single slice
    for id = 1:length(idxs_ZLoc)
        pointer = size(ContourData,1);
        TempZLocation=ContourZLoc(idxs_ZLoc(id));    %ZLocation
        ContourData_temp=structViewROI(ROIIndex).CurvesCor{idxs_ZLoc(id)};
        
        [a, b] = IBSI_close_ROI(ContourData_temp(:,1), ContourData_temp(:,2));

        ContourData = [ContourData; a b];
        edge_temp = [(1:size(b,1)-1)', (2:size(a,1))'];
        edge = [edge; edge_temp+pointer];
        
    end
    
    %If curve is in image domain
    BWSlice_MATLAB = zeros(Y_RowNum, X_ColNum, 'uint8');
    if  min(abs(TablePos-TempZLocation)) <= (ImageDataInfoAxial.ZPixDim/3)
        
        X_BWC=ContourData(:,1);
        Y_BWR=ContourData(:,2);

        % NON ROUND
        X_CIndex=(X_BWC-MinX)/ImageDataInfoAxial.XPixDim+1;
        Y_RIndex=(Y_BWR-MinY)/ImageDataInfoAxial.YPixDim+1;
        
        node = [X_CIndex, Y_RIndex];
        edge = [edge(:,1), edge(:,2)];
        
%         [stat,bnds] = IBSI_inpoly([A(:), B(:)], node, edge);
                
        % Single Conversion
        [stat,bnds] = IBSI_inpoly(single([A(:), B(:)]), single(node), single(edge));
        
        BWSlice_MATLAB(stat | bnds) = 1;
        
        [~, ZIndex]=min(abs(TablePos-TempZLocation));
        
        BWMat_MATLAB(:,:,ZIndex)=BWSlice_MATLAB;
    end
end
%toc
BWMat = BWMat_MATLAB;
BWMat=flip(BWMat, 1);

% Save Results
BWMatInfo.XStart=MinX;
BWMatInfo.YStart=MinY;
BWMatInfo.ZStart=MinZ;

BWMatInfo.XStartIdx=X_MinCol;
BWMatInfo.YStartIdx=Y_MinRow;
BWMatInfo.ZStartIdx=Z_MinPage;

BWMatInfo.XEndIdx=X_MaxCol;
BWMatInfo.YEndIdx=Y_MaxRow;
BWMatInfo.ZEndIdx=Z_MaxPage;

BWMatInfo.XDim=size(BWMat, 2);
BWMatInfo.YDim=size(BWMat, 1);
BWMatInfo.ZDim=size(BWMat, 3);

BWMatInfo.XPixDim=ImageDataInfoAxial.XPixDim;
BWMatInfo.YPixDim=ImageDataInfoAxial.YPixDim;
BWMatInfo.ZPixDim=ImageDataInfoAxial.ZPixDim;
BWMatInfo.MaskData=BWMat;

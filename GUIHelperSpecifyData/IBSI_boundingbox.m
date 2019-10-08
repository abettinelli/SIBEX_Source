function ROIDataInfo=IBSI_boundingbox(ImageDataInfo, ROIDataInfo, handles)

% creata da BWfillROI
MinX_ROI=ROIDataInfo.XStart;
MinY_ROI=ROIDataInfo.YStart;
MinZ_ROI=ROIDataInfo.ZStart;
MaxX_ROI=ROIDataInfo.XStart+(ROIDataInfo.XDim-1)*ROIDataInfo.XPixDim;
MaxY_ROI=ROIDataInfo.YStart+(ROIDataInfo.YDim-1)*ROIDataInfo.YPixDim;
MaxZ_ROI=ROIDataInfo.ZStart+(ROIDataInfo.ZDim-1)*ROIDataInfo.ZPixDim;

% Find ROI borders - index
X_MinCol=round((MinX_ROI-ImageDataInfo.XStart)/ImageDataInfo.XPixDim)+1;
X_MaxCol=round((MaxX_ROI-ImageDataInfo.XStart)/ImageDataInfo.XPixDim)+1;
Y_MinRow=round((MinY_ROI-ImageDataInfo.YStart)/ImageDataInfo.YPixDim)+1;
Y_MaxRow=round((MaxY_ROI-ImageDataInfo.YStart)/ImageDataInfo.YPixDim)+1;
Z_MinPage=round((MinZ_ROI-ImageDataInfo.ZStart)/ImageDataInfo.ZPixDim)+1;
Z_MaxPage=round((MaxZ_ROI-ImageDataInfo.ZStart)/ImageDataInfo.ZPixDim)+1;

% Number of Voxel for ROI dilation
BWMat_ROI = ROIDataInfo.MaskData;
Delta=[handles.PadROI handles.PadROI handles.PadROI];
DeltaLim1=abs([X_MinCol-1, Y_MinRow-1, Z_MinPage-1]);
DeltaLim2=abs([ImageDataInfo.XDim-X_MaxCol, ImageDataInfo.YDim-Y_MaxRow, ImageDataInfo.ZDim-Z_MaxPage]);

Delta_prec = min([Delta; DeltaLim1]);
Delta_post = min([Delta; DeltaLim2]);

% if ~isempty(find(nnz(2*DeltaHope-Delta_prec-Delta_post),1))
%     display('Warning')
% end

% Update DIMs
X_MinCol_expantion=X_MinCol-Delta_prec(1);
X_MaxCol_expantion=(X_MaxCol)+Delta_post(1);
Y_MinRow_expantion=Y_MinRow-Delta_prec(2);
Y_MaxRow_expantion=(Y_MaxRow)+Delta_post(2);
Z_MinPage_expantion=Z_MinPage-Delta_prec(3);
Z_MaxPage_expantion=(Z_MaxPage)+Delta_post(3);

% Update Info ROI
% Update MinX, MinY, MinZ according to the ROI dilation and grids
ROIDataInfo.XStart=(X_MinCol_expantion-1)*ImageDataInfo.XPixDim+ImageDataInfo.XStart;
ROIDataInfo.YStart=(Y_MinRow_expantion-1)*ImageDataInfo.YPixDim+ImageDataInfo.YStart;
ROIDataInfo.ZStart=ImageDataInfo.TablePos(Z_MinPage_expantion);

ROIDataInfo.XEnd=(X_MaxCol_expantion-1)*ImageDataInfo.XPixDim+ImageDataInfo.XStart;
ROIDataInfo.YEnd=(Y_MaxRow_expantion-1)*ImageDataInfo.YPixDim+ImageDataInfo.YStart;
ROIDataInfo.ZEnd=ImageDataInfo.TablePos(Z_MaxPage_expantion);

ROIDataInfo.XDim=double(X_MaxCol_expantion-X_MinCol_expantion+1);
ROIDataInfo.YDim=double(Y_MaxRow_expantion-Y_MinRow_expantion+1);
ROIDataInfo.ZDim=double(Z_MaxPage_expantion-Z_MinPage_expantion+1);

% BWMat dilation
BWMat_ROI = padarray(BWMat_ROI,double([Delta_post(2),Delta_prec(1),Delta_prec(3)]),0,'pre');
BWMat_ROI = padarray(BWMat_ROI,double([Delta_prec(2),Delta_post(1),Delta_post(3)]),0,'post');
ROIDataInfo.MaskData = BWMat_ROI;

%MorphologicalMask
ROIDataInfo.MorphologicalMaskData = BWMat_ROI;
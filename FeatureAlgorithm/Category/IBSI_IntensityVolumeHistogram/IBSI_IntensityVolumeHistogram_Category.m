function ParentInfo=IBSI_IntensityVolumeHistogram_Category(CDataSetInfo, Mode, Param)
%%%Doc Starts%%%
% -Description:
% 1. This method is to compute the intensity-volume histogram (IVH) from image inside
%     the binary mask.
% 2. IVH is passed into IBSI_IntensityVolumeHistogram_Feature.m to compute the related features.
%
% -Parameters:
% 1. Rescale:
%	'fbn': fixed bin number -> specify BinNumber
%	'fbs': fixed bin size   -> specify BinSize
%	'off': do not perform the discretization step
% 2. BinNumber: Integer specifying the number of bin number to use when scaling the grayscale values. [] when rescale is set to 'fbs' or 'off';
% 3. BinSize: Integer specifying the bin size to use when scaling the grayscale values. [] when rescale is set to 'fbn' or 'off';
%
% -Revision:
% 2019-02-18: The method is implemented.
%
% -Authors:
% Andrea Bettinelli
%%%Doc Ends%%%

if isequal(Mode, 'InfoID')
    ParentInfo=[];
else
    %Code
    % Pinnacle to IBSI
    CDataSetInfo = IBSI_waterCTnumber(CDataSetInfo);
    
    %[~, ImgVector_d, G, X_d, X_gl_d] = IBSI_IVH_gl_rescale(CDataSetInfo, Param);
    
    [CDataSetInfo, Param] = IBSI_gl_rescale(CDataSetInfo, Param);
    ImgVector_d = double(CDataSetInfo.ROIImageInfo.MaskData(CDataSetInfo.ROIBWInfo.MaskData == 1));
    G = Param.G;
    X_d = Param.X_d;
    X_gl_d = Param.X_gl_d;
    
    % Fractional volume
    counts = zeros(length(X_d), 1);
    for n = 1:length(X_d)
        counts(n) = nnz(ImgVector_d < X_d(n));
    end
    % counts = 1-counts./nnz(ImgVector_d);
    counts = 1-counts./length(ImgVector_d);
    
    % Gray level fraction
    gamma = (X_gl_d-min(G))/(max(G)-min(G));
    
    %Histogram
    CDataSetInfo.ROIImageInfo.counts=counts;
    CDataSetInfo.ROIImageInfo.gamma=gamma;
    CDataSetInfo.ROIImageInfo.intensities=X_gl_d;
    
    switch Mode
        case 'Review'
            ReviewInfo=CDataSetInfo.ROIImageInfo;
            ParentInfo=ReviewInfo;
            
        case 'Child'
            ParentInfo=CDataSetInfo;
    end
end
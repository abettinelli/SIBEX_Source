function ParentInfo=IBSI_GrayLevelRunLengthMatrix_Category(CDataSetInfo, Mode, Param)
%%%Doc Starts%%%
% -Description: 
% 1. This method is to compute gray-level run length matrix (GLRLM) from image inside
%    the binary mask using the desired 2D/3D approach in 13 unique directions.
% 2. GLRLM is passed into GrayLevelRunLengthMatrix25_Feature.m to compute the related features.
% 
% -Parameters:
% 1. Direction: Define the angle of intensity pair (phi/theta).
%	0: 0/90, 1: 90/90, 2: 45/90, 3: 135/90, 4: 0/0, 5: 90/45, 6: 90/135
%	7: 0/45, 8: 0/135, 9: 45/45, 10: 135/45, 11: 45/135, 12: 135/135
% 2. AggregationMethod: 
%	1: 2D:avg
%	2: 2D:mrg
%	3: 2D:vmrg
%	4: 3D:avg
%	5: 3D:mrg
% 3. Rescale: 
%	'fbn': fixed bin number -> specify BinNumber
%	'fbs': fixed bin size   -> specify BinSize
%	'off': do not perform the discretization step
% 4. BinNumber: Integer specifying the number of bin number to use when scaling the grayscale values. [] when rescale is set to 'fbs' or 'off';
% 5. BinSize: Integer specifying the bin size to use when scaling the grayscale values. [] when rescale is set to 'fbn' or 'off';
% 
% -References:
% 1.  M. M. Galloway. Texture analysis using gray level run lengths. 
%    Computer Graphics and Image Processing, 4:172–179, 1975.
% 2.  Xiaoou Tang. Texture information in run-length matrices.
%    IEEE Transactions on Image Processing ,Volume 7 Issue 11, Page 1602-1609 
% 3. Zwanenburg A, Leger S, Vallières M, Löck S. Image biomarker standardisation initiative. 
%      December 2016. http://arxiv.org/abs/1612.07003. Accessed May 21, 2019.
% 
% -Revision:
% 2019-07-10: The method is made IBSI compliant.
% 2014-05-22: The method is implemented.
% 
% -Authors:
% Joy Zhang, lifzhang@mdanderson.org
% 
% Andrea Bettinelli
%%%Doc Ends%%%

% Pinnacle to IBSI
CDataSetInfo = IBSI_waterCTnumber(CDataSetInfo);

% Limiti opzionali (modificano ROI)
[CDataSetInfo, Param] = IBSI_gl_rescale(CDataSetInfo, Param);

%Check param
if~ isfield(Param, 'GrayLimits')
    Param.GrayLimits = [min(CDataSetInfo.ROIImageInfo.MaskData(CDataSetInfo.ROIBWInfo.MaskData == 1)) max(CDataSetInfo.ROIImageInfo.MaskData(CDataSetInfo.ROIBWInfo.MaskData == 1))];
end

ROIImageData=CDataSetInfo.ROIImageInfo.MaskData;
ROIBWData=CDataSetInfo.ROIBWInfo.MaskData;

% Remove empty slices above and below ROI
[ROIImageData, ROIBWData] = IBSI_minimal_ROI(ROIImageData, ROIBWData);

%Code
if isequal(Param.AggregationMethod, 1) || isequal(lower(Param.AggregationMethod), '2davg') || isequal(Param.AggregationMethod, 2) || isequal(lower(Param.AggregationMethod), '2dmrg')...
        || isequal(Param.AggregationMethod, 3) || isequal(lower(Param.AggregationMethod), '2dvmrg') || isequal(Param.AggregationMethod, 6) || isequal(lower(Param.AggregationMethod), '25dmrg')
    if length(Param.Direction) > 4
        error('For 2D extraction only 4 direction possible (0 1 2 3)')
    end
    GLRLMStruct=ComputeGLRLM2D(ROIImageData, ROIBWData, Param);
    
end
if isequal(Param.AggregationMethod, 4) || isequal(lower(Param.AggregationMethod), '3davg') || isequal(Param.AggregationMethod, 5) || isequal(lower(Param.AggregationMethod), '3dmrg')
    GLRLMStruct=ComputeGLRLM3D(ROIImageData, ROIBWData, Param);
end

switch Mode
    case 'Review'
        ReviewInfo=CDataSetInfo.ROIImageInfo;
        ReviewInfo.GLRLMStruct25=GLRLMStruct;        
        ParentInfo=ReviewInfo;
        
    case 'Child'
        CDataSetInfo.ROIImageInfo.GLRLMStruct25=GLRLMStruct;
        ParentInfo=CDataSetInfo;
end

function GLRLMStruct3=ComputeGLRLM3D(ROIImageData, ROIBWData, Param)

if ~(isfield(Param, 'Direction') && isfield(Param, 'GrayLimits') && isfield(Param, 'NumLevels') && isfield(Param, 'Offset') && isfield(Param, 'Symmetric'))
    GLCMStruct=[];
end

Count=1;

% Support 13 directions
for i=1:length(Param.Direction)
    
    [GLRLM, SI] = IBSI_GrayRLMatrix3_Mask(double(ROIImageData), ROIBWData, 'GrayLimits', Param.GrayLimits, 'Offset', Param.Direction(i), 'NumLevels', Param.NumLevels);
        
    GLRLMStruct3(Count).Direction=Param.Direction(i);    
    GLRLMStruct3(Count).GLRLM=GLRLM;
    % GLRLMStruct3(Count).ScaleImage=SI;
    GLRLMStruct3(Count).Nv = nnz(ROIBWData);
    
    Count=Count+1;
end

if isequal(Param.AggregationMethod, 5) || isequal(lower(Param.AggregationMethod), '3dmrg')
    
    %Sum all directions
    dims = [0 0];
    for i = 1:length(GLRLMStruct3)
        dims = max([dims; size(GLRLMStruct3(i).GLRLM)]);
    end
    GLRLM_temp = zeros(dims);
    for i=1:length(GLRLMStruct3)
        temp = GLRLMStruct3(i).GLRLM;
        GLRLM_temp(1:size(temp,1), 1:size(temp,2))=GLRLM_temp(1:size(temp,1), 1:size(temp,2))+temp;
    end
    
    GLRLMStruct3=[];
    GLRLMStruct3.Direction=-333;
    GLRLMStruct3.GLRLM = GLRLM_temp;
    GLRLMStruct3.Nv = nnz(ROIBWData)*length(Param.Direction);
end

function GLRLMstruct2D=ComputeGLRLM2D(ROIImageData, ROIBWData, Param)

if ~(isfield(Param, 'Direction') && isfield(Param, 'GrayLimits') && isfield(Param, 'NumLevels') && isfield(Param, 'Offset') && isfield(Param, 'Symmetric'))
    GLRLMstruct2D=[];
end

N_slice = size(ROIBWData,3);

GLRLMstruct_full.GLRLMStruct2D = [];
for curr_slice = 1:N_slice
    for curr_direction=1:length(Param.Direction)
        
        % Support 13 directions
        [GLRLM, SI] = IBSI_GrayRLMatrix3_Mask(double(ROIImageData(:,:,curr_slice)), ROIBWData(:,:,curr_slice), 'GrayLimits', Param.GrayLimits, 'Offset', Param.Direction(curr_direction), 'NumLevels', Param.NumLevels);
        
        GLRLMstruct_full(curr_slice).GLRLMStruct2D(curr_direction).Direction=Param.Direction(curr_direction);
        GLRLMstruct_full(curr_slice).GLRLMStruct2D(curr_direction).GLRLM=GLRLM;
        GLRLMstruct_full(curr_slice).GLRLMStruct2D(curr_direction).ScaleImage=SI;
        GLRLMstruct_full(curr_slice).GLRLMStruct2D(curr_direction).Nv = nnz(ROIBWData(:,:,curr_slice));
    end
end

if isequal(Param.AggregationMethod, 1) || isequal(lower(Param.AggregationMethod), '2davg')
    
    %Do not merge
    GLRLMstruct2D = [];
    counter = 1;
    for curr_slice = 1:N_slice
        for curr_direction=1:length(Param.Direction)
            GLRLMstruct2D(counter).GLRLM = GLRLMstruct_full(curr_slice).GLRLMStruct2D(curr_direction).GLRLM;
            GLRLMstruct2D(counter).Direction = GLRLMstruct_full(curr_slice).GLRLMStruct2D(curr_direction).Direction;
            GLRLMstruct2D(counter).Nv= GLRLMstruct_full(curr_slice).GLRLMStruct2D(curr_direction).Nv;
            counter = counter+1;
        end
    end
end

if isequal(Param.AggregationMethod, 2) || isequal(lower(Param.AggregationMethod), '2dmrg')
    
    GLRLMstruct2D = [];
    for curr_slice = 1:N_slice
        %Sum all directions, per slice
        dims = [0 0];
        for curr_direction=1:length(Param.Direction)
            dims = max([dims; size(GLRLMstruct_full(curr_slice).GLRLMStruct2D(curr_direction).GLRLM)]);
        end
        
        GLRLM_temp = zeros(dims);
        for curr_direction=1:length(Param.Direction)
            temp = GLRLMstruct_full(curr_slice).GLRLMStruct2D(curr_direction).GLRLM;
            GLRLM_temp(1:size(temp,1), 1:size(temp,2))=GLRLM_temp(1:size(temp,1), 1:size(temp,2))+temp;
        end
        GLRLMstruct2D(curr_slice).Direction=GLRLMstruct_full(curr_slice).GLRLMStruct2D(1).Direction;
        GLRLMstruct2D(curr_slice).GLRLM=GLRLM_temp;
        GLRLMstruct2D(curr_slice).Nv = GLRLMstruct_full(curr_slice).GLRLMStruct2D(1).Nv*length(Param.Direction);
    end
end

if isequal(Param.AggregationMethod, 3) || isequal(lower(Param.AggregationMethod), '2dvmrg')        
    
    GLRLMstruct2D = [];
    
    
    dims = [0 0];
    for curr_slice = 1:N_slice
        for curr_direction=1:length(Param.Direction)
            dims = max([dims; size(GLRLMstruct_full(curr_slice).GLRLMStruct2D(curr_direction).GLRLM)]);
        end
    end
    
    %Sum all direction and slices
    GLRLM_temp = zeros(dims);
    Nv_temp = 0;
    for curr_slice = 1:N_slice
        for curr_direction=1:length(Param.Direction)
            temp = GLRLMstruct_full(curr_slice).GLRLMStruct2D(curr_direction).GLRLM;
            GLRLM_temp(1:size(temp,1), 1:size(temp,2))=GLRLM_temp(1:size(temp,1), 1:size(temp,2))+temp;
            Nv_temp = Nv_temp+GLRLMstruct_full(curr_slice).GLRLMStruct2D(1).Nv;
        end
    end
    GLRLMstruct2D.Direction=-444;
    GLRLMstruct2D.GLRLM=GLRLM_temp;
    GLRLMstruct2D.Nv = Nv_temp;
end

if isequal(Param.AggregationMethod, 6) || isequal(lower(Param.AggregationMethod), '25dmrg')
    
    %Merge Directions over slices
    GLRLMstruct2D = [];
    counter = 1;
    for i=1:length(Param.Direction)
        GLRLM_temp = zeros(size(GLRLMstruct_full(1).GLRLMStruct2D(i).GLRLM));
        Nv_temp = 0;
        for s = 1:size(ROIBWData,3)
            GLRLM_temp = GLRLM_temp+GLRLMstruct_full(s).GLRLMStruct2D(i).GLRLM;
            Nv_temp = Nv_temp+GLRLMstruct_full(s).GLRLMStruct2D(i).Nv;
        end
        GLRLMstruct2D(i).GLRLM = GLRLM_temp;
        GLRLMstruct2D(i).Direction = GLRLMstruct_full(1).GLRLMStruct2D(i).Direction;
        GLRLMstruct2D(i).Nv = Nv_temp;
    end
end
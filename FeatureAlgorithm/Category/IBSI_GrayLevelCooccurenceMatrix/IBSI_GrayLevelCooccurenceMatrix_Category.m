function ParentInfo=IBSI_GrayLevelCooccurenceMatrix_Category(CDataSetInfo, Mode, Param)
%%%Doc Starts%%%
% -Description:
% 1. This method is to compute gray-level co-ccorrence matrix (GLCM) from image inside
%     the binary mask in sing the desired 2D/3D approach in 13 unique directions.
% 2. GLCM is passed into GrayLevelCooccurenceMatrix3_Feature.m to compute the related features.
%
% -Parameters:
% 1. Direction: Define the angle of intensity pair (phi/theta).
%	0: 0/90, 1: 90/90, 2: 45/90, 3: 135/90, 4: 0/0, 5: 90/45, 6: 90/135
%	7: 0/45, 8: 0/135, 9: 45/45, 10: 135/45, 11: 45/135, 12: 135/135
% 2. Offset: The distance between the intensity pair
% 3. AggregationMethod:
%	1: 2D:avg
%	2: 2D:mrg, 3D:smrg
%   6: 2.5D:avg, 2.5D:dmrg
%	3: 2.5D:mrg, 2.5D:vrgm
%	4: 3D:avg
%	5: 3D:mrg
% 4. Rescale:
%	'fbn': fixed bin number -> specify BinNumber
%	'fbs': fixed bin size   -> specify BinSize
%	'off': do not perform the discretization step
% 5. BinNumber: Integer specifying the number of bin number to use when scaling the grayscale values. [] when rescale is set to 'fbs' or 'off';
% 6. BinSize: Integer specifying the bin size to use when scaling the grayscale values. [] when rescale is set to 'fbn' or 'off';
% 7. Symmetric: 0==The pixel order in the pair matters. 1==The pixel order in the pair doesn't matter.
%
% -References:
% 1. Haralick, R.M., K. Shanmugan, and I. Dinstein, "Textural Features for Image Classification",
%      IEEE Transactions on Systems, Man, and Cybernetics, Vol. SMC-3, 1973, pp. 610-621.
% 2. Haralick, R.M., and L.G. Shapiro. Computer and Robot Vision: Vol. 1, Addison-Wesley, 1992, p. 459.
% 3. MATLAB built-in functions: graycomatrix, graycoprops.
% 4. Zwanenburg A, Leger S, Vallières M, Löck S. Image biomarker standardisation initiative.
%      December 2016. http://arxiv.org/abs/1612.07003. Accessed May 21, 2019.
%
% -Revision:
% 2019-07-10: The method is made IBSI compliant.
% 2014-03-05: The method is implemented.
%
% -Authors:
% Joy Zhang, lifzhang@mdanderson.org
% David Fried, DVFried@mdanderson.org
% Xenia Fave, XJFave@mdanderson.org
% Dennis Mackin, DSMackin@mdanderson.org
% Slade Klawikowski, slade@uwalumni.com
%
% Andrea Bettinelli
%%%Doc Ends%%%

% Pinnacle to IBSI
CDataSetInfo = IBSI_waterCTnumber(CDataSetInfo);

% Limiti opzionali (modificano ROI)
[CDataSetInfo, Param] = IBSI_gl_rescale(CDataSetInfo, Param);

%Code
GLCMStruct=ComputeGLCM(CDataSetInfo, Param);

switch Mode
    case 'Review'
        ReviewInfo=CDataSetInfo.ROIImageInfo;
        ReviewInfo.GLCMStruct3=GLCMStruct;
        ParentInfo=ReviewInfo;
        
    case 'Child'
        CDataSetInfo.ROIImageInfo.GLCMStruct3=GLCMStruct;
        CDataSetInfo.AggregationMethod = Param.AggregationMethod;
        ParentInfo=CDataSetInfo;
end

function GLCMStructOut=ComputeGLCM(CDataSetInfo, Param)

if ~(isfield(Param, 'Direction') && isfield(Param, 'NumLevels') && isfield(Param, 'Offset') && isfield(Param, 'Symmetric'))
    GLCMStructOut=[];
end

ROIImageData=CDataSetInfo.ROIImageInfo.MaskData;
ROIBWData=CDataSetInfo.ROIBWInfo.MaskData;

% Remove empty slices above and below ROI
[ROIImageData, ROIBWData] = IBSI_minimal_ROI(ROIImageData, ROIBWData);

if      isequal(Param.AggregationMethod, 4) || isequal(lower(Param.AggregationMethod), '3davg') ||...
        isequal(Param.AggregationMethod, 5) || isequal(lower(Param.AggregationMethod), '3dmrg')
    if length(Param.Direction) > 13
        error('For 3D extraction only 13 direction possible [0 1 2 3 4 5 6 7 8 9 10 11 12]')
    end
    for d=1:length(Param.Direction)
        OffsetMat=Param.Offset';
        switch Param.Direction(d)
            case 0 %'0/90'
                Offset=[1*OffsetMat, 0*OffsetMat, 0*OffsetMat];
            case 1 %'90/90'
                Offset=[0*OffsetMat, 1*OffsetMat, 0*OffsetMat];
            case 2 %'45/90'
                Offset=[1*OffsetMat, 1*OffsetMat, 0*OffsetMat];
            case 3 % '135/90'
                Offset=[-1*OffsetMat, 1*OffsetMat, 0*OffsetMat];
            case 4 % '0/0'
                Offset=[0*OffsetMat, 0*OffsetMat, 1*OffsetMat];
            case 5 %'90/45'
                Offset=[0*OffsetMat, 1*OffsetMat, 1*OffsetMat];
            case 6 %'90/135'
                Offset=[0*OffsetMat, 1*OffsetMat, -1*OffsetMat];
            case 7 %'0/45'
                Offset=[1*OffsetMat, 0*OffsetMat, 1*OffsetMat];
            case 8 %'0/135'
                Offset=[1*OffsetMat, 0*OffsetMat, -1*OffsetMat];
            case 9 %'45/54.7'
                Offset=[1*OffsetMat, 1*OffsetMat, 1*OffsetMat];
            case 10 %'135/54.7'
                Offset=[-1*OffsetMat, 1*OffsetMat, 1*OffsetMat];
            case 11 %'45/125.3'
                Offset=[1*OffsetMat, 1*OffsetMat, -1*OffsetMat];
            case 12 %'135/125.3'
                Offset=[-1*OffsetMat, 1*OffsetMat, -1*OffsetMat];
        end
        
        [GLCM, ~] = IBSI_GrayCoMatrix3_Mask(double(ROIImageData), ROIBWData,'Offset', Offset, 'NumLevels', Param.NumLevels, 'Symmetric', logical(Param.Symmetric));
        
        GLCMStruct3D(d).Direction=Param.Direction(d);
        GLCMStruct3D(d).Offset=OffsetMat;
        GLCMStruct3D(d).GLCM=GLCM;
    end
    
    % [3D:mrg] merged 3D directions
    if isequal(Param.AggregationMethod, 4) || isequal(lower(Param.AggregationMethod), '3davg')
        
        % Do not merge
        GLCMStructOut=GLCMStruct3D;
    end
    
    % [3D:mrg] merged 3D directions
    if isequal(Param.AggregationMethod, 5) || isequal(lower(Param.AggregationMethod), '3dmrg')
        
        % Merge all directions
        GLCMStructOut=GLCMStruct3D(1);
        GLCMStructOut.Direction= -555;
        GLCMStructOut.GLCM=zeros(size(GLCMStruct3D(1).GLCM));
        for i=1:length(GLCMStruct3D)
            GLCMStructOut.GLCM = GLCMStructOut.GLCM+GLCMStruct3D(i).GLCM;
        end
    end
    
else
    if length(Param.Direction) > 4
        error('For 2D extraction only 4 direction possible [0 1 2 3]')
    end
    for s = 1:size(ROIBWData,3)
        for d=1:length(Param.Direction)
            
            OffsetMat=Param.Offset';
            switch Param.Direction(d)
                case 0 %'0/90'
                    Offset=[1*OffsetMat, 0*OffsetMat];
                case 1 %'90/90'
                    Offset=[0*OffsetMat, 1*OffsetMat];
                case 2 %'45/90'
                    Offset=[1*OffsetMat, 1*OffsetMat];
                case 3 % '135/90'
                    Offset=[-1*OffsetMat, 1*OffsetMat];
            end
            [GLCM, ~] = GrayCoMatrix25_Mask(double(ROIImageData(:,:,s)), ROIBWData(:,:,s),'Offset', Offset, 'NumLevels', Param.NumLevels, 'Symmetric', logical(Param.Symmetric));
            
            GLCMStruct2D(s).GLCMStruct2D(d).Direction=Param.Direction(d);
            GLCMStruct2D(s).GLCMStruct2D(d).Offset=OffsetMat;
            GLCMStruct2D(s).GLCMStruct2D(d).GLCM=GLCM;
        end
    end
    
    % [2D:avg] averaged over slices and directions
    if isequal(Param.AggregationMethod, 1) || isequal(lower(Param.AggregationMethod), '2davg')
        
        % Do not merge
        GLCMStructOut = [];
        counter = 1;
        for s = 1:size(ROIBWData,3)
            for d=1:length(Param.Direction)
                GLCMStructOut(counter).GLCM = GLCMStruct2D(s).GLCMStruct2D(d).GLCM;
                GLCMStructOut(counter).Direction = GLCMStruct2D(s).GLCMStruct2D(d).Direction;
                GLCMStructOut(counter).Offset = GLCMStruct2D(s).GLCMStruct2D(d).Offset;
                counter = counter+1;
            end
        end
    end
    
    % [2D:mrg, 2D:smrg] merged directions per slice and averaged
    if isequal(Param.AggregationMethod, 2) || isequal(lower(Param.AggregationMethod), '2dsmrg')
        
        % Merge Directions, by slice
        for s = 1:size(ROIBWData,3)
            GLCM_temp = zeros(size(GLCMStruct2D(1).GLCMStruct2D(1).GLCM));
            for d=1:length(Param.Direction)
                GLCM_temp = GLCMStruct2D(s).GLCMStruct2D(d).GLCM+GLCM_temp;
            end
            GLCMStructOut(s).GLCM = GLCM_temp;
            GLCMStructOut(s).Direction = -222;
            GLCMStructOut(s).Offset = GLCMStruct2D(s).GLCMStruct2D(d).Offset;
        end
    end
    
    % [2.5D:avg, 2.5D:dmrg] merged per direction and averaged
    if isequal(Param.AggregationMethod, 6) || isequal(lower(Param.AggregationMethod), '25ddmrg')
        
        % Merge directions over slices
        GLCMStructOut = [];
        counter = 1;
        for d=1:length(Param.Direction)
            GLCM_temp = zeros(size(GLCMStruct2D(1).GLCMStruct2D(d).GLCM));
            for s = 1:size(ROIBWData,3)
                GLCM_temp = GLCM_temp+GLCMStruct2D(s).GLCMStruct2D(d).GLCM;
            end
            GLCMStructOut(d).GLCM = GLCM_temp;
            GLCMStructOut(d).Direction = GLCMStruct2D(1).GLCMStruct2D(d).Direction;
            GLCMStructOut(d).Offset = GLCMStruct2D(1).GLCMStruct2D(d).Offset;
        end
    end
    
    % [2.5D:mrg, 2.5D:vmrg] merged over all slices
    if isequal(Param.AggregationMethod, 3) || isequal(lower(Param.AggregationMethod), '2dvmrg')
        
        % Merge directions and slices
        GLCM_temp = zeros(size(GLCMStruct2D(1).GLCMStruct2D(1).GLCM));
        for s = 1:size(ROIBWData,3)
            for d=1:length(Param.Direction)
                GLCM_temp = GLCMStruct2D(s).GLCMStruct2D(d).GLCM+GLCM_temp;
            end
        end
        GLCMStructOut.GLCM = GLCM_temp;
        GLCMStructOut.Direction = -333;
        GLCMStructOut.Offset = GLCMStruct2D(s).GLCMStruct2D(d).Offset;
    end
    
end

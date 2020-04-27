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
%	2: 2D:mrg
%	3: 2D:vmrg
%	4: 3D:avg
%	5: 3D:mrg
%	6: 25D:dmrg
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
        ParentInfo=CDataSetInfo;
end

function GLCMStruct3=ComputeGLCM(CDataSetInfo, Param)

if ~(isfield(Param, 'Direction') && isfield(Param, 'NumLevels') && isfield(Param, 'Offset') && isfield(Param, 'Symmetric'))
    GLCMStruct3=[];
end

ROIImageData=CDataSetInfo.ROIImageInfo.MaskData;
ROIBWData=CDataSetInfo.ROIBWInfo.MaskData;

% Remove empty slices above and below ROI
[ROIImageData, ROIBWData] = IBSI_minimal_ROI(ROIImageData, ROIBWData);

if isequal(Param.AggregationMethod, 5) || isequal(lower(Param.AggregationMethod), '3dmrg') || isequal(Param.AggregationMethod, 4) || isequal(lower(Param.AggregationMethod), '3davg')
    for i=1:length(Param.Direction)
        OffsetMat=Param.Offset';
        switch Param.Direction(i)
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

        [GLCM, SI] = IBSI_GrayCoMatrix3_Mask(double(ROIImageData), ROIBWData,'Offset', Offset, 'NumLevels', Param.NumLevels, 'Symmetric', logical(Param.Symmetric));
        
        GLCMStruct3(i).Direction=Param.Direction(i);
        GLCMStruct3(i).Offset=OffsetMat;
        GLCMStruct3(i).GLCM=GLCM;
        %GLCMStruct3(i).ScaleImage=SI;
    end
else
    for s = 1:size(ROIBWData,3)
        for i=1:length(Param.Direction)
            
            OffsetMat=Param.Offset';
            switch Param.Direction(i)
                case 0 %'0/90'
                    Offset=[1*OffsetMat, 0*OffsetMat];
                case 1 %'90/90'
                    Offset=[0*OffsetMat, 1*OffsetMat];
                case 2 %'45/90'
                    Offset=[1*OffsetMat, 1*OffsetMat];
                case 3 % '135/90'
                    Offset=[-1*OffsetMat, 1*OffsetMat];
            end
            [GLCM, SI] = GrayCoMatrix25_Mask(double(ROIImageData(:,:,s)), ROIBWData(:,:,s),'Offset', Offset, 'NumLevels', Param.NumLevels, 'Symmetric', logical(Param.Symmetric));
            
            GLCMStruct_full(s).GLCMStruct2D(i).Direction=Param.Direction(i);
            GLCMStruct_full(s).GLCMStruct2D(i).Offset=OffsetMat;
            GLCMStruct_full(s).GLCMStruct2D(i).GLCM=GLCM;
        end
    end
end

if isequal(Param.AggregationMethod, 5) || isequal(lower(Param.AggregationMethod), '3dmrg')
    
    %Sum all directions
    SumGLCMStruct=GLCMStruct3(1);
    SumGLCMStruct.Direction= -333;
    SumGLCMStruct.GLCM=zeros(size(GLCMStruct3(1).GLCM));
    for i=1:length(GLCMStruct3)
        SumGLCMStruct.GLCM = SumGLCMStruct.GLCM+GLCMStruct3(i).GLCM;
    end
    GLCMStruct3=SumGLCMStruct;

end

if isequal(Param.AggregationMethod, 1) || isequal(lower(Param.AggregationMethod), '2davg')
    
    %Do not merge
    GLCMStruct3 = [];
    counter = 1;
    for s = 1:size(ROIBWData,3)
        for i=1:length(Param.Direction)
            GLCMStruct3(counter).GLCM = GLCMStruct_full(s).GLCMStruct2D(i).GLCM;
            GLCMStruct3(counter).Direction = GLCMStruct_full(s).GLCMStruct2D(i).Direction;
            GLCMStruct3(counter).Offset = GLCMStruct_full(s).GLCMStruct2D(i).Offset;
            counter = counter+1;
        end
    end
end

if isequal(Param.AggregationMethod, 2) || isequal(lower(Param.AggregationMethod), '2dmrg')
    
    for s = 1:size(ROIBWData,3)
        
        %Merge Directions, by slice
        GLCM_temp = zeros(size(GLCMStruct_full(1).GLCMStruct2D(1).GLCM));
        for i=1:length(Param.Direction)
            GLCM_temp = GLCMStruct_full(s).GLCMStruct2D(i).GLCM+GLCM_temp;
        end
        GLCMStruct3(s).GLCM = GLCM_temp;
        GLCMStruct3(s).Direction = -333;
        GLCMStruct3(s).Offset = GLCMStruct_full(s).GLCMStruct2D(i).Offset;
    end
end

if isequal(Param.AggregationMethod, 3) || isequal(lower(Param.AggregationMethod), '2dvmrg')
    
    %Merge Directions and slices
    GLCM_temp = zeros(size(GLCMStruct_full(1).GLCMStruct2D(1).GLCM));
    for s = 1:size(ROIBWData,3)
        for i=1:length(Param.Direction)
            GLCM_temp = GLCMStruct_full(s).GLCMStruct2D(i).GLCM+GLCM_temp;
        end
    end
    GLCMStruct3.GLCM = GLCM_temp;
    GLCMStruct3.Direction = -333;
    GLCMStruct3.Offset = GLCMStruct_full(s).GLCMStruct2D(i).Offset;
end

if isequal(Param.AggregationMethod, 6) || isequal(lower(Param.AggregationMethod), '25dmrg')
    
    %Merge Directions over slices
    GLCMStruct3 = [];
    counter = 1;
    for i=1:length(Param.Direction)
        GLCM_temp = zeros(size(GLCMStruct_full(1).GLCMStruct2D(i).GLCM));
        for s = 1:size(ROIBWData,3)
            GLCM_temp = GLCM_temp+GLCMStruct_full(s).GLCMStruct2D(i).GLCM;
        end
        GLCMStruct3(i).GLCM = GLCM_temp;
        GLCMStruct3(i).Direction = GLCMStruct_full(1).GLCMStruct2D(i).Direction;
        GLCMStruct3(i).Offset = GLCMStruct_full(1).GLCMStruct2D(i).Offset;
    end
end
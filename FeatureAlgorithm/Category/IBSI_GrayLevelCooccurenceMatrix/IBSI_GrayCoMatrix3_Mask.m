function [GLCMS,SI] = IBSI_GrayCoMatrix3_Mask(varargin)
%GRAYCOMATRIX Create gray-level co-occurrence matrix.
%   GLCMS = GRAYCOMATRIX(I) analyzes pairs of horizontally adjacent pixels
%   in a scaled version of I.  If I is a binary image, it is scaled to 2
%   levels. If I is an intensity image, it is scaled to 8 levels. In this
%   case, there are 8 x 8 = 64 possible ordered combinations of values for
%   each pixel pair. GRAYCOMATRIX accumulates the total occurrence of each
%   such combination, producing a 8-by-8 output array, GLCMS. The row and
%   column subscripts in GLCMS correspond respectively to the first and
%   second (scaled) pixel-pair values.
%
%   GLCMS = GRAYCOMATRIX(I,PARAM1,VALUE1,PARAM2,VALUE2,...) returns one or
%   more gray-level co-occurrence matrices, depending on the values of the
%   optional parameter/value pairs. Parameter names can be abbreviated, and
%   case does not matter.
%
%   Parameters include:
%
%   'Offset'         A p-by-2 array of offsets specifying the distance
%                    between the pixel-of-interest and its neighbor. Each
%                    row in the array is a two-element vector,
%                    [ROW_OFFSET COL_OFFSET], that specifies the
%                    relationship, or 'Offset', between a pair of pixels.
%                    ROW_OFFSET is the number of rows between the
%                    pixel-of-interest and its neighbor.  COL_OFFSET is the
%                    number of columns between the pixel-of-interest and
%                    its neighbor. For example, if you want the number of
%                    occurrences where the pixel of interest is one pixel
%                    to the left of its neighbor, then
%                    [ROW_OFFSET COL_OFFSET] is [0 1].
%
%                    Because this offset is often expressed as an angle,
%                    the following table lists the offset values that
%                    specify common angles, given the pixel distance D.
%
%                    Angle     OFFSET
%                    -----     ------
%                    0         [0 D]
%                    45        [-D D]
%                    90        [-D 0]
%                    135       [-D -D]
%
%                    ROW_OFFSET and COL_OFFSET must be integers.
%
%                    Default: [0 1]
%
%   'NumLevels'      An integer specifying the number of gray levels to use
%                    when scaling the grayscale values in I. For example,
%                    if 'NumLevels' is 8, GRAYCOMATRIX scales the values in
%                    I so they are integers between 1 and 8.  The number of
%                    gray levels determines the size of the gray-level
%                    co-occurrence matrix (GLCM).
%
%                    'NumLevels' must be an integer. 'NumLevels' must be 2
%                    if I is logical.
%
%                    Default: 8 for numeric
%                             2 for logical
%
%   'GrayLimits'     A two-element vector, [LOW HIGH], that specifies how
%                    the grayscale values in I are linearly scaled into
%                    gray levels. Grayscale values less than or equal to
%                    LOW are scaled to 1. Grayscale values greater than or
%                    equal to HIGH are scaled to HIGH.  If 'GrayLimits' is
%                    set to [], GRAYCOMATRIX uses the minimum and maximum
%                    grayscale values in I as limits,
%                    [min(I(:)) max(I(:))].
%
%                    Default: the LOW and HIGH values specified by the
%                    class, e.g., [LOW HIGH] is [0 1] if I is double and
%                    [-32768 32767] if I is int16.
%
%   'Symmetric'      A Boolean that creates a GLCM where the ordering of
%                    values in the pixel pairs is not considered. For
%                    example, when calculating the number of times the
%                    value 1 is adjacent to the value 2, GRAYCOMATRIX
%                    counts both 1,2 and 2,1 pairings, if 'Symmetric' is
%                    set to true. When 'Symmetric' is set to false,
%                    GRAYCOMATRIX only counts 1,2 or 2,1, depending on the
%                    value of 'offset'. The GLCM created in this way is
%                    symmetric across its diagonal, and is equivalent to
%                    the GLCM described by Haralick (1973).
%
%                    The GLCM produced by the following syntax,
%
%                    graycomatrix(I, 'offset', [0 1], 'Symmetric', true)
%
%                    is equivalent to the sum of the two GLCMs produced by
%                    these statements.
%
%                    graycomatrix(I, 'offset', [0 1], 'Symmetric', false)
%                    graycomatrix(I, 'offset', [0 -1], 'Symmetric', false)
%
%                    Default: false
%
%
%   [GLCMS,SI] = GRAYCOMATRIX(...) returns the scaled image used to
%   calculate GLCM. The values in SI are between 1 and 'NumLevels'.
%
%   Class Support
%   -------------
%   I can be numeric or logical.  I must be 2D, real, and nonsparse. SI is
%   a double matrix having the same size as I.  GLCMS is an
%   'NumLevels'-by-'NumLevels'-by-P double array where P is the number of
%   offsets in OFFSET.
%
%   Notes
%   -----
%   Another name for a gray-level co-occurrence matrix is a gray-level
%   spatial dependence matrix.
%
%   GRAYCOMATRIX ignores pixels pairs if either of their values is NaN. It
%   also replaces Inf with the value 'NumLevels' and -Inf with the value 1.
%
%   GRAYCOMATRIX ignores border pixels, if the corresponding neighbors
%   defined by 'Offset' fall outside the image boundaries.
%
%   References
%   ----------
%   Haralick, R.M., K. Shanmugan, and I. Dinstein, "Textural Features for
%   Image Classification", IEEE Transactions on Systems, Man, and
%   Cybernetics, Vol. SMC-3, 1973, pp. 610-621.
%
%   Haralick, R.M., and L.G. Shapiro. Computer and Robot Vision: Vol. 1,
%   Addison-Wesley, 1992, p. 459.
%
%   Example 1
%   ---------
%   Calculate the gray-level co-occurrence matrix (GLCM) and return the
%   scaled version of the image, SI, used by GRAYCOMATRIX to generate the
%   GLCM.
%
%        I = [1 1 5 6 8 8;2 3 5 7 0 2; 0 2 3 5 6 7];
%       [GLCMS,SI] = graycomatrix(I,'NumLevels',9,'G',[])
%
%   Example 2
%   ---------
%   Calculate the gray-level co-occurrence matrix for a grayscale image.
%
%       I = imread('circuit.tif');
%       GLCMS = graycomatrix(I,'Offset',[2 0])
%
%   Example 3
%   ---------
%   Calculate gray-level co-occurrences matrices for a grayscale image
%   using four different offsets.
%
%       I = imread('cell.tif');
%       offsets = [0 1;-1 1;-1 0;-1 -1];
%       [GLCMS,SI] = graycomatrix(I,'Of',offsets);
%
%   Example 4
%   ---------
%   Calculate the symmetric gray-level co-occurrence matrix (the Haralick
%   definition) for a grayscale image.
%
%       I = imread('circuit.tif');
%       GLCMS = graycomatrix(I,'Offset',[2 0],'Symmetric', true)
%
%   See also GRAYCOPROPS.

%   Copyright 1993-2010 The MathWorks, Inc.
%   $Revision: 1.1.8.5 $  $Date: 2010/10/11 14:46:51 $


[I, Mask, Offset, NL, makeSymmetric] = ParseInputs(varargin{:});

SI = round(I);

% Clip values if user had a value that is outside of the range, e.g.,
% double image = [0 .5 2;0 1 1]; 2 is outside of [0,1]. The order of the
% following lines matters in the event that NL = 0.
SI(SI > NL) = NL;
SI(SI < 1) = 1;

SI(Mask==0)=NaN;

numOffsets = size(Offset,1);

if NL ~= 0
    
    % Create vectors of row and column subscripts for every pixel and its
    % neighbor.
    s = size(I);
    if length(s) == 3
        [r,c,z] = meshgrid(1:s(1),1:s(2),1:s(3));
    elseif length(s) == 2 % In case one slice
        [r,c,z] = meshgrid(1:s(1),1:s(2),1);
    end
    r = r(:);
    c = c(:);
    z = z(:);
    
    % Compute GLCMS
    GLCMS = zeros(NL,NL,numOffsets);
    for k = 1 : numOffsets
        GLCMS(:,:,k) = computeGLCM(r, c, z, Offset(k,:), SI,NL);
        
        if makeSymmetric
            % Reflect glcm across the diagonal
            glcmTranspose = GLCMS(:,:,k).';
            GLCMS(:,:,k) = GLCMS(:,:,k) + glcmTranspose;
        end
    end
    
else
    GLCMS = zeros(0,0,numOffsets);
end

%-----------------------------------------------------------------------------
function oneGLCM = computeGLCM(r, c, z, offset, si, nl)
% computes GLCM given one Offset

r2 = r + offset(1);
c2 = c + offset(2);
z2 = z + offset(3);

[nR nC nZ] = size(si);

%Determine locations where subscripts outside the image boundary
outsideBounds = find(z2 < 1 | z2 > nZ | c2 < 1 | c2 > nC | r2 < 1 | r2 > nR);

% outsideBoundsMask=find(Mask < 1);
% outsideBounds=[outsideBounds; outsideBoundsMask];

%Create vector containing si(r1,c1,z1)
index = r + (c-1)*nR + (z-1)*nR*nC;
v1 = si(index);
v1(outsideBounds) = [];

%Create vector containing si(r2,c2,z2). Not using sub2ind for performance reasons
r2(outsideBounds) = [];
c2(outsideBounds) = [];
z2(outsideBounds) = [];

index = r2 + (c2-1)*nR + (z2-1)*nR*nC;
v2 = si(index);

bad = isnan(v1) | isnan(v2);
ind = [v1 v2];
ind(bad,:) = [];

if isempty(ind)
    oneGLCM = zeros(nl);
else
    %Tabulate the occurrences of pixel pairs having v1 and v2.
    oneGLCM = accumarray(ind, 1, [nl nl]);
end


%-----------------------------------------------------------------------------
function [I, Mask, offset, nl, sym] = ParseInputs(varargin)
% function [I, Mask, offset, nl, gl, sym] = ParseInputs(varargin)

narginchk(1, 10);

% Check I
I = varargin{1};
validateattributes(I,{'logical','numeric'},{'real','nonsparse'}, ...
    mfilename,'I',1);

Mask = varargin{2};

% Assign Defaults
offset = [0 1];
if islogical(I)
    nl = 2;
else
    nl = 8;
end
% gl = getrangefromclass(I);
sym = false;

% Parse Input Arguments
if nargin ~= 1
    
    paramStrings = {'Offset','NumLevels','GrayLimits','Symmetric'};
    
    for k = 3:2:nargin
        
        param = lower(varargin{k});
        inputStr = validatestring(param, paramStrings, mfilename, 'PARAM', k);
        idx = k + 1;  %Advance index to the VALUE portion of the input.
        if idx > nargin
            eid = sprintf('Images:%s:missingParameterValue', mfilename);
            error(eid,'Parameter ''%s'' must be followed by a value.', inputStr);
        end
        
        switch (inputStr)
            
            case 'Offset'
                
                offset = varargin{idx};
                validateattributes(offset,{'logical','numeric'},...
                    {'nonempty','integer','real'},...
                    mfilename, 'OFFSET', idx);
                if size(offset,2)  >  3
                    eid = sprintf('Images:%s:invalidOffsetSize',mfilename);
                    error(eid, 'OFFSET must be an N-by-3 array.');
                end
                offset = double(offset);
                
            case 'NumLevels'
                
                nl = varargin{idx};
                validateattributes(nl,{'logical','numeric'},...
                    {'real','integer','nonnegative','nonempty','nonsparse'},...
                    mfilename, 'NL', idx);
                if numel(nl) > 1
                    eid = sprintf('Images:%s:invalidNumLevels',mfilename);
                    error(eid, 'NL cannot contain more than one element.');
                elseif islogical(I) && nl ~= 2
                    eid = sprintf('Images:%s:invalidNumLevelsForBinary',mfilename);
                    error(eid, 'NL must be two for a binary image.');
                end
                nl = double(nl);
                
            case 'Symmetric'
                sym = varargin{idx};
                validateattributes(sym,{'logical'}, {'scalar'}, mfilename, 'Symmetric', idx);
                
        end
    end
end
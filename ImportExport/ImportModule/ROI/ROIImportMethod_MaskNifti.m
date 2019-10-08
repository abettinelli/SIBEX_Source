function structAxialROI=ROIImportMethod_MaskNifti(FileName, ImageDataInfo)

%Import
try
   
    [DataOut, Pixdim, Rotate, DataType] = ReadNifti(FileName);
    
    %Sanity Check 1
    if ~isempty(DataOut) && isequal(DataType, 'uint8')
        
        MaskMat=DataOut(:, :, :, 1);
        
        MaskMat=flipdim(MaskMat, 3);
        
        %Sanity Check 2
        MaskSize=size(MaskMat);
        if MaskSize(1) == ImageDataInfo.YDim && MaskSize(2) == ImageDataInfo.XDim && MaskSize(3) == ImageDataInfo.ZDim
            MaskMat=uint8(MaskMat);            
            
            %Import ROI
            structAxialROI=GenerateStructAxialROI(MaskMat, ImageDataInfo);
        else
            structAxialROI=[];
        end
    else
        structAxialROI=[];
    end
    
catch
     structAxialROI=[];
end
 
function   structAxialROI=GenerateStructAxialROI(MaskMat, ImageDataInfo)

TempIndex=find(MaskMat);
[RowIndex, ColIndex, PageIndex]=ind2sub(size(MaskMat), TempIndex);

MinPage=min(PageIndex);
MaxPage=max(PageIndex);

ZLocation=[]; CurvesCor={[]};
for i=MinPage:MaxPage
    BWSlice=MaskMat(:, :, i);
    BWSlice=flipud(BWSlice);
    
    CurveContour = bwboundaries(BWSlice);
    
    if ~isempty(CurveContour)        
        
        for kk=1:length(CurveContour)
            SubSliceContour=CurveContour{kk};
            
            if length(SubSliceContour) >=5              
                
                YCor=floor(SubSliceContour(:, 1)); XCor=floor(SubSliceContour(:, 2));
                
                XCor2=ImageDataInfo.XStart+(XCor-1)*ImageDataInfo.XPixDim;
                YCor2=ImageDataInfo.YStart+(YCor-1)*ImageDataInfo.YPixDim;
                
                CurvesCor=[CurvesCor; {[XCor2, YCor2]}];
                ZLocation=[ZLocation; ImageDataInfo.ZStart+(i-1)*ImageDataInfo.ZPixDim];
            end
        end        
    end
end
CurvesCor(1)=[];

structAxialROI(1).name='ROINii';
structAxialROI(1).OrganCurveNum=length(ZLocation);
structAxialROI(1).ZLocation=ZLocation;
structAxialROI(1).CurvesCor=CurvesCor;
structAxialROI(1).Color='red';


function [out,pixdim,rotate,dtype] = ReadNifti(filename,volnum)

% READNIFTI  - Read MRI files in the NIFTI format
%
%    usage: 
%            [data,pixdim,orient,dtype] = readnifti(filename);
%            [data,pixdim,orient,dtype] = readnifti(filename,volumenum);
%
%        filename - is the name of a file in NIFTI format. 
%                   (filename can include the .nii, .hdr, or .img
%                   extensions or just the base filename. If base
%                   filename is used then the file is assumed to have
%                   the .nii extension.)
%       volumenum - loads a specific volume from a 4D dataset
%
%            data - is a n-dimensional matrix of the data
%          pixdim - is the size of each voxel (mm)
%          orient - is a structure containing the qform and sform
%                   matrices.
%           dtype - is the datatype of the file (ie 'uint8', 'int16', etc)
%

% Written by Colin Humphries, 2005

%Initialize
out=[];
pixdim=[];
rotate=[];
dtype=[];

% %%%% User parameters %%%%%%%%%%%%%%%%%%%%%
RESHAPE_DATA = 1; % When this flag is set to 1 the data is reshaped into
                  % an n-dimensional matrix. Otherwise readnifti will
                  % just output a vector. 
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if nargin < 2
  volnum = [];
end

% Get rid of possible file extensions and figure out if we are dealing
% with a NIFTI .nii file or a NIFTI .img/.hdr file
ind = findstr(filename,'.gz');
if ~isempty(ind)
  filename = filename(1:ind-1);
  gzipped = 1;
  
  %error('Currently cannot open gzipped data files');
  return;
end
ind = findstr(filename,'.nii');
if ~isempty(ind)
  filename = filename(1:ind-1);
  filenametype = 'nii';
else
  ind = findstr(filename,'.img');
  if ~isempty(ind)
    filename = filename(1:ind-1);
    filenametype = 'img';
  else
    ind = findstr(filename,'.hdr');
    if ~isempty(ind)
      filename = filename(1:ind-1);
      filenametype = 'img';
    else
      filenametype = 'nii';
    end
  end
end

% Read header information
fileinfo = readniftiheader(filename,filenametype);
if isempty(fileinfo)
    return;
end

% Open Data File
if isempty(filenametype)    
    % error('not implemented yet');    
    return;
else
  if strcmp(filenametype,'img')
    fid = fopen([filename,'.img'],'r',fileinfo.byteswap);
    if fid < 0
        
        %error('Error opening image file');        
        return;
    end
  else
    fid = fopen([filename,'.nii'],'r',fileinfo.byteswap);
    if fid < 0
      %error('Error opening image file');      
      return;
    end
    fseek(fid,fileinfo.voxoffset,'bof');
  end
end

% Convert to matlab datatypes
switch fileinfo.datatype
  case 2
    dtype = 'uint8';
  case 4
    dtype = 'int16';
  case 8
    dtype = 'int32';
  case 16
    dtype = 'float';
  case 64
    dtype = 'double';
  case 132
    dtype = 'int16';
  otherwise
    %error('Unsupported datatype');
    return;
end
dimension = fileinfo.dimension;

% Read binary data
if isempty(volnum)
  out = fread(fid,inf,dtype);
else
  switch fileinfo.datatype
   case 2
    fseek(fid,(volnum-1)*prod(dimension(2:4)),'cof');
   case 4
    fseek(fid,2*(volnum-1)*prod(dimension(2:4)),'cof');
   case 8
    fseek(fid,4*(volnum-1)*prod(dimension(2:4)),'cof');
   case 16
    fseek(fid,4*(volnum-1)*prod(dimension(2:4)),'cof');
   case 64
    fseek(fid,8*(volnum-1)*prod(dimension(2:4)),'cof');
   case 132
    fseek(fid,2*(volnum-1)*prod(dimension(2:4)),'cof');
   otherwise
    %error('Unsupported datatype');
    return;
  end
  % dimension
  out = fread(fid,prod(dimension(2:4)),dtype);
  RESHAPE_DATA = 0;
end
% Close data file
fclose(fid);

if RESHAPE_DATA
    % Reshape data
    switch dimension(1)
        case 4
            % 4-dimensional data
            if dimension(5) == 1
                out = reshape(out,dimension(2),dimension(3),dimension(4));
                % %%%%%%%%%%%%%%%%%%%
            else
                out = reshape(out,dimension(2),dimension(3),dimension(4), ...
                    dimension(5));
            end
        case 3
            % 3-dimensional data
            out = reshape(out,dimension(2),dimension(3),dimension(4));
            % %%%%%%%%%%%%%%%%%%%
        case 2
            % 2-dimensional data
            out = reshape(out,dimension(2),dimension(3));
        case 1
            % 1-d data
        otherwise
            %printf('Warning: data not reshaped\n');            
    end
end

pixdim = fileinfo.pixdim(2:(dimension(1)+1));
rotate = struct('qfac',fileinfo.pixdim(1),...
                'qform',fileinfo.formcodes(1),...
                'qmatrix',fileinfo.qmatrix,...
                'sform',fileinfo.formcodes(2),...
                'smatrix',fileinfo.smatrix);

%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%

function [fileinfo] = readniftiheader(filename,filenametype)
% Open Header
%    filename is the name of the file
%    filenametype is either 'img' or 'nii'
%
fileinfo=[]; 
if isempty(filenametype)
  %error('not implemented yet');
  return;
else
  if strcmp(filenametype,'img')
    fid = fopen([filename,'.hdr'],'r');
    if fid < 0
      %error('Error opening header file');
      return;
    end
  else
    fid = fopen([filename,'.nii'],'r');
    if fid < 0
      %error('Error opening header file');
      return;
    end
  end
end

fseek(fid,40,'bof');
dimension = fread(fid,8,'int16');
byteswap = 'n';

% The next part tries to figure out if we have a byte swapping problem by
% looking at the dimension bit in the header file. If it's bigger than 10
% (we probably aren't dealing with more than 10-dimensional data) then it
% tries byte swapping. If it still fails then it outputs an error.
% dimension
if (dimension(1) > 10)
  byteswap = 'b';
  fclose(fid);
  if isempty(filenametype)
    %error('not implemented yet');
    return;
  else
    if strcmp(filenametype,'img')
      fid = fopen([filename,'.hdr'],'r',byteswap);
      if fid < 0
        %error('Error opening header file');
        return;
      end
    else
      fid = fopen([filename,'.nii'],'r',byteswap);
      if fid < 0
        %error('Error opening header file');
        return;
      end
    end
  end
  fseek(fid,40,'bof');
  dimension = fread(fid,8,'int16');
  if (dimension(1) > 10)
    byteswap = 'l';
    fclose(fid);
    if isempty(filenametype)
      %error('not implemented yet');
      return;
    else
      if strcmp(filenametype,'img')
        fid = fopen([filename,'.hdr'],'r',byteswap);
        if fid < 0
          %error('Error opening header file');
          return;
        end
      else
        fid = fopen([filename,'.nii'],'r',byteswap);
        if fid < 0
          %error('Error opening header file');
          return;
        end
      end
    end
    fseek(fid,40,'bof');
    dimension = fread(fid,8,'int16');
    if (dimension(1) > 10)
      fclose(fid);
      %error('Error opening file. Dimension argument is not valid');
      return;
    end
  end
end

% Read information from header file
% Note: there is information in the header that is not currently read
% like the intent codes.

% datatype
fseek(fid,40+30,'bof');
datatype = fread(fid,1,'int16');

% pixel dimension
fseek(fid,40+36,'bof');
pixdim = fread(fid,8,'float');

% bits per pixel
fseek(fid,40+32,'bof');
bitpix = fread(fid,1,'int16');

% data offset
fseek(fid,108,'bof');
voxoffset = fread(fid,1,'float');

% orientation 
fseek(fid,252,'bof');
formcodes = fread(fid,2,'int16');
fseek(fid,256,'bof');
qmatrix = fread(fid,6,'float');
fseek(fid,280,'bof');
smatrix = fread(fid,12,'float');

% Close header file
fclose(fid);

fileinfo = struct('dimension',dimension,...
                  'pixdim',pixdim,...
                  'datatype',datatype,...
                  'bitpix',bitpix,...
                  'voxoffset',voxoffset,...
                  'byteswap',byteswap,...
                  'formcodes',formcodes,...
                  'qmatrix',qmatrix,...
                  'smatrix',smatrix);
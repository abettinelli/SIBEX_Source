function out = cast(in, datatype, varargin)
%CAST Convert datatypes, expanding and shrinking size of matrices.
%   Y = CAST(X, DATATYPE) convert X to DATATYPE.  If DATATYPE has fewer
%   bits than the class of X, Y will have more elements than X.  If
%   DATATYPE has more bits than the class of X, Y will have fewer
%   elements than X.
%
%   Y = CAST(X, DATATYPE, SWAP) convert X to DATATYPE and perform byte
%   swapping on the result.  If SWAP is nonzero, the result will be
%   swapped.
%
%   Note: DATATYPE must be one of 'UINT8', 'INT8', 'UINT16', 'INT16',
%   'UINT32', 'INT32', 'SINGLE', or 'DOUBLE'.
%
%   Note: If X contains fewer values than are needed to make an output
%   value, the last elements of X will not be used.
%
%   Example:
%
%      X = uint32([1 2 3]);
%      Y = cast(X, 'uint8');
%
%   On little-endian architectures Y will be
%
%      [1   0   0   0   2   0   0   0   3   0   0   0]
%
%      Z = cast(X, 'uint8', 1);
%
%   On little-endian architectures Z will be
%
%      [0   0   0   1   0   0   0   2   0   0   0   3]
%
%   See also CLASS.

%   Copyright 1993-2003 The MathWorks, Inc.
%   $Revision: 1.2.4.4 $  $Date: 2004/08/10 01:44:30 $

error(nargchk(2, 3, nargin, 'struct'))

if ((nargin == 2) || (isequal(varargin{1}, 0)))
    
  out = castc(in, datatype);
    
else
  
  if (~isempty(strfind(lower(datatype), 'int8')))

    out = swapToBytes(in, datatype);
    
  elseif ((isequal(class(in), 'uint8')) || ...
          (isequal(class(in), 'int8')))

    out = swapFromBytes(in, datatype);
    
  elseif (isequal(getNumBytes(class(in)), getNumBytes(datatype)))
    
    out = swapBetweenBytes(in, datatype);
    
  else
    
    eid = sprintf('Images:%s:byteSwapNotSupported',mfilename);
    error(eid,'%s%s', ...
          'Byte swapping is possible between similar types', ...
          ' or to/from INT8 and UINT8.')

  end
    
  % Reshape the data to the same orientation as the input.
  if (size(in, 1) ~= 1)
    out = reshape(out, [numel(out) 1]);
  else
    out = reshape(out, [1 numel(out)]);
  end
    
end



function out = swapToBytes(in, datatype)

% Find out how big an input element is.
numbytes = getNumBytes(class(in));

% Cast the data to bytes then rearrange it.
tmp = castc(in, datatype);
tmp = reshape(tmp, numbytes, []);
out = flipud(tmp);



function out = swapFromBytes(in, datatype)

% Find out how big an output element is.
numbytes = getNumBytes(datatype);

if (rem(numel(in), getNumBytes(datatype)) ~= 0)
  
  eid = sprintf('Images:%s:notEnoughBytesToSwap',mfilename);
  error(eid, '%s', 'Too few bytes to swap and convert data.')
  
end

% Rearrange the data, then cast it.
tmp = reshape(in, numbytes, []);
tmp = flipud(tmp);
out = castc(tmp(:), datatype);



function out = swapBetweenBytes(in, datatype)

% Find out how big an element is.
numbytes = getNumBytes(datatype);

% Cast the data to bytes, rearrange it, then cast it the output type.
tmp = castc(in, 'uint8');
tmp = reshape(tmp, numbytes, []);
tmp = flipud(tmp);
out = castc(tmp(:), datatype);



function numbytes = getNumBytes(datatype)

switch (lower(datatype))
case {'uint8', 'int8'}
  numbytes = 1;
  
case {'uint16', 'int16'}
  numbytes = 2;
  
case {'uint32', 'int32', 'single'}
  numbytes = 4;
  
case {'uint64', 'int64', 'double'}
  numbytes = 8;
  
otherwise
  
  eid = sprintf('Images:%s:invalidOutputType', mfilename);
  error(eid, 'Invalid output format "%s"', datatype)
  
end

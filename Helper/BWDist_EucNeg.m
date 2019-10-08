function varargout = bwdist(varargin)
%BWDIST Distance transform.


% Computing the nearest-neighbor transform is expensive in memory, so we
% only want to call the lower-level functions eucdist2, eucdistn, and
% ddist with two output arguments if we have been called with two output
% arguments.
if nargout == 1
    varargout = cell(1,1);
end

if nargout == 2
    varargout = cell(1,1);
    varargout = cell(1,2);
end

if nargout == 3
    varargout = cell(1,1);
    varargout = cell(1,2);
    varargout = cell(1,3);
end


BW1=varargin{1};
BW2=varargin{2};
UnitLen=varargin{3};

% Use a really fast method for 2-D Euclidean distance transforms, or
% a reasonably fast kd-tree based method for multidimensional
% Euclidean distance transforms.
[varargout{:}] = eucdistn(BW1, BW2, UnitLen);




%----------eucdistn
function [dist, L, bg_subs] = eucdistn(BW1, BW2, UnitLen)
%EUCDISTN N-D Euclidean distance transform.
%   D = EUCDISTN(BW) computes the Euclidean distance transform on the input 
%   binary image BW, which can have any dimension.  Specifically, it
%   computes the distance to the nearest nonzero-valued pixel.
%    
%   [D,L] = EUCDIST2(BW) returns a linear index array L representing a
%   nearest-neighbor transform.
%
%   See also BWDIST.

%   Copyright 1993-2003 The MathWorks, Inc.
%   $Revision: 1.4.4.1 $  $Date: 2003/01/26 05:59:27 $

% L is a double-precision array with the same size as BW and D, so only
% compute it if the caller asked for it.
do_labels = 0;

size_BW = size(BW1);

% Optimization: zero-valued elements of BW can be closest only to
% one-valued elements that belong to the perimeter of BW.  By reducing
% the number of one-valued points to be searched, we can cut down on the
% search time.
% perim = bwperim(BW1,conndef(ndims(BW1),'maximal'));
perim = bwperim(BW1);

% Find the locations of the perimeter pixels and convert that into an
% M-by-N array perim_subs containing the locations of M points in
% N-space.
perim_idx = find(perim);
perim_subs = cell(1,ndims(BW1));
[perim_subs{:}] = ind2sub(size_BW, perim_idx);
perim_subs = [perim_subs{:}];

% Find the locations of the zero-valued pixels and convert that into a
% P-by-N array bg_subs containing the the locations of P points in
% N-space.

% perim = bwperim(BW2,conndef(ndims(BW2),'maximal'));
perim = bwperim(BW2);

% Find the locations of the perimeter pixels and convert that into an
% M-by-N array perim_subs containing the locations of M points in
% N-space.
bg_idx = find(perim);
bg_subs = cell(1,ndims(BW2));
[bg_subs{:}] = ind2sub(size_BW, bg_idx);
bg_subs = [bg_subs{:}];


% From perim_subs, construct an optimized k-d tree with a bucket size of
% 25.
tree = BWDist_kdtree(perim_subs,25);

% Using the k-d tree, find the closest one-valued pixel for each
% zero-valued pixel.
[dist, idx] = BWDist_nnsearch_RealNeg(tree, perim_subs', bg_subs', UnitLen);

L=idx;


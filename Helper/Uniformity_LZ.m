function UniformityValue=Uniformity_LZ(Data, BinLoc)
Data=double(Data(:));

%histogram
[p, BinCenter] = hist(Data, BinLoc);

% remove zero entries in p 
p(p==0) = [];

% normalize p so that sum(p) is one.
p = p ./ numel(Data);

UniformityValue= sum(p.^2);
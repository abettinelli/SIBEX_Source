function EntropyValue=Entropy_LZ(Data, BinLoc)
Data=double(Data(:));

%histogram
[p, BinCenter] = hist(Data, BinLoc);

% remove zero entries in p 
p(p==0) = [];

% normalize p so that sum(p) is one.
p = p ./ numel(Data);

EntropyValue= -sum(p.*log2(p));
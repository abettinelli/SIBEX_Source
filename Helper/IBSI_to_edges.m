function [Cedges, Redges] = to_edges(CIndex, RIndex)

Cedges = zeros(length(CIndex)-1, 2);
Redges = zeros(length(RIndex)-1, 2);
for i = 1:length(CIndex)-1
    Cedges(i,:) = [CIndex(i) CIndex(i+1)];
    Redges(i,:) = [RIndex(i) RIndex(i+1)];
end
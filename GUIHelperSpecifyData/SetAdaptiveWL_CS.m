function [LevelMin, LevelMax]=SetAdaptiveWL_CS(handles)
 
hImage=findobj(handles.AxesImageAxial, 'Type', 'Image');
ImageData=get(hImage, 'CData');

[Count, Bin]=hist(single(ImageData(:)));

[MCount, CountIndex]=max(Count);

LevelMin=Bin(CountIndex)+Bin(CountIndex)*2/3;

cdf = cumsum(Count)/sum(Count);

tol_high=0.9998;
IndexHigh = find(cdf>=tol_high, 1, 'first');
if ~isempty(IndexHigh)
    LevelMax=Bin(IndexHigh);
else
    LevelMax=max(ImageData(:));
end

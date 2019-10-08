function  NumVox=MKGetNumVoxBWMask(BWMask, EdgeVoxelFraction)
if nargin > 1
    Fraction=EdgeVoxelFraction;
else
    Fraction=0.5;
end


TempIndex=find(BWMask);

if isempty(TempIndex)
    NumVox=0;
    return;
end

[II, JJ, KK]=ind2sub(size(BWMask), TempIndex);

MinK=min(KK);
MaxK=max(KK);

BWTemp=single(BWMask);
for i=MinK:MaxK       
    CurrentSlice=BWTemp(:, :, i);    

    BWPerim=bwperim(logical(CurrentSlice));
    CurrentSlice(BWPerim)=Fraction;
    
    BWTemp(:, :, i)=CurrentSlice;
end

NumVox=sum(BWTemp(:));
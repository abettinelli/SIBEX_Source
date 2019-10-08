
function [LocalUniformityMat, ScaleRatio, ScaleMin]=Scale2CTRange(LocalUniformityMat)

CTMin=0;
CTMax=2000;

MinV=min(LocalUniformityMat(:));
MaxV=max(LocalUniformityMat(:));

if MaxV ~= MinV
    LocalUniformityMat=(LocalUniformityMat-MinV)*(CTMax-CTMin)/(MaxV-MinV)+CTMin;
    
    ScaleRatio=(MaxV-MinV)/(CTMax-CTMin);
    ScaleMin=MinV;
else
    ScaleRatio=1;
    ScaleMin=MinV;
end

LocalUniformityMat=uint16(LocalUniformityMat);
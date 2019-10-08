function [mrn,Dice,Volume,Uniformity,SUVmean,SUVmax]=threshseg(I3d,showIMs,ParentInfo)
dbstop if error
% 
% i=1;ParentInfo = DataSetsInfo(i,1);
% I3d = ParentInfo.ROIImageInfo.MaskData;
% [results224(i,1),results224(i,2),results224(i,3),results224(i,4)]=threshseg(I3d,1,ParentInfo);

levels = 0.2:0.01:0.6;
count = 0;

hx = fspecial('sobel');
hy = hx';
Result = zeros(size(I3d));
Binary_Mask = Result;
cutlist = zeros(1,size(I3d,3));

%1. Go through each SUV levels to find SUVPerimMean, EdgePerimMean
for slice = 1:size(I3d,3);
    I = I3d(:,:,slice);
    SUVmax = max(I(:));
    Iy = imfilter(double(I), hy, 'replicate');
    Ix = imfilter(double(I), hx, 'replicate');
    gradmag = sqrt(Ix.^2 + Iy.^2);
    
    gradient_perim = zeros(1,length(levels));
    SUVmean = gradient_perim;
    count = 0;
    for i = levels
        mask = zeros(size(I));
        count = count + 1;
        cut=i*SUVmax;
        mask(I>cut) = 1;
        mask = imfill(mask);
        gradient_perim(count)=mean(gradmag(bwperim(mask,8)==1));
        SUVperimmean(count) = mean(I(bwperim(mask,8)==1));
        
        if showIMs == 1
            figure(1);
            subplot(1,3,1)
            imagesc(I);
            subplot(1,3,2)
            imagesc(mask);
            gradient_perim;
            SUVperimmean;
        end
    end
    
    %2: A. SUVPerimMean can't too be big;  B. Edge need to be strong
    gradient_perim=gradient_perim.*(SUVperimmean<0.6*SUVmax);%%%avoids fitting high gradient near peaks in tumor
    maxgrad=find(gradient_perim==max(gradient_perim));
    
    %3. Get rough binary mask, fill holes, remove small objects
    ROI = zeros(size(I));
    if SUVmax > 0
        ROI(I>levels(maxgrad(1))*SUVmax) = 1;
        cutlist(slice) = levels(maxgrad(1))*SUVmax;
        ROI = imfill(ROI);
        ROI=bwareaopen(ROI,3);
    end
    
    [labels,Numobj]=bwlabeln(ROI);
    
    ROIbuild = zeros(size(ROI));
    
    %4. Get the edge envelop. Based on conv hull to smooth the envelop
    for obj = 1:Numobj
    ROItemp = labels==obj;
    hull = bwconvhull(ROItemp);
    voids = hull-ROItemp;
    [mat,N]=bwlabeln(voids);
    [counts,~]=hist(nonzeros(mat),1:N);
    if(~isempty(find(counts>10)))
        voidnum=find(counts==max(counts));
        void = mat==voidnum;
        MAL=regionprops(void,'MajorAxisLength');
        MAL = round(MAL.MajorAxisLength);
        ROItemp = padarray(ROItemp,[MAL,MAL]);
        ROItemp=imerode(imdilate(ROItemp,ones(MAL)),ones(MAL));
        ROItemp = ROItemp(1+MAL:end-MAL,1+MAL:end-MAL);
    end
    ROIbuild = ROIbuild+ROItemp;
    end
    ROI = ROIbuild;
    %ROI = imerode(ROI,ones(3))
    if showIMs == 1
        figure(1);
        subplot(1,3,1)
        imagesc(I);
        title('Original Image')
        subplot(1,3,2)
        imagesc(I.*ROI);
        title('New Delineation')
        %title(strcat('slice = ',num2str(slice)));
        subplot(1,3,3)
        imagesc(ParentInfo.ROIImageInfo.MaskData(:,:,slice).*single(ParentInfo.ROIBWInfo.MaskData(:,:,slice)))
        title('Original Delineation')
        pause(1)
    end
    Iuse = double(I.*ROI);
    Iuse(Iuse==0) = NaN;
    
    offset = [0 1; -1 1; -1 0; -1 -1];
    C=graycomatrix(Iuse,'GrayLimits',[min(Iuse(:)) max(Iuse(:))],'NumLevels',length(min(Iuse(:)):max(Iuse(:))),'Offset',offset,'Symmetric',true);
    %disp(graycoprops(sum(C,3),'Energy'))
    %disp(slice)
    Result(:,:,slice) = I.*ROI;
    Binary_Mask(:,:,slice) = ROI;
end

vals=round(nonzeros(Result));
[counts,centers]=hist(vals,1:max(vals));
Uniformity=sum((counts./sum(counts)).^2);

Volume = sum(Binary_Mask(:))*0.327*0.54688^2;
SUVmean = mean(nonzeros(Result));
SUVmax = max(nonzeros(Result));
BWMask = ParentInfo.ROIBWInfo.MaskData;
%Dice = (length(nonzeros(BWMask&Binary_Mask))*2)/(sum(BWMask(:))+sum(Binary_Mask(:)));
Dice = 2;%%%used in motion examination
mrn=str2num(ParentInfo.MRN);


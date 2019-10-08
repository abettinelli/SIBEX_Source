function Necrosis_use=necrosis3d(CDataSetInfo)
%load('tissuetest.mat')
%%%Make necrosis come up exactly to line of liquid?????????
disp_img =0;
IMG=CDataSetInfo.ROIImageInfo.MaskData;
IMGinit = IMG;
%Mask = CDataSetInfo.ROIBWInfo.MaskData;
Maskfill = CDataSetInfo.ROIBWInfo.MaskData;
Mask_noair = Maskfill;
Maskfill(IMGinit<975) = 0;
Mask_noair(IMGinit<950)=0;
for i = 1:size(CDataSetInfo.ROIImageInfo.MaskData,3);
Maskfill(:,:,i) = imfill(Maskfill(:,:,i),'holes');
end
%%%fill internal air with 1000%%%
IMGinit(Maskfill==1 & IMGinit<975)=1005;
%%%Establish guess for necrosis based off threshold and filter IMG%%%
Necr_bounds = [975 1020];
for i = 1:size(CDataSetInfo.ROIImageInfo.MaskData,3);
    filt = fspecial('gaussian',[3 3],0.7);
    %IMG(:,:,i) = imfilter(IMG(:,:,i),filt);
    IMGinit(:,:,i) = roifilt2(filt,IMGinit(:,:,i),Maskfill(:,:,i));
end
%Mask(IMG<950) = 0;
use=IMGinit.*uint16(Mask_noair);
N_guess = (use>Necr_bounds(1)).*(use<=Necr_bounds(2));%%use used to be IMG
for i = 1:size(CDataSetInfo.ROIImageInfo.MaskData,3);
    N_guess(:,:,i) = imfill(logical(N_guess(:,:,i)),'holes');
end
SE = strel('disk', 2);
N_guess = imdilate(imerode(N_guess,SE),SE);
%%%%%%%%%%%%%%%%%%%

%%%Find if multiple regions within the guess exists, analyze largest%%%
if(max(N_guess(:))>0)
    [L,num] = bwlabeln(N_guess);
    [value,~]=hist(nonzeros(L),1:num);
    biggest_region = find(max(value)==value);
    Necr_cent = L==biggest_region;
    N=BWcentroid(Necr_cent);
    disp('Into region growing')
    [~,Necrosis_use] = regionGrowing(use, [N(2) N(1) N(3)],30,[],false);
    disp('Out of region growing')
    %%%prune results%%%%%%%%%%%%%%%%%%%%%%%
    for i = 1:size(CDataSetInfo.ROIImageInfo.MaskData,3);
        Necrosis_use(:,:,i) = bwareaopen(Necrosis_use(:,:,i),50);
        Necrosis_use(:,:,i)=imerode(Necrosis_use(:,:,i),ones(3));
        Necrosis_use(:,:,i) =imdilate(Necrosis_use(:,:,i),ones(3));
        Necrosis_use(:,:,i) = bwareaopen(Necrosis_use(:,:,i),50);
    end
else
    Necrosis_use = zeros(size(N_guess,1),size(N_guess,2),size(N_guess,3));
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%figure(1);subplot(1,2,1); imagesc(IMGinit(:,:,12).*uint16(Maskt(:,:,12))); subplot(1,2,2);imagesc(use(:,:,12)); colormap(gray)
%%%find centroid of Necrosis guess using 3D region growing%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%Display results%%%
R = zeros(size(IMG,1),size(IMG,2),3);
R(:,:,1) = 1;
if(disp_img==1)
    for i = 1:size(CDataSetInfo.ROIImageInfo.MaskData,3);
        figure(1);
        subplot(1,3,1);imagesc(use(:,:,i),[900 1300]);colormap(gray); 
        subplot(1,3,2);imagesc(IMG(:,:,i),[900 1300]);colormap(gray); 
         subplot(1,3,3);imagesc(IMG(:,:,i),[900 1300]);colormap(gray); hold on
        subplot(1,3,3);red=imagesc(R);
        set(red, 'AlphaData', Necrosis_use(:,:,i)*0.2);
        pause(1); hold off
    end
end

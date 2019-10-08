function [Air_out,Necrosis_out,Tissue_out,Vessel_out]=TissueSeg3(CDataSetInfo) %Air_out,Necrosis_out,Tissue_out,
disp_img = 0;
%load tissuetest.mat
%save('C:\Users\DVFried\Documents\MATLAB\test.mat')
%load 'C:\Users\DVFried\Documents\MATLAB\test.mat'

Air_bounds=[0 900];%%%white
%Necr_bounds = [975 1020];%%%red %%% 975 1035
Tissue_bounds = [1020 1120];%%%blue
Vessel_bounds = [1120 2000];%%%green
%%%%Initiation%%%%%%%%%%%
% Necr = zeros(size(CDataSetInfo.ROIImageInfo.MaskData,1),size(CDataSetInfo.ROIImageInfo.MaskData,2),3*size(CDataSetInfo.ROIImageInfo.MaskData,3));
% Tissue = zeros(size(CDataSetInfo.ROIImageInfo.MaskData,1),size(CDataSetInfo.ROIImageInfo.MaskData,2),3*size(CDataSetInfo.ROIImageInfo.MaskData,3));
% Vessel = zeros(size(CDataSetInfo.ROIImageInfo.MaskData,1),size(CDataSetInfo.ROIImageInfo.MaskData,2),3*size(CDataSetInfo.ROIImageInfo.MaskData,3));
% Air = zeros(size(CDataSetInfo.ROIImageInfo.MaskData,1),size(CDataSetInfo.ROIImageInfo.MaskData,2),3*size(CDataSetInfo.ROIImageInfo.MaskData,3));

Tissue_out = zeros(size(CDataSetInfo.ROIImageInfo.MaskData,1),size(CDataSetInfo.ROIImageInfo.MaskData,2),size(CDataSetInfo.ROIImageInfo.MaskData,3));
Vessel_out = zeros(size(CDataSetInfo.ROIImageInfo.MaskData,1),size(CDataSetInfo.ROIImageInfo.MaskData,2),size(CDataSetInfo.ROIImageInfo.MaskData,3));
Air_out = zeros(size(CDataSetInfo.ROIImageInfo.MaskData,1),size(CDataSetInfo.ROIImageInfo.MaskData,2),size(CDataSetInfo.ROIImageInfo.MaskData,3));

%%%%%%%%%%%%%%%%%%%
disp('1: Identifying necrotic regions')
%%%Identify Necrosis in 3D%%%%
Necrosis_use = necrosis3d(CDataSetInfo);
%%%%%%%%%%%%%%%
disp('2: Finished necrosis region growing')
%%%Identify Air,Vessels, Tissue on each 2D slice%%%%
for slice = 1:size(CDataSetInfo.ROIImageInfo.MaskData,3);
    %disp(slice)
    IMG=CDataSetInfo.ROIImageInfo.MaskData(:,:,slice);
    Mask = CDataSetInfo.ROIBWInfo.MaskData(:,:,slice);
    filt = fspecial('gaussian', [3 3],0.7);
    TumorTest1 = roifilt2(filt,IMG,Mask);
    Mask(IMG<875) = 0;
    Maskfill=imfill(Mask,'holes');
    
    
    %%%Identify air and vessels%%%%%
    TumorTest1 = double(TumorTest1).*double(Maskfill);
    TumorTestinit = double(IMG).*double(Maskfill);
    %TumorTestinit = double(IMG).*double(Maskfill);
    
    Air_use=TumorTestinit>Air_bounds(1) & TumorTestinit<=Air_bounds(2);
    Air_use = imerode(Air_use,ones(2));Air_use = imerode(Air_use,ones(2));
    Air_use = imdilate(Air_use,ones(2));Air_use = imdilate(Air_use,ones(2));
    Air_use=imfill(Air_use,'holes');
    %%%use raw or filtered image for vessels???
    Vessel1=TumorTest1>Vessel_bounds(1) & TumorTest1<=Vessel_bounds(2);
    Vessel_use=double(bwareaopen(Vessel1,2));
    %%%%%%%%%%%%%%%%%%%
    
    
    
    %%%%Identify Tissue%%%%%
    Tissue1=TumorTest1>Tissue_bounds(1) & TumorTest1<=Tissue_bounds(2);
    Tissue_use=double(bwareaopen(Tissue1,5));
    Tissue_use=abs(bwareaopen(abs(Tissue_use-1),20)-1);
    %Tissue_use=imfill(Tissue_use,'holes');
    Tissue_use = Tissue_use - (Tissue_use&(Air_use|Vessel_use|Necrosis_use(:,:,slice)));
    %%%%%%%%%%%%%%%%
    
    %%% Define the outputs & Initialize Colors%%%%%%
    Vessel_out(:,:,slice) = Vessel_use;
    Necrosis_out = Necrosis_use;
    Air_out(:,:,slice) = Air_use;
    Tissue_out(:,:,slice) = Tissue_use;
end
disp('3: Identified Air and Vessels')
%%%%check that the necrosis is bounded by Tissue/Internal Air/Vessels
%%% In future condense this loop into previous loop%%%
for i = 1:size(CDataSetInfo.ROIImageInfo.MaskData,3);
    IMG=CDataSetInfo.ROIImageInfo.MaskData(:,:,i);
    Mask = CDataSetInfo.ROIBWInfo.MaskData(:,:,i);
    Mask(IMG<875) = 0;
    Maskfill=imfill(Mask,'holes');
    TumorTest1 = double(IMG).*double(Maskfill);
    
    
    Regions=bwlabel(Necrosis_use(:,:,i));
    Seg_out = 3*Vessel_out(:,:,i)+Necrosis_out(:,:,i)+2*Air_out(:,:,i)+4*Tissue_out(:,:,i);
    %figure(1); subplot(2,3,1);imagesc(TumorTest1,[900 1300]); colormap(bone);
    for r = 1:max(Regions(:))
        %subplot(2,3,4);imagesc(Regions);
        region = Regions==r;
        SE = strel('disk', 4);
        Rdilated = imdilate(region,SE);
        perim = bwperim(Rdilated);
        %subplot(2,3,2);imagesc(perim*10+Seg_out);
        [num,~]=hist(Seg_out(perim==1),[0,1,2,3,4]);
        if(sum(num(2:5))/sum(num(:))>0.75)
            disp(sum(num(2:5))/sum(num(:)))
        else
            Necrosis_use(:,:,i)=Necrosis_use(:,:,i)-region;
            Tissue_out(:,:,i) = Tissue_out(:,:,i)+region;
        end
    end
    %subplot(2,3,5); imagesc(Necrosis_out(:,:,i));
    %subplot(2,3,6); imagesc(Necrosis_use(:,:,i));
    %pause(1);
    Tissue_out(:,:,i) = imfill(Tissue_out(:,:,i));
end
disp('4: Checked that necrosis met constraints')
Necrosis_out = Necrosis_use;

Tissue_out = Tissue_out - (Tissue_out&(Air_out|Vessel_out|Necrosis_out));


%%%%%%%%%%%%%%%%
Red = zeros(size(CDataSetInfo.ROIImageInfo.MaskData,1),size(CDataSetInfo.ROIImageInfo.MaskData,2),3);
Green = Red;
Blue = Red;
White = Red;
Red(:,:,1) = ones(size(CDataSetInfo.ROIImageInfo.MaskData,1),size(CDataSetInfo.ROIImageInfo.MaskData,2));
Green(:,:,2) = ones(size(CDataSetInfo.ROIImageInfo.MaskData,1),size(CDataSetInfo.ROIImageInfo.MaskData,2));
Blue(:,:,3) = ones(size(CDataSetInfo.ROIImageInfo.MaskData,1),size(CDataSetInfo.ROIImageInfo.MaskData,2));
White(:,:,1) = ones(size(CDataSetInfo.ROIImageInfo.MaskData,1),size(CDataSetInfo.ROIImageInfo.MaskData,2));
White(:,:,2) = ones(size(CDataSetInfo.ROIImageInfo.MaskData,1),size(CDataSetInfo.ROIImageInfo.MaskData,2));
White(:,:,3) = ones(size(CDataSetInfo.ROIImageInfo.MaskData,1),size(CDataSetInfo.ROIImageInfo.MaskData,2));
%%%%Display Stuff%%%%%%%%%
if(disp_img==1)
    for slice = 1:size(CDataSetInfo.ROIImageInfo.MaskData,3);
        image = slice;
        IMG=CDataSetInfo.ROIImageInfo.MaskData(:,:,image);
        Mask = CDataSetInfo.ROIBWInfo.MaskData(:,:,image);
        I = double(IMG).*double(Mask);
        figure(1); subplot(1,2,1);
        figure(1); imagesc(I,[900 1300]); colormap(gray); hold on;
        figure(1); type1 = imagesc(Red);
        set(type1, 'AlphaData', Necrosis_out(:,:,slice)*0.2);
        figure(1); type2 = imagesc(Green);
        set(type2, 'AlphaData', Tissue_out(:,:,slice)*0.2);
        figure(1); type3 = imagesc(Blue);
        set(type3, 'AlphaData', Vessel_out(:,:,slice)*0.2);
        figure(1); type4 = imagesc(White);
        set(type4, 'AlphaData', Air_out(:,:,slice)*0.5); hold off;
        subplot(1,2,2);
        imagesc(I,[900 1300]);
        pause(1)
        
    end
else
    disp('display off')
end



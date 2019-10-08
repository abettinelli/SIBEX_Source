function centroid=BWcentroid(BW)
SE = strel('disk', 1);
N = regionprops(BW,'centroid');
Ncent=round(N.Centroid);

if length(Ncent)==2
    Ncent(3)=1;
end

if(BW(Ncent(2),Ncent(1),Ncent(3))==1)
    centroid =Ncent;
    disp('centroid within guess')
else
    disp('centroid outside of guess...finding closest point')
    temp = zeros(size(BW(:,:,Ncent(3))));
    temp(Ncent(2),Ncent(1))=1;
    match=temp&BW(:,:,Ncent(3));
    while(sum(match(:))==0)
        temp = imdilate(temp,SE);
        match=temp&BW(:,:,Ncent(3));
        %figure(3),imagesc(2*temp+BW(:,:,Ncent(3)));
    end
    [r,c]=find(match==1);
    centroid = [c(1),r(1),Ncent(3)];
    disp('~centroid point found in guess')
end

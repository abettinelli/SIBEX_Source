function filter = IBSI2_get_riesz_filter(MaskData, Param)

% Padding measurements
N=max(size(MaskData));
pad_square = N-size(MaskData);
N_half_filter = ceil((N+1)/2)-1;

pad_pre=ceil(pad_square/2) + N_half_filter;
pad_post=floor(pad_square/2) + N_half_filter;

NF=max(pad_pre+size(MaskData)+pad_post);

% Fourier space
idx_k = (1:NF)-(floor(NF/2)+1); % +1 to get most frequencies on the right part

switch Param.type
    case '2D'
        [K1, K2] = meshgrid(idx_k, idx_k);
        modFreq = sqrt(K1.^2+K2.^2);
        ni(:,:,:,1)=K1;
        ni(:,:,:,2)=K2;
    case '3D'
        [K1, K2, K3] = meshgrid(idx_k, idx_k, idx_k);
        modFreq = sqrt(K1.^2+K2.^2+K3.^2);
        ni(:,:,:,1)=K1;
        ni(:,:,:,2)=K2;
        ni(:,:,:,3)=K3;
end

% Create Riesz filter
l = Param.l;
N_dims=size(ni,4);

L=sum(l);
l_fact_product=1;
v_elev_product=1;
v_squared_sum =0;
for i = 1:N_dims
    l_fact_product=l_fact_product*factorial(l(i));
    v_elev_product=v_elev_product.*ni(:,:,:,i).^l(i);
    v_squared_sum =v_squared_sum+ni(:,:,:,i).^2;
end
clearvars i

filter = ((-1i)^L)*sqrt((factorial(L))/(l_fact_product))*(v_elev_product)./((v_squared_sum).^(L/2));
filter(isnan(filter))=0;

% Shift filter
filter = ifftshift(filter); 
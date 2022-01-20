function image_filtered = IBSI2_apply_riesz_filtering(image, filter, Param)

N=max(size(image));

% Image_padding
pad_square = N-size(image);
N_pad = ceil((N+1)/2)-1;
pad_pre=ceil(pad_square/2) + N_pad;
pad_post=floor(pad_square/2) + N_pad;
image_pad = padarray(image, pad_pre, Param.padding, 'pre');
image_pad = padarray(image_pad, pad_post, Param.padding, 'post');

%Fourier space
switch Param.type
    case '2D'
        f_IMG=image_pad;
        parfor i=1:size(image_pad,3)
            f_IMG(:,:,i) = fftn(image_pad(:,:,i));
        end
    case '3D'
        f_IMG = fftn(image_pad);
end

% Apply filter
switch Param.type
    case '2D'
        image_filtered=f_IMG;
        parfor i=1:size(f_IMG,3)
            image_filtered(:,:,i)=ifftn(squeeze(f_IMG(:,:,i)).*filter);
        end
    case '3D'
        image_filtered=ifftn(f_IMG.*filter);
end

% Delete Padding
image_filtered=image_filtered((pad_pre(1)+1):end-pad_post(1),(pad_pre(2)+1):end-pad_post(2),(pad_pre(3)+1):end-pad_post(3));
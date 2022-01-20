function gabor_filter_bank = IBSI2_get_gabor_filters(Param, theta, pixel_size)

sigma=Param.sigma_star/pixel_size;
lambda=Param.lambda_star/pixel_size;

% Filter support size
if Param.gamma <= 1
    M = 1+2*floor(Param.d*sigma+0.5);
else
    M = 1+2*floor(Param.d*Param.gamma*sigma+0.5);
end

x = (1:M)-ceil(M/2);
y = (1:M)-ceil(M/2);

[K1,K2] = meshgrid(x,y);

gabor_filter_bank = cell(1,length(theta));
for i=1:length(theta)
    % rotate k1 and k2
    R = [cos(theta(i)), sin(theta(i)); sin(theta(i)), -cos(theta(i))];
    K_tilde = [K1(:), K2(:)]*R;
    
    % Create filter
    gabor_filter=exp(-((K_tilde(:,1).^2+Param.gamma.^2*K_tilde(:,2).^2)/(2*sigma.^2) + 1i*(2*pi*K_tilde(:,1)/lambda)));
    gabor_filter_bank{i}=reshape(gabor_filter,M,[]);
end
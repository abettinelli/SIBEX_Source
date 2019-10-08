function H=LaplacianAnySize(Size, Sigma)

p2=[Size, Size];
p3=Sigma;

siz   = (p2-1)/2;
std2   = p3^2;

[x,y] = meshgrid(-siz(2):siz(2),-siz(1):siz(1));
arg   = -(x.*x + y.*y)/(2*std2);

h     = exp(arg);
h(h<eps*max(h(:))) = 0;

sumh = sum(h(:));
if sumh ~= 0,
    h  = h/sumh;
end;

%Remove gaussian effect
hTemp=zeros(size(h));
hTemp((size(h, 1)+1)/2,  (size(h, 2)+1)/2)=1;
h=hTemp;

% now calculate Laplacian
hTemp=(x.*x + y.*y - 2*std2)/(std2^2);

h1 = h.*(x.*x + y.*y - 2*std2)/(std2^2);
H = h1 - sum(h1(:))/prod(p2); % make the filter sum to zero
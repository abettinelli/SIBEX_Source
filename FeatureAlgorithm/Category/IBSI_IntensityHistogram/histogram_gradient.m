function [H_g, levels] = histogram_gradient(img)

levels = unique(img);
levels = levels(1):levels(end);
[count, levels] = hist(img, levels);

N = length(levels)-1;

H_g = zeros(1,N);
H_g(1) = count(2)-count(1);
for i = 2:N
    H_g(i) = (count(i+1)-count(i-1))/2;
end
H_g(end) = count(end)-count(end-1);
function value = my_prctile(vector, p)

vector = sort(vector, 'ascend');
n = ceil(p/100*length(vector));
value = vector(n);

end
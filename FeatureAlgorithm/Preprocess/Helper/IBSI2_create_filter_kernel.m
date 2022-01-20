function FilterKernel = IBSI2_create_filter_kernel(monoFilterBank)

if length(monoFilterBank) == 2
    FilterKernel = monoFilterBank{2}'*monoFilterBank{1};
    
elseif length(monoFilterBank) == 3
    n1=length(monoFilterBank{1});
    n2=length(monoFilterBank{2});
    n3=length(monoFilterBank{3});
    p(1,1,:) = monoFilterBank{3};
    two_dim=repmat(monoFilterBank{2}',1,n1).*repmat(monoFilterBank{1},n2,1);
    FilterKernel=repmat(two_dim,1,1,n3).*repmat(p,n2,n1,1);
end
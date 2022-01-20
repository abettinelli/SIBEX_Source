function PooledData = IBSI2_imfilter_ri(CurrentData, monoFilterBank, padding, pooling)

if length(monoFilterBank) == 2
    
    % Filters
    g1=monoFilterBank{1};
    g2=monoFilterBank{2};
    % Flipped filters
    J1= fliplr(g1);
    J2= fliplr(g2);
    
    FilterKernel{1} = IBSI2_create_filter_kernel({g1 g2});
    FilterKernel{2} = IBSI2_create_filter_kernel({J2 g1});
    FilterKernel{3} = IBSI2_create_filter_kernel({J1 J2});
    FilterKernel{4} = IBSI2_create_filter_kernel({g2 J1});
    
elseif length(monoFilterBank) == 3
    
    % Filters
    g1=monoFilterBank{1};
    g2=monoFilterBank{2};
    g3=monoFilterBank{3};
    % Flipped filters
    J1= fliplr(g1);
    J2= fliplr(g2);
    J3= fliplr(g3);
    
    FilterKernel{01} = IBSI2_create_filter_kernel({g1 g2 g3});
    FilterKernel{02} = IBSI2_create_filter_kernel({J3 g2 g1});
    FilterKernel{03} = IBSI2_create_filter_kernel({J1 g2 J3});
    FilterKernel{04} = IBSI2_create_filter_kernel({g3 g2 J1});
    FilterKernel{05} = IBSI2_create_filter_kernel({g2 g3 g1});
    FilterKernel{06} = IBSI2_create_filter_kernel({g2 J3 J1});
    FilterKernel{07} = IBSI2_create_filter_kernel({g2 J1 g3});
    FilterKernel{08} = IBSI2_create_filter_kernel({J1 J2 g3});
    FilterKernel{09} = IBSI2_create_filter_kernel({J2 g1 g3});
    FilterKernel{10} = IBSI2_create_filter_kernel({J3 J1 g2});
    FilterKernel{11} = IBSI2_create_filter_kernel({J3 J2 J1});
    FilterKernel{12} = IBSI2_create_filter_kernel({J3 g1 J2});
    FilterKernel{13} = IBSI2_create_filter_kernel({J2 J1 J3});
    FilterKernel{14} = IBSI2_create_filter_kernel({g1 J2 J3});
    FilterKernel{15} = IBSI2_create_filter_kernel({g2 g1 J3});
    FilterKernel{16} = IBSI2_create_filter_kernel({g3 J1 J2});
    FilterKernel{17} = IBSI2_create_filter_kernel({g3 J2 g1});
    FilterKernel{18} = IBSI2_create_filter_kernel({g3 g1 g2});
    FilterKernel{19} = IBSI2_create_filter_kernel({J1 g3 g2});
    FilterKernel{20} = IBSI2_create_filter_kernel({J2 g3 J1});
    FilterKernel{21} = IBSI2_create_filter_kernel({g1 g3 J2});
    FilterKernel{22} = IBSI2_create_filter_kernel({J1 J3 J2});
    FilterKernel{23} = IBSI2_create_filter_kernel({J2 J3 g1});
    FilterKernel{24} = IBSI2_create_filter_kernel({g1 J3 g2});
end

parfor i =1:length(FilterKernel)
    CurrentDataBank(:,:,:,i)=imfilter(CurrentData, flip(FilterKernel{i},3), padding, 'same', 'conv');
end

switch pooling
    case 'max'
        PooledData=squeeze(max(CurrentDataBank,[],4));
    case 'avg'
        PooledData=squeeze(mean(CurrentDataBank,4));
end
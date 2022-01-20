function [FilteredSlice] = IBSI2_apply_gabor_filtering(IMG,gabor_filter_bank, Param)

FilteredSlice = zeros([size(IMG) length(gabor_filter_bank)]);
for i = 1:size(gabor_filter_bank,2)
    FilteredSlice(:,:,i) = abs(imfilter(IMG,gabor_filter_bank{i}, Param.padding, 'same', 'conv'));
end

% If rotation invariance do Pooling
if Param.rotation_invariance
    if strcmp(Param.pooling,'avg')
        FilteredSlice = mean(FilteredSlice,3);
    elseif strcmp(Param.pooling,'max')
        FilteredSlice = max(FilteredSlice,3);
    end
end

end
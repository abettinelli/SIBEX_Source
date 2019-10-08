function  [img, mask] = IBSI_minimal_ROI(img, mask)

if length(size(mask)) == 3
    idx_x = squeeze(sum(squeeze(sum(mask,3)),2)); % mod2014 squeeze(sum(mask, [2, 3]))
    idx_y = squeeze(sum(squeeze(sum(mask,3)),1))'; % mod2014 squeeze(sum(mask, [1, 3]))'
    idx_z = squeeze(sum(squeeze(sum(mask,2)),1)); % mod2014 squeeze(sum(mask, [1, 2]))
    
    img = img(find(idx_x, 1, 'first'):find(idx_x, 1, 'last'), find(idx_y, 1, 'first'):find(idx_y, 1, 'last'), find(idx_z, 1, 'first'):find(idx_z, 1, 'last'));
    mask = mask(find(idx_x, 1, 'first'):find(idx_x, 1, 'last'), find(idx_y, 1, 'first'):find(idx_y, 1, 'last'), find(idx_z, 1, 'first'):find(idx_z, 1, 'last'));
elseif length(size(mask)) == 2
    idx_x = squeeze(sum(mask, 2));
    idx_y = squeeze(sum(mask, 1))';
    
    img = img(find(idx_x, 1, 'first'):find(idx_x, 1, 'last'), find(idx_y, 1, 'first'):find(idx_y, 1, 'last'));
    mask = mask(find(idx_x, 1, 'first'):find(idx_x, 1, 'last'), find(idx_y, 1, 'first'):find(idx_y, 1, 'last'));
end
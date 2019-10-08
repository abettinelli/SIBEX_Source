function [ResultStruct, ResultStructBW]=Butterworth_Smooth(CDataSetInfo, Param)
%%%Doc Starts%%%
%-Description: 
%Applies a 2D Butterworth filter in the frequency domain slice-by-slice.
%
% Based on text Digital Imaging Processing by Gonzales and Woods.
% 
%-Parameters:
%1.  cutoff: Frequencies below radius cutoff will be filtered. Smaller
%               number produce more smoothing in the spatial domain.
%2.  order: higher orders produce harder cuts at the cutoff frequency.

%-Revision:
%2015-10-30: The method is implemented.

%-Author:
%Dennis Mackin, dsmackin@mdanderson.org
%%%Doc Ends%%%

    %--Parameters
    [MFilePath, MFileName]=fileparts(mfilename('fullpath'));

    if nargin < 2    
        ConfigFile=[MFilePath, '\', MFileName, '.INI'];

        Param=GetParamFromINI(ConfigFile);   
    end

    %Parameter Check
    if ~isfield(Param, 'cutoff') || ~isfield(Param, 'order')
        ResultStruct=[];
        ResultStructBW=[];
        return;
    end
    
    ROIImageInfo=CDataSetInfo.ROIImageInfo;
    %Filter
    for i=1:CDataSetInfo.ROIImageInfo.ZDim
        I=ROIImageInfo.MaskData(:, :, i);
        I_filtered = filterImage(I, Param.cutoff, Param.order, ...
                                Param.x_padded_size, Param.y_padded_size);
        ROIImageInfo.MaskData(:, :, i) = I_filtered;
        if(Param.draw_before_after & i == 1)
           draw_before_after(I, I_filtered, Param.images_folder, CDataSetInfo.MRN, CDataSetInfo.ROIName, Param.cutoff);
        end        
    end

    %Return Value
    ROIImageInfo.Description=MFileName;
    ResultStruct=ROIImageInfo;
    ResultStructBW=CDataSetInfo.ROIBWInfo;
end
%		End of function


function plot = draw_before_after(I_before, I_after, folder, MRN, roi_name, cutoff)
    fig = figure;
    subplot(1,2,1);
    imshow(imadjust(I_before));
    subplot(1,2,2);
    imshow(imadjust(I_after));

    filename = sprintf('%s/%s_%03d.png', folder, MRN, cutoff);
    print('-dpng', filename);  
    
    close;
end


function I_filtered = filterImage(I, cutoff, order, x_padded_size, y_padded_size)

    %Get max and min to preserve scaling
    I_min = single(min(I(:)));
    I_max = single(max(I(:)));

    %rescale image
    f = single(I) - I_min;
    f = f/(I_max - I_min);

    % Pad image for the FFT
    F = fft2(f, x_padded_size, y_padded_size);

    %Build BW filter
    u = single(0:(x_padded_size - 1));
    v = single(0:(y_padded_size - 1));

    idx = find( u > x_padded_size/2);
    u(idx) = u(idx) - x_padded_size;  
    idy = find( v > y_padded_size/2);
    v(idy) = v(idy) - y_padded_size;

    [V, U] = meshgrid(v, u);

    D = sqrt(U.^2 + V.^2);
    H = 1.0 ./ (1.0 + (D./cutoff).^(2*order));
    
    %apply the filter to frequency image
    G = H .* F;

    %transform back to spatial domain
    g = ifft2(G);
    g = g(1:size(f,1), 1:size(f,2));

    % Rescale to original  
    g = g*(I_max - I_min) + I_min;
    I_filtered = uint16(g);
end
%		End of function


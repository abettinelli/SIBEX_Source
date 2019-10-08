function OrganColor=GetWinOrganColor(cellColor)

ColorPresetList=[1,1,0; 1,0,1; 0,1,1; 1,0,0; 0,1,0; 0,0,1; 1,1,1; 0,0,0];

OrganColor=[];
for i=1:length(cellColor)
    TempColor=cellColor{i};
    
    switch TempColor
        case 'red'
            TempColor=[255,0,0]/255;
        case 'green'
            TempColor=[0,255,0]/255;
        case 'blue'
            TempColor=[0,0, 255]/255;
        case 'yellow'
            TempColor=[255,255,0]/255;
        case 'purple'
            TempColor=[255,0,255]/255;
        case 'skyblue'
            TempColor=[0,255,255]/255;
        case 'lavender'
            TempColor=[200,180,255]/255;
        case 'orange'
            TempColor=[255,150,0]/255;
        case 'forest'
            TempColor=[34,139,34]/255;
        case 'slateblue'
            TempColor=[128,0,255]/255;
        case 'lightblue'
            TempColor=[0,128,255]/255;
        case 'yellowgreen'
            TempColor=[192,255,0]/255;
        case 'lightorange'
            TempColor=[255,192,0]/255;
        case 'grey'
            TempColor=[192,192,192]/255;
        case 'khaki'
            TempColor=[240,230,140]/255;
        case 'aquamarine'
            TempColor=[128,255,212]/255;
        case 'teal'
            TempColor=[0,160,160]/255;
        case 'steelblue'
            TempColor=[70,130,180]/255;
        case 'brown'
            TempColor=[165,80,55]/255;
        case 'olive'
            TempColor=[165,161,55]/255;
        case 'tomato'
            TempColor=[255,83,76]/255;
        case 'seashell'
            TempColor=[255,228,196]/255;
        case 'maroon'
            TempColor=[180,30,30]/255;
        case 'greyscale'
            TempColor=[255,255,255]/255;
        case 'inverse_grey'
            TempColor=[0,0,0]/255;
        case 'skin'
            TempColor=[255,200,150]/255;
        case 'Smart'
            TempColor=[255,255,255]/255;
        case 'Fusion_Red'
            TempColor=[255,0,0]/255;
        case 'Thermal'
            TempColor=[0,0,0]/255;
        case 'SUV2'
            TempColor=[255,255,255]/255;
        case 'SUV3'
            TempColor=[255,255,255]/255;
        case 'CEqual'
            TempColor=[0,0,0]/255;
        case 'rainbow1'
            TempColor=[136,0, 121]/255;
        case 'rainbow2'
            TempColor=[64,0,128]/255;
        case 'GEM'
            TempColor=[0,32,64]/255;
        case 'spectrum'
            TempColor=[0,0,0]/255;
        otherwise
            if rem(i, 8) ~= 0
                TempColor= ColorPresetList(rem(i, 8), :);
            else
                TempColor= ColorPresetList(8, :);
            end
    end

    OrganColor=[OrganColor; {TempColor}];
end
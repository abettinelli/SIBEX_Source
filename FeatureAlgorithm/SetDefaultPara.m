function Param=SetDefaultPara(MFileName)

hMsg=MsgboxGuiIFOA('Parameters are incomplete. Default value are used.', 'Error', 'error', 'modal');
waitfor(hMsg);
            
switch MFileName
    case 'Gaussian_Smooth'
        Param.Size=3;
        Param.Sigma=0.5;
        
    case 'Laplacian_Smooth'        
        Param.Alpha=0.2;
        
    case 'Log_Smooth'
        Param.Size=5;
        Param.Sigma=0.5;
        
    case 'Average_Smooth'
          Param.Size=3;
          
    case 'AdaptHistEqualization_Enhance'
        Param.NumTiles=8;
        Param.ClipLimit=0.01;
        Param.NBins=256;
        
    case 'HistEqualization_Enhance'
        Param.NBins=64;
        
    case 'Wiener_Smooth'
        Param.Size=3;        
        
    case 'Median_Smooth'
        Param.Size=3;   
        
    case 'Sharp_Enhance'
        Param.Alpha=0.2;
        
    case 'Gaussian_Deblur'
        Param.Size=5; 
        
    case 'BitDepthRescale_Range'        
        Param.RangeMin=0;
        Param.RangeMax=4096;
        Param.BitDepth=8;
        
    case 'BitDepthRescale'      
        Param.BitDepth=8;
       
    otherwise
        Param=[];       
end









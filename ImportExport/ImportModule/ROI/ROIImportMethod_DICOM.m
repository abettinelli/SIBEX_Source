function structAxialROI=ROIImportMethod_DICOM(FileName, ImageDataInfo)
%Import
try
    DCM2PinnV9=ImageDataInfo.StartV9;
    
    %Import
    ROIDICOMInfo=dicominfo(FileName);
    
    if ~isequal(ROIDICOMInfo.Modality, 'RTSTRUCT')
        structAxialROI=[];
        return;
    end
    
    XPixDim=ImageDataInfo.XPixDim;
    YPixDim=ImageDataInfo.YPixDim;
    
    if ~isempty(ImageDataInfo.XStartV9)
        TempPos=[ImageDataInfo.XStartV9, ImageDataInfo.YStartV9-YPixDim];
    else
        TempPos=[ImageDataInfo.XStartV8, ImageDataInfo.YStartV8+ImageDataInfo.YPixDim*ImageDataInfo.YDim-YPixDim/2];
    end
        
    %NameStr
    NameStr='TempStr';
    
    %ROIName
    ROIName=[];
    if isfield(ROIDICOMInfo, 'StructureSetROISequence')
        for i=1:length(fieldnames(ROIDICOMInfo.StructureSetROISequence))
            FieldName=['Item_', num2str(i)];
            ROIName=[ROIName; {ROIDICOMInfo.StructureSetROISequence.(FieldName).ROIName}];
        end
    end
    
    %No ROI
    if isempty(ROIName)
        return;
    end
    
    
    FinalFileHead={
        '// Region of Interest file';  ...
        ['// Data set: ', NameStr]; ...
        ['// File created: ', datestr(now, 0)];  ...
        ' ';  ...
        '//';...
        '// Pinnacle Treatment Planning System Version 7.6c'; ...
        '// 7.6c '; ...
        '//'};
    
    
    %Template ROI head
    ModelROIStart={
        '//-----------------------------------------------------';...
        '//  Beginning of ROI: RT Parotid';...
        '//-----------------------------------------------------';...
        ' ';...
        'roi={';...
        'name: RT Parotid';...
        ['volume_name: ', NameStr];...
        ['stats_volume_name: ', NameStr];...
        'flags =          131088;';...
        'color:           forest';...
        'box_size =       5;';...
        'line_2d_width =  1;';...
        'line_3d_width =  1;';...
        'paint_brush_radius =  0.4;';...
        'paint_allow_curve_closing = 1;';...
        'lower =          800;';...
        'upper =          4096;';...
        'radius =         0;';...
        'density =        1;';...
        'density_units:   g/cm^3';...
        'override_data =  0;';...
        'invert_density_loading =  0;';...
        'volume =         0;';...
        'pixel_min =      0;';...
        'pixel_max =      0;';...
        'pixel_mean =     0;';...
        'pixel_std =      0;';...
        'num_curve = 18;'...
        };
    
    ModelROIEnd={'}; // End of ROI RT Parotid'};
    
    ModelCurveStart={
        '//----------------------------------------------------';...
        '//  ROI: GTV primary 0';...
        '//  Curve 1 of 16';...
        '//----------------------------------------------------';...
        'curve={';...
        'flags =       16908308;';...
        'block_size =  32;';...
        'num_points =  77;';...
        'points={';...
        };
    
    ModelCurveEnd={
        '};  // End of points for curve 1';...
        '}; // End of curve 1';...
        };
    
    ColorList={'lightorange'; 'red'; 'green'; 'blue'; 'yellow'; 'purple'; 'skyblue'; 'maroon'; 'orange'; 'forest'; 'slateblue'; 'lightblue'; 'yellowgreen'};
    
    PinColor={'red'; 'green'; 'blue'; 'yellow'; 'purple'; 'skyblue'; 'lavender'; 'orange'; 'forest'; 'slateblue';  'lightblue'; 'yellowgreen'; 'lightorange'; ...
        'grey'; 'khaki'; 'aquamarine'; 'teal'; 'steelblue'; 'brown';  'olive'; 'tomato'; 'seashell'; 'maroon'; 'greyscale'; 'Thermal'; 'skin'; ...
        'Smart'; 'Fusion_Red'; 'Thermal'; 'SUV2'; 'SUV3'; 'CEqual'; 'rainbow1'; 'rainbow2'; 'GEM'; 'spectrum'};
    
    WindowColor=[255,0,0; 0,255,0; 0,0, 255; 255,255,0; 255,0,255; 0,255,255; 200,180,255; 255,149,0; 34,139,34; 128,0,255; 0,128,255; 192,255,0; 255,192,0; ...
        192,192,192; 240,230,140; 128,255,212; 0,160,160; 70,130,180; 165,80,55; 165,161,55; 255,83,76; 255,228,196; 180,30,30; 255,255,255; 0,0,0; 255,200,150; ...
        255,255,255; 255,0,0; 0,0,0; 255,255,255; 255,255,255; 0,0,0; 136,0, 121; 64,0,128; 0,32,64; 0,0,0]/255;
    
    %Write curve cooridate for each organ
    ROIFileMiddle=[];
    RowNum=length(ROIName);
    
    for i=1:RowNum
        %Set Status
        %     set(hText, 'String', ['Generating ', ROIName{i}, ' in plan.roi for Plan_', num2str(PlanID), ' ...']);
        %     drawnow;
        
        %ROI Start&End template
        TempROIStart=ModelROIStart;
        TempROIStart{2}=['//  Beginning of ROI: ', ROIName{i}];
        TempROIStart{6}=['name: ',  ROIName{i}];
        
        FieldName=['Item_', num2str(i)];
        
        if isfield(ROIDICOMInfo.ROIContourSequence.(FieldName), 'ROIDisplayColor')
            ROIColor=ROIDICOMInfo.ROIContourSequence.(FieldName).ROIDisplayColor'/255;
            
            TempV=sum(ROIColor.^2);
            if TempV < 1E-04
                ROIColor=[0, 1,1 ];
            end
        else
            ROIColor=[1, 0, 0];
        end
        
        TempColor=repmat(ROIColor, [length(WindowColor), 1])-WindowColor;
        TempColor=sum(TempColor.*TempColor, 2);
        [TempMin, TempIndex]=min(TempColor);
        
        TempROIStart{10}=['color:           ', PinColor{TempIndex}];
        
        if isfield(ROIDICOMInfo.ROIContourSequence.(FieldName), 'ContourSequence')
            ROICurveNum=length(fieldnames(ROIDICOMInfo.ROIContourSequence.(FieldName).ContourSequence));
        else
            continue;
        end
        TempROIStart{end}=['num_curve = ', num2str(ROICurveNum), ';'];
        
        TempROIEnd=ModelROIEnd;
        TempROIEnd{1}=['}; // End of ROI ', ROIName{i}];
        
        %Curve Start&End template
        TempCurveStart=ModelCurveStart;
        TempCurveStart{2}=['//  ROI: ', ROIName{i}];
        
        TempCurveEnd=[{'};  // End of points for curve 1'}; {'}; // End of curve 1'}];
        
        %Write Curve points
        TempROISection=[];
        for jj=1:ROICurveNum
            SubFieldName=['Item_', num2str(jj)];
            
            TempCurveStart(3)=cellstr(['//  Curve ', num2str(jj), ' of ', num2str(ROICurveNum)]);
            
            %CurvePoints
            TempData=ROIDICOMInfo.ROIContourSequence.(FieldName).ContourSequence.(SubFieldName).ContourData;
            TempData=reshape(TempData, 3, [])'/10;
            
            TempPoint=ROIDICOMInfo.ROIContourSequence.(FieldName).ContourSequence.(SubFieldName).NumberOfContourPoints;
            TempCurveStart(8)=cellstr(['num_points = ', num2str(TempPoint), ';']);
            
            TempCurveEnd(1)={['};  // End of points for curve ', num2str(jj)]};
            TempCurveEnd(2)={['}; // End of curve ', num2str(jj)]};
            
            TempZLocation=TempData(:, 3);
            
            %Changed on 03/25/2010
            HalfPixelOffset=1;
            
            if DCM2PinnV9 < 1
                if HalfPixelOffset > 0
                    TempData(:,1)=TempData(:,1);
                    TempData(:,2)=2*TempPos(2)-TempData(:,2)-YPixDim;
                    TempData(:, 3)=-TempData(:, 3);
                else
                    TempData(:,1)=TempData(:,1);
                    TempData(:,2)=2*TempPos(2)-TempData(:,2);
                    TempData(:, 3)=-TempData(:, 3);
                end
            else
                TempData(:,1)=TempData(:,1);
                TempData(:,2)=-TempData(:,2);
                TempData(:, 3)=-TempData(:, 3);
            end
            
            TempCurvePoint=cellstr(num2str(TempData));
            
            TempROISection=[TempROISection; TempCurveStart; TempCurvePoint; TempCurveEnd];
        end
        
        %Store
        ROIFileMiddle=[ROIFileMiddle; TempROIStart; TempROISection; TempROIEnd];
    end
    
    FinalFile=[FinalFileHead; ROIFileMiddle];
    
    %Write TempFile
    TempPath=fileparts(FileName);
    TempFile=[TempPath, '\', datestr(now, 30), '.roi'];
    
    Fid=fopen(TempFile, 'w');
    for i=1:length(FinalFile)
        fprintf(Fid, '%s\n', FinalFile{i});
    end
    fclose(Fid);
    
    %Load in
    [DXStart, DYStart]=GetDiffStartPoint(DCM2PinnV9, ImageDataInfo);
    structAxialROI=LoadROIStructs(TempFile, 'Fake.roi', 'Fake.roi', [DXStart, DYStart]);
    
    %Delete temp file
    delete(TempFile);
catch
    structAxialROI=[];
end







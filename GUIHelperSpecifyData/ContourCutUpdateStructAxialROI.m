function ContourCutUpdateStructAxialROI(handles)

%Initialization
[ROIName, PlanIndex]=GetCurrentROIInfo(handles);

ImageDataInfo=GetImageDataInfo(handles, 'Axial');
CurrentZLoc=ImageDataInfo.TablePos(handles.SliceNum);

structAxialROI=handles.PlansInfo.structAxialROI{PlanIndex};
ROIIndex=strmatch(ROIName, {structAxialROI.name}, 'exact');


hLine=findobj(handles.figure1, 'Type', 'line', 'UserData', 'ContourNudge');

if ~isempty(hLine)
    %Get region
    CutLineX=get(hLine, 'XData'); CutLineY=get(hLine, 'YData');
    
    %Delete region line
    delete(hLine);    
 
    [ROIName, PlanIndex]=GetCurrentROIInfo(handles);
    ROIhLine=findobj(handles.AxesImageAxial, 'Type', 'Line', 'UserData', [{'Contour'}, {[ROIName, num2str(PlanIndex)]}]);
    
    if ~isempty(ROIhLine)        
        structAxialROI=structAxialROI(ROIIndex);
        
        %Clean structAxialROI
        TempIndexT=find(abs(CurrentZLoc-structAxialROI.ZLocation) < ImageDataInfo.ZPixDim/3);
        
        if ~isempty(TempIndexT)
            structAxialROI.ZLocation(TempIndexT)=[];
            structAxialROI.CurvesCor(TempIndexT)=[];
            structAxialROI.OrganCurveNum=structAxialROI.OrganCurveNum-length(TempIndexT);
        end
        
        %Cut or keep curve
        MinX=min(CutLineX); MaxX=max(CutLineX); MinY=min(CutLineY); MaxY=max(CutLineY);
        for i=1:length(ROIhLine)
            LineX=get(ROIhLine(i), 'XData'); LineY=get(ROIhLine(i), 'YData');
            
            CutCurve=0;
            
            for j=1:length(LineX)
                if (LineX(j) >= MinX) && (LineX(j) <= MaxX) && (LineY(j) >= MinY) && (LineY(j) <= MaxY)
                    CutCurve=1;
                    break;
                end
                
                %If the curve point is too sparse
                if j < length(LineX)
                    Dist=sqrt((LineX(j)-LineX(j+1))^2+(LineY(j)-LineY(j+1))^2);
                    
                    if Dist > 3*ImageDataInfo.XPixDim
                        SegNum=round(Dist/(3*ImageDataInfo.XPixDim));
                        
                        if abs(LineX(j+1)-LineX(j)) > 1E-06
                            Increament=(LineX(j+1)-LineX(j))/SegNum;
                            NewLineX=LineX(j):Increament:LineX(j+1);
                        else
                            NewLineX=repmat(LineX(j), [1, SegNum+1]);
                        end
                        
                        if abs(LineY(j+1)-LineY(j)) > 1E-06
                            Increament=(LineY(j+1)-LineY(j))/SegNum;
                            NewLineY=LineY(j):Increament:LineY(j+1);
                        else
                            NewLineY=repmat(LineY(j), [1, SegNum+1]);
                        end
                        
                        for jj=2:length(NewLineX)
                            
                            if (NewLineX(jj) >= MinX) && (NewLineX(jj) <= MaxX) && (NewLineY(jj) >= MinY) && (NewLineY(jj) <= MaxY)
                                CutCurve=1;
                                break;
                            end
                        end
                        
                        if CutCurve > 0
                            break;
                        end
                    end
                    
                end
            end
            
            if CutCurve < 1
                structAxialROI.ZLocation=[structAxialROI.ZLocation; CurrentZLoc];
                structAxialROI.CurvesCor=[structAxialROI.CurvesCor; {[LineX', LineY']}];
                structAxialROI.OrganCurveNum=structAxialROI.OrganCurveNum+1;
            else
                delete(ROIhLine(i));        
            end            
        end
                
        handles.PlansInfo.structAxialROI{PlanIndex}(ROIIndex)=structAxialROI;
        
        guidata(handles.figure1, handles);
    end 
    
end





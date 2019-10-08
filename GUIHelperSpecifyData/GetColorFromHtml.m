function OldColor=GetColorFromHtml(ColorCell)
TempIndexStart=strfind(ColorCell, '(');
TempIndexEnd=strfind(ColorCell, ')');

ColorStr=ColorCell(TempIndexStart(1)+1:TempIndexEnd(1)-1);
ColorStr=[ColorStr, ','];

OldColor = sscanf(ColorStr, ['%d' ',']);
function CenterFig(CFig, PFig)

if nargin > 1
    OldUnit=get(PFig, 'Units');
    set(PFig, 'Units', 'pixels');
    ScreenPos=get(PFig, 'Position');
    set(PFig, 'Units', OldUnit);
else    
    OldUnit=get(0, 'Units');
    set(0, 'Units', 'pixels');
    ScreenPos=get(0, 'ScreenSize');
    set(0, 'Units', OldUnit);
end

OldUnit=get(CFig, 'Units');
set(CFig, 'Units', 'pixels');

PrefacePos=get(CFig, 'Position');

if nargin > 1
    YPos=(ScreenPos(4)-PrefacePos(4))/2;
    XPos=(ScreenPos(3)-PrefacePos(3))/2;
    
    XPos=ScreenPos(1)+XPos;
    YPos=ScreenPos(2)+YPos;
else    
    YPos=(ScreenPos(4)-PrefacePos(4))*2/3;
    XPos=(ScreenPos(3)-PrefacePos(3))/2;
end

pause(0.01);

set(CFig, 'Position', [XPos, YPos, PrefacePos(3), PrefacePos(4)]);
set(CFig, 'Units', OldUnit);


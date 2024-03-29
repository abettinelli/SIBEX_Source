function CenterFigBottomRight(CFig, PFig, XFraction)

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

XPos=ScreenPos(1)+ScreenPos(3)*XFraction;
YPos=ScreenPos(2)-PrefacePos(4);

pause(0.01);

set(CFig, 'Position', [XPos, YPos, PrefacePos(3), PrefacePos(4)]);
set(CFig, 'Units', OldUnit);


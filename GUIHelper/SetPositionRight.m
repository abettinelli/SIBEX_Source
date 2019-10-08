function SetPositionRight(ParentFig, CurrentFig)
OldUnit=get(ParentFig, 'Units');
set(ParentFig, 'Units', 'pixels');
ParentPos=get(ParentFig, 'Position');
set(ParentFig, 'Units', OldUnit);


OldUnit=get(CurrentFig, 'Units');
set(CurrentFig, 'Units', 'pixels');
FigPos=get(CurrentFig,'Position');

set(CurrentFig, 'Position', [ParentPos(1)+ParentPos(3), ParentPos(2)+ParentPos(4)-FigPos(4), FigPos(3), FigPos(4)]);

set(CurrentFig, 'Units', OldUnit);
function ColorStr=GetPinnColor(PinnColorList, Index)
ColorLen=length(PinnColorList);
ColorIndex=rem(Index, ColorLen)+1;
ColorStr=PinnColorList{ColorIndex};
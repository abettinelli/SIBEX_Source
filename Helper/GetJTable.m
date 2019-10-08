function jUITable=GetJTable(UITable)
jScroll = findjobj(UITable);
try jScroll = jScroll(1); jScroll = jScroll.getViewport;  catch, end  % may possibly already be the viewport
try jScroll = jScroll.getComponent(0).getViewport;  catch, end  % HG2
jUITable= jScroll.getView;

%Set Table resize
jUITable.setAutoResizeMode(jUITable.AUTO_RESIZE_SUBSEQUENT_COLUMNS);
jUITable.setColumnResizable(true);
% jUITablePatient.setRowResizable(true);
jUITable.setRowHeight(28);

% jUITablePatient.setRowSelectionAllowed(0);
% jUITablePatient.setColumnSelectionAllowed(0);
% jUITablePatient.setCellSelectionEnabled(0);

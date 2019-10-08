function [CIndex, RIndex] = IBSI_close_ROI(CIndex, RIndex)

if (CIndex(1) ~= CIndex(end)) || (RIndex(1) ~= RIndex(end))
    CIndex(end+1) = CIndex(1);
    RIndex(end+1) = RIndex(1);
end
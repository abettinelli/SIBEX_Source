close all
clear all
clc
rng(1)

CurrentImg = randn(100,100)*5+50;
CurrentMask = randn(100,100) < 1;
CurrentImg_ROI = CurrentImg(CurrentMask == 1);

figure()
hist(CurrentImg(CurrentMask == 1), 500)

Param.RangeMin = min(CurrentImg(CurrentMask == 1));
Param.RangeMax = max(CurrentImg(CurrentMask == 1));

Param.RangeMin = 0;
Param.DynMin = 0;
Param.RangeMax = 100;
Param.DynMin = 1;
Param.BinNumber = 100;
Param.BinSize = 0.5;

InputRange=[Param.RangeMin, Param.RangeMax];

%Filter
idx_min = CurrentImg <= Param.RangeMin;
idx_max = CurrentImg >= Param.RangeMax;
idx = ~idx_min & ~idx_max;

CurrentImg_fbn = CurrentImg;
CurrentImg_fbn(idx_min) = 1;
% CurrentImg_fbn(idx_max) = Param.BinNumber;
% CurrentImg_fbn(idx) = ceil(Param.BinNumber*(CurrentImg(idx)-InputRange(1))/(InputRange(2)-InputRange(1)));

CurrentImg_fbn(idx) = ceil((CurrentImg(idx)-InputRange(1))/Param.BinSize);
CurrentImg_fbn(idx_max) = max(CurrentImg_fbn(idx));

figure()
hist(CurrentImg_fbn(CurrentMask == 1), 0:1:max(CurrentImg_fbn(CurrentMask == 1)))

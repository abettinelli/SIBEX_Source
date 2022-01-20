function monoFilterBank = IBSI2_append_zero_on_even(monoFilterBank)
% correct if even
for i = 1:length(monoFilterBank)
    if mod(length(monoFilterBank{i}),2)==0
        monoFilterBank{i}= [monoFilterBank{i} 0];
    end
end
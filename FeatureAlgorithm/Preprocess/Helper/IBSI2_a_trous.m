function monoFilterBank = IBSI2_a_trous(monoFilterBank, curr_l)

for i = 1:length(monoFilterBank)
    n=(2^(curr_l-1)-1);
    temp = reshape(padarray(monoFilterBank{i},[n 0],0,'post'),1,[]);
    monoFilterBank{i} = temp;
end

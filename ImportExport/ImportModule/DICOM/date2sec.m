function t_seconds = date2sec(curr_Time)
%     ka = length(curr_Time);
    t_seconds = str2double(curr_Time(1:2))*3600 + str2double(curr_Time(3:4))*60 + round(str2double(curr_Time(5:6))); %ka do not consider after seconds
end
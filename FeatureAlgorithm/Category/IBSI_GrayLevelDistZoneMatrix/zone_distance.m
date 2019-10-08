function value = zone_distance(CC)

    global x_distance_map
    distance_map = x_distance_map;
    value = nanmin(distance_map(CC));
end
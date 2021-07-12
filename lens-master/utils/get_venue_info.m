
%% get_venue_info
function [location, mass] = get_venue_info(fullpath, TM_type, width, height)

    if TM_type == '4sq'
        % input_dir = '../processed_data/subtask_process_4sq/TM/';
        [filename, input_dir] = basename(fullpath);
        input_dir = [input_dir '/'];


        if findstr(filename, 'Airport')
            info_file = 'Airport_sorted.txt';
        elseif findstr(filename, 'Austin')
            info_file = 'Austin_sorted.txt';
        elseif findstr(filename, 'Manhattan')
            info_file = 'Manhattan_sorted.txt';
        elseif findstr(filename, 'San_Francisco')
            info_file = 'San_Francisco_sorted.txt';
        end

        % fprintf('  info file = %s\n', [input_dir info_file]);

        fid = fopen([input_dir info_file]);
        c = textscan(fid, '%s%f%f%f', 'Delimiter', '|', 'MultipleDelimsAsOne', 1);
        fclose(fid);
    end

    location = [c{2}, c{3}];
    location = location(1:width, :);
    mass = c{4};
    mass = mass(1:width, :);
end


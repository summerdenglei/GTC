%% --------------------
% 2013/10/06
% Yi-Chao Chen @ UT Austin
%
% TM_to_video
% 
% @input (optional) full_filename: the name of Traffic Matrix
% @input (optional) width: the width of the matrix to output in the video
% @input (optional) height: the height of the matrix to output in the video
% @input (optional) frames: the number of frames will be generated
%
% e.g.
%   TM_to_video('../processed_data/subtask_process_4sq/TM/TM_Airport_period5_', 300, 300, 12)
%   TM_to_video('../processed_data/subtask_inject_error/TM_err/TM_Airport_period5_.exp0.', 300, 300, 12)
%
%% --------------------

function TM_to_video(full_filename, width, height, frames)
    
    addpath('../utils/YUV2Image');
    addpath('../utils/mirt_dctn');
    addpath('../utils/compressive_sensing');
    addpath('../utils');

    
    %% --------------------
    % Debugs
    %% --------------------
    DEBUG0 = 0;     %% don't print 
    DEBUG1 = 1;     %% print 
    DEBUG2 = 1;     %% program flow
    DEBUG3 = 1;     %% output


    %% --------------------
    % Input
    %% --------------------
    if nargin < 1, file_name = 'TM_Airport_period5_'; end
    if nargin < 2, width = 500;                  end
    if nargin < 3, height = 500;                 end
    if nargin < 4, frames = 12;                  end


    %% --------------------
    % Variables
    %% --------------------
    % input_dir = '../processed_data/subtask_process_4sq/TM/';
    % input_dir = '../processed_data/subtask_inject_error/TM_err/';
    [file_name, input_dir] = basename(full_filename);
    input_dir = [input_dir '/'];
    output_dir = '../processed_data/subtask_TM_to_video/video/';
    fh = fopen([output_dir, file_name '.yuv'], 'w');


    %% --------------------
    % Main starts here
    %% --------------------
    for this_frame = [1:frames]
        this_file_name = [file_name, int2str(this_frame-1), '.txt'];

        if DEBUG2 == 1
            fprintf('frame %d: \n  start to load TM: %s\n', this_frame, [input_dir, this_file_name]);
        end

        data = load([input_dir, this_file_name]);

        %% 1st byte to V, 2nd to U, 3rd to V
        % frame_y = mod(data(1:width, 1:height), 256);
        % frame_u = mod(floor(data(1:width, 1:height) ./ 256), 256);
        % frame_v = floor(data(1:width, 1:height) ./ 65536);
        % buf = reshape(frame_y, [], 1);
        % count = fwrite(fh, buf, 'uchar');
        % buf = reshape(frame_u, [], 1);
        % count = fwrite(fh, buf, 'uchar');
        % buf = reshape(frame_v, [], 1);
        % count = fwrite(fh, buf, 'uchar');
        
        frame_data = data(1:width, 1:height);
        buf = reshape(frame_data, [], 1);
        count = fwrite(fh, buf, 'uchar');

        frame_uv = zeros(width/2, height/2);
        buf = reshape(frame_uv, [], 1);
        count = fwrite(fh, buf, 'uchar');
        count = fwrite(fh, buf, 'uchar');
    end
    
    fclose(fh);

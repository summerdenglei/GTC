%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Yi-Chao Chen
%% 2013.10.08 @ UT Austin
%%
%% - Input:
%%
%% - Output:
%%
%% e.g. 
%%     diff_orig_comp_video('/u/yichao/anomaly_compression/data/video/bus_cif.yuv', '/u/yichao/anomaly_compression/processed_data/video/bus_cif.b100.mpeg_dec.yuv', 150, 352, 288)
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [] = diff_orig_comp_video(orig_name, comp_name, num_frames, width, height)
    addpath('../utils/YUV2Image');
    addpath('../utils/mirt_dctn');
    addpath('../utils');


    %% --------------------
    %% DEBUG
    %% --------------------
    DEBUG0 = 0;
    DEBUG1 = 1;
    DEBUG2 = 1;


    %% --------------------
    %% Variable
    %% --------------------
    input_dir  = '';
    output_dir = '../processed_data/subtask_detect_anomaly/errs/';

    [base_orig_name, dir_orig_name] = basename(orig_name);
    [base_comp_name, dir_comp_name] = basename(comp_name);

    if DEBUG2
        fprintf('orig video: %s\n', base_orig_name);
        fprintf('comp video: %s\n', base_comp_name);
    end
    % return;

    %% --------------------
    %% main starts here
    %% --------------------
    mov1 = loadFileYuv(orig_name, width, height, 1:num_frames);
    mov2 = loadFileYuv(comp_name, width, height, 1:num_frames);


    if DEBUG2
        fprintf('calculate errors:\n');
    end

    errs = zeros(num_frames*width*height, 3);
    for f = 1:num_frames
        if DEBUG0, fprintf('  frame %d:\n', f); end

        imgYuv1 = mov1(f).imgYuv;
        imgYuv2 = mov2(f).imgYuv;

        start_ind = (f-1)*width*height + 1;
        end_ind   = f*width*height;
        if DEBUG0
            fprintf('  %d - %d\n', start_ind, end_ind);
        end
        
        errs(start_ind:end_ind, 1) = reshape(abs(imgYuv1(:,:,1)' - imgYuv2(:,:,1)'), [], 1);
        errs(start_ind:end_ind, 2) = reshape(abs(imgYuv1(:,:,2)' - imgYuv2(:,:,2)'), [], 1);
        errs(start_ind:end_ind, 3) = reshape(abs(imgYuv1(:,:,3)' - imgYuv2(:,:,3)'), [], 1);
    end


    %% --------------------
    %% write errs to the file
    %% --------------------
    errs_file = [output_dir base_comp_name '.txt'];
    if DEBUG2
        fprintf('write errs to the file: %s\n', errs_file);
    end
    dlmwrite(errs_file, errs);
end

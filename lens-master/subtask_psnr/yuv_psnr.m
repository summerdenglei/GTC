%% --------------------
% 2013/09/24
% Yi-Chao Chen @ UT Austin
%
% yuv_psnr
% 
% @input (optional) video_name1: the name of YUV video 1 (assume the video format: YUV CIF 4:2:0)
% @input (optional) video_name2: the name of YUV video 2 (assume the video format: YUV CIF 4:2:0)
% @input (optional) frames: number of frames to analyze
% @input (optional) width: the width of the video
% @input (optional) height: the height of the video
%
% e.g.
%   yuv_psnr('~/anomaly_compression/data/video/stefan_cif.yuv', '~/anomaly_compression/processed_data/video/stefan_cif.avi_dec.yuv')
%   yuv_psnr('~/anomaly_compression/data/video/stefan_cif.yuv', '~/anomaly_compression/processed_data/video/stefan_cif.mpeg_dec.yuv')
%
%% --------------------

function [psnr] = yuv_psnr(video_name1, video_name2, frames, width, height)
    addpath('../utils/YUV2Image');
    addpath('../utils');

    %% --------------------
    % Debugs
    %% --------------------
    DEBUG0 = 0;     %% don't print 
    DEBUG1 = 1;     %% print 
    DEBUG2 = 0;     %% program flow
    DEBUG3 = 0;     %% output


    %% --------------------
    % Input
    %% --------------------
    if nargin == 2
        frames = 90;
        width = 352;
        height = 288;
    end


    %% --------------------
    % Variables
    %% --------------------
    

    %% --------------------
    % Main starts here
    %% --------------------
    mov1 = loadFileYuv(video_name1, width, height, 1:frames);
    mov2 = loadFileYuv(video_name2, width, height, 1:frames);
    if DEBUG2 == 1
        fprintf('  done loading.\n');
    end

    psnr = calculate_psnr(mov1, mov2, frames);

    if DEBUG3 == 1
        fprintf('PSNR=%f\n', psnr);
    end

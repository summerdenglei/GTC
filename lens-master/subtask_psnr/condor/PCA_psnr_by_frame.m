%% --------------------
% 2013/09/24
% Yi-Chao Chen @ UT Austin
%
% PCA_psnr_by_frame
% 
% @input (optional) num_PC: num of PCs to use (i.e. rank)
% @input (optional) dct_thresh: when the value after DCT <= dct_thresh, make it 0
% @input (optional) group_size: group x frames to do PCA
% @input (optional) video_name: the name of raw video (assume the video format: YUV CIF 4:2:0)
% @input (optional) frames: number of frames to analyze
% @input (optional) width: the width of the video
% @input (optional) height: the height of the video
%
% note
% - stefan_cif.yuv
%   CIF, YCbCr 4:2:0 planar 8 bit, 352*288, 90 frames
% - bus_cif.yuv
%   CIF, YCbCr 4:2:0 planar 8 bit, 352*288, 150 frames
%
%% --------------------

function [psnr, compressed_ratio] = PCA_psnr(num_PC, dct_thresh, group_size, video_name, frames, width, height)
    addpath('/u/yichao/anomaly_compression/utils/YUV2Image');
    addpath('/u/yichao/anomaly_compression/utils/mirt_dctn');
    addpath('/u/yichao/anomaly_compression/utils');
    addpath('/u/yichao/anomaly_compression/subtask_psnr');

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
    if nargin == 3
        video.file = 'stefan_cif.yuv';
        video.frames = 90;  %% 90
        video.width = 352;
        video.height = 288;
    elseif nargin == 7
        video.file = video_name;
        video.frames = frames;
        video.width = width;
        video.height = height;
    else
        num_PC = 288;
        dct_thresh = 0;
        group_size = 1;
        video.file = 'stefan_cif.yuv';
        video.frames = 90;  %% 90
        video.width = 352;
        video.height = 288;
    end


    %% --------------------
    % Variables
    %% --------------------
    input_dir = '/u/yichao/anomaly_compression/condor_data/subtask_TM_to_video/video/';
    output_dir = '/u/yichao/anomaly_compression/condor_data/subtask_psnr/comp_video/';
    

    %% --------------------
    % Main starts here
    %% --------------------
    if DEBUG2 == 1
        fprintf('start to load video: %s\n', [input_dir, video.file]);
    end

    mov = loadFileYuv([input_dir, video.file], video.width, video.height, 1:video.frames);
    if DEBUG2 == 1
        fprintf('  done loading.\n');
    end


    %% --------------------
    %  Loop over the frames
    %% --------------------
    compressed_size = 0;
    group_raw_video_vector_y = zeros(video.width, video.height * group_size);
    group_raw_video_vector_u = zeros(video.width, video.height * group_size);
    group_raw_video_vector_v = zeros(video.width, video.height * group_size);

    for k = 1:video.frames
        if DEBUG2
            fprintf('frame %d\n', k);
        end

        % [h, w, p] = size(mov(k).cdata);
        imgYuv = mov(k).imgYuv;
        [h, w, p] = size(imgYuv);

        if DEBUG0 == 1
            fprintf('frame %d: w=%d, h=%d, p=%d\n', k, w, h, p);
        end


        %% --------------------
        %% group video every "group_size" frames
        %% --------------------
        g_ind = mod(k-1, group_size) + 1;
        height_start = (g_ind-1) * video.height + 1;
        height_end   = g_ind * video.height;
        
        
        group_raw_video_vector_y(:, height_start:height_end) = imgYuv(:,:,1)';
        group_raw_video_vector_u(:, height_start:height_end) = imgYuv(:,:,2)';
        group_raw_video_vector_v(:, height_start:height_end) = imgYuv(:,:,3)';



        if g_ind ~= group_size & k ~= video.frames
            %% not enough frames for this group
            continue;
        end


        %% with enough frames for this group
        group_width = video.width;
        group_height = video.height * g_ind;

        %% resize the matrix due to the last group may not have enough frames
        group_raw_video_vector_y = group_raw_video_vector_y(:, 1:group_height);
        group_raw_video_vector_u = group_raw_video_vector_u(:, 1:group_height);
        group_raw_video_vector_v = group_raw_video_vector_v(:, 1:group_height);
        

        %% --------------------
        %  DCT
        %% --------------------
        group_raw_video_vector_y = mirt_dctn(group_raw_video_vector_y);
        group_raw_video_vector_u = mirt_dctn(group_raw_video_vector_u);
        group_raw_video_vector_v = mirt_dctn(group_raw_video_vector_v);


        %% --------------------
        %  values after DCT < dct_thresh, make them 0
        %% --------------------
        group_raw_video_vector_y(abs(group_raw_video_vector_y) < dct_thresh) = 0;
        group_raw_video_vector_u(abs(group_raw_video_vector_u) < dct_thresh) = 0;
        group_raw_video_vector_v(abs(group_raw_video_vector_v) < dct_thresh) = 0;



        rank_y = min(rank(group_raw_video_vector_y), num_PC);
        rank_u = min(rank(group_raw_video_vector_u), num_PC);
        rank_v = min(rank(group_raw_video_vector_v), num_PC);

        if DEBUG0
            fprintf('  rank = (%d, %d, %d)\n', rank_y, rank_u, rank_v);
        end


        %% --------------------
        %  PCA
        %% --------------------
        [latent_y, U_y, eigenvector_y] = calculate_PCA(group_raw_video_vector_y);
        [latent_u, U_u, eigenvector_u] = calculate_PCA(group_raw_video_vector_u);
        [latent_v, U_v, eigenvector_v] = calculate_PCA(group_raw_video_vector_v);


        %% --------------------
        %  Compressed video:
        %% --------------------
        compressed_video_vector_y = PCA_compress(latent_y, U_y, eigenvector_y, rank_y);
        compressed_video_vector_u = PCA_compress(latent_u, U_u, eigenvector_u, rank_u);
        compressed_video_vector_v = PCA_compress(latent_v, U_v, eigenvector_v, rank_v);
        compressed_size = compressed_size + (1 + group_width + group_height) * (rank_y + rank_u + rank_v);


        %% --------------------
        %  Inverse DCT
        %% --------------------
        compressed_video_vector_y = mirt_idctn(compressed_video_vector_y);
        compressed_video_vector_u = mirt_idctn(compressed_video_vector_u);
        compressed_video_vector_v = mirt_idctn(compressed_video_vector_v);


        %% --------------------
        %% ungroup the matrix
        %% --------------------
        this_group_size = group_size;
        if k == video.frames
            this_group_size = mod(k-1, group_size)+1;
        end


        for this_k = (k-this_group_size+1:k)
            if DEBUG2
                fprintf('  ungroup frame %d\n', this_k);
            end

            this_g_ind = mod(this_k-1, group_size) + 1;
            this_height_start = (this_g_ind-1) * video.height + 1;
            this_height_end   = this_g_ind * video.height;

            compressed_mov(this_k).imgYuv(:,:,1) = compressed_video_vector_y(:, this_height_start:this_height_end)';
            compressed_mov(this_k).imgYuv(:,:,2) = compressed_video_vector_u(:, this_height_start:this_height_end)';
            compressed_mov(this_k).imgYuv(:,:,3) = compressed_video_vector_v(:, this_height_start:this_height_end)';

        end

    end %% end for all frames

    %% --------------------
    %  save file
    %% --------------------
    saveFileYuv2(compressed_mov, [output_dir video_name '.PCA.' int2str(group_size) '.' int2str(num_PC) '.' int2str(dct_thresh) '.' int2str(video.frames) '.' int2str(video.width) '.' int2str(video.height) '.yuv'], 'w');

    %% --------------------
    %  PSNR
    %% --------------------
    psnr = calculate_psnr(mov, compressed_mov, video.frames);
    original_size = video.frames * video.width * video.height * 3;
    compressed_ratio = compressed_size / original_size;

    if DEBUG3 == 1
        fprintf('size=%d/%d=%f, PSNR=%f\n', compressed_size, original_size, compressed_ratio, psnr);
    end


end


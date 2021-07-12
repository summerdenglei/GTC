%% --------------------
% 2013/10/04
% Yi-Chao Chen @ UT Austin
%
% DCT_psnr
% 
% @input (optional) num_chunks: num of chunks to have per GoP
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

function [psnr, compressed_ratio] = DCT_psnr(num_chunks, group_size, video_name, frames, width, height)
    addpath('/u/yichao/anomaly_compression/utils/YUV2Image');
    addpath('/u/yichao/anomaly_compression/utils/mirt_dctn');
    addpath('/u/yichao/anomaly_compression/utils');

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
    if nargin == 2
        video.file = 'stefan_cif.yuv';
        video.frames = 90;  %% 90
        video.width = 352;
        video.height = 288;
    elseif nargin == 6
        video.file = video_name;
        video.frames = frames;
        video.width = width;
        video.height = height;
    else
        group_size = 4;
        num_chunks = 64 * group_size;
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
    chunk_width = 50;
    chunk_height = 50;
    num_chunk_w = video.width / chunk_width;
    num_chunk_h = video.height / chunk_height;
        
    

    % [x, y, z] = convert_3d_ind(8, 8, 4, 256)
    % return


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
    group_raw_video_y = zeros(video.width, video.height, group_size);
    group_raw_video_u = zeros(video.width, video.height, group_size);
    group_raw_video_v = zeros(video.width, video.height, group_size);

    for k = 1:video.frames
        % [h, w, p] = size(mov(k).cdata);
        imgYuv = mov(k).imgYuv;
        [h, w, p] = size(imgYuv);

        if DEBUG1 == 1
            fprintf('frame %d: w=%d, h=%d, p=%d\n', k, w, h, p);
        end


        %% --------------------
        %% group video every "group_size" frames
        %% --------------------
        g_ind = mod(k-1, group_size) + 1;
        
        group_raw_video_y(:, :, g_ind) = imgYuv(:,:,1)';
        group_raw_video_u(:, :, g_ind) = imgYuv(:,:,2)';
        group_raw_video_v(:, :, g_ind) = imgYuv(:,:,3)';


        if g_ind ~= group_size & k ~= video.frames
            %% not enough frames for this group
            continue;
        end


        %% The last group may not have enough frames
        %%   make those values 0 
        if k == video.frames
            group_raw_video_y(:, :, g_ind+1:group_size) = 0;
            group_raw_video_u(:, :, g_ind+1:group_size) = 0;
            group_raw_video_v(:, :, g_ind+1:group_size) = 0;
        end



        %% --------------------
        %% 3D DCT
        %% --------------------
        group_dct_y = mirt_dctn(group_raw_video_y);
        group_dct_u = mirt_dctn(group_raw_video_u);
        group_dct_v = mirt_dctn(group_raw_video_v);


        %% --------------------
        %% bit map of DCT
        %% --------------------
        if DEBUG2 == 1
            fprintf('  bit map of DCT: \n');
        end

        bit_map_y = zeros(num_chunk_w, num_chunk_h, group_size);
        bit_map_u = zeros(num_chunk_w, num_chunk_h, group_size);
        bit_map_v = zeros(num_chunk_w, num_chunk_h, group_size);

        %% the bit map will increase the size of the compressed video
        compressed_size = compressed_size + (num_chunk_w*num_chunk_h*group_size*3)/8;

        for chunk_w_ind = [1:num_chunk_w]
            w_start = (chunk_w_ind-1) * chunk_width + 1;
            w_end   = chunk_w_ind * chunk_width;

            for chunk_h_ind = [1:num_chunk_h]
                h_start = (chunk_h_ind-1) * chunk_height + 1;
                h_end   = chunk_h_ind * chunk_height;

                for chunk_f_ind = [1:group_size]
                    %% what if this chunk is remove
                    tmp_group_dct_y = group_dct_y;
                    tmp_group_dct_u = group_dct_u;
                    tmp_group_dct_v = group_dct_v;
                    tmp_group_dct_y(w_start:w_end, h_start:h_end, chunk_f_ind) = 0;
                    tmp_group_dct_u(w_start:w_end, h_start:h_end, chunk_f_ind) = 0;
                    tmp_group_dct_v(w_start:w_end, h_start:h_end, chunk_f_ind) = 0;

                    %% inverted dct
                    tmp_group_idct_y = mirt_idctn(tmp_group_dct_y);
                    tmp_group_idct_u = mirt_idctn(tmp_group_dct_u);
                    tmp_group_idct_v = mirt_idctn(tmp_group_dct_v);

                    %% calculate the error
                    bit_map_y(chunk_w_ind, chunk_h_ind, chunk_f_ind) = sum((double(tmp_group_idct_y(:)) - double(group_raw_video_y(:))) .^ 2);
                    bit_map_u(chunk_w_ind, chunk_h_ind, chunk_f_ind) = sum((double(tmp_group_idct_u(:)) - double(group_raw_video_u(:))) .^ 2);
                    bit_map_v(chunk_w_ind, chunk_h_ind, chunk_f_ind) = sum((double(tmp_group_idct_v(:)) - double(group_raw_video_v(:))) .^ 2);


                    if DEBUG1 == 1
                        fprintf('  w=%d, h=%d, f=%d: err_y=%f, err_u=%f, err_v=%f\n', chunk_w_ind, chunk_h_ind, chunk_f_ind, bit_map_y(chunk_w_ind, chunk_h_ind, chunk_f_ind), bit_map_u(chunk_w_ind, chunk_h_ind, chunk_f_ind), bit_map_v(chunk_w_ind, chunk_h_ind, chunk_f_ind));
                    end
                end
            end
        end


        %% --------------------
        %% sort bit map to find the max ones
        %% --------------------
        selected_group_dct_y = zeros(video.width, video.height, group_size);
        selected_group_dct_u = zeros(video.width, video.height, group_size);
        selected_group_dct_v = zeros(video.width, video.height, group_size);

        [err_sort, err_ind_sort] = sort([bit_map_y(:); bit_map_u(:); bit_map_v(:)], 'descend');
        for selected_ind = [1:min(num_chunks, length(err_sort))]
            this_ind = err_ind_sort(selected_ind);
            yuv_ind = floor( (this_ind - 1) / (num_chunk_w*num_chunk_h*group_size) ) + 1;
            this_ind_yuv = mod(this_ind - 1, num_chunk_w*num_chunk_h*group_size) + 1;
            [chunk_ind_x, chunk_ind_y, chunk_ind_z] = convert_3d_ind(num_chunk_w, num_chunk_h, group_size, this_ind_yuv);

            %% size of the compressed video
            if err_sort(this_ind) ~= 0
                compressed_size = compressed_size + chunk_width * chunk_height;

                if DEBUG1
                    fprintf('- ind = %d, err = %f, compressed size = %10.2f\n', selected_ind, err_sort(selected_ind), compressed_size);
                end
            end

            w_start = (chunk_ind_x-1) * chunk_width + 1;
            w_end   = chunk_ind_x * chunk_width;

            h_start = (chunk_ind_y-1) * chunk_height + 1;
            h_end   = chunk_ind_y * chunk_height;

            if DEBUG1
                fprintf('  ind=%d, yuv=%d, ind_yuv=%d, (w, h f) = (%d, %d, %d), chunk (x, y, z) = (%d, %d, %d), w=%d:%d, h=%d:%d\n', this_ind, yuv_ind, this_ind_yuv, num_chunk_w, num_chunk_h, group_size, chunk_ind_x, chunk_ind_y, chunk_ind_z, w_start, w_end, h_start, h_end);
            end

            if yuv_ind == 1
                selected_group_dct_y(w_start:w_end, h_start:h_end, chunk_ind_z) = group_dct_y(w_start:w_end, h_start:h_end, chunk_ind_z);

            elseif yuv_ind == 2
                selected_group_dct_u(w_start:w_end, h_start:h_end, chunk_ind_z) = group_dct_u(w_start:w_end, h_start:h_end, chunk_ind_z);
            else
                selected_group_dct_v(w_start:w_end, h_start:h_end, chunk_ind_z) = group_dct_v(w_start:w_end, h_start:h_end, chunk_ind_z);
            end
        end


        %% --------------------
        %  Inverse DCT
        %% --------------------
        compressed_video_y = mirt_idctn(selected_group_dct_y);
        compressed_video_u = mirt_idctn(selected_group_dct_u);
        compressed_video_v = mirt_idctn(selected_group_dct_v);


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
        
            compressed_mov(this_k).imgYuv(:,:,1) = compressed_video_y(:, :, this_g_ind)';
            compressed_mov(this_k).imgYuv(:,:,2) = compressed_video_u(:, :, this_g_ind)';
            compressed_mov(this_k).imgYuv(:,:,3) = compressed_video_v(:, :, this_g_ind)';
        end

    end %% end for all frames


    %% --------------------
    %  save file
    %% --------------------
    saveFileYuv2(compressed_mov, [output_dir video_name '.3DDCT.' int2str(group_size) '.' int2str(num_chunks) '.' int2str(video.frames) '.' int2str(video.width) '.' int2str(video.height) '.yuv'], 'w');
    

    %% --------------------
    %  PSNR
    %% --------------------
    psnr = calculate_psnr(mov, compressed_mov, video.frames);
    original_size = video.frames * video.width * video.height * 3;
    compressed_ratio = compressed_size / original_size;

    if DEBUG3 == 1
        fprintf('size=%10.9f/%d=%f, PSNR=%f\n', compressed_size, original_size, compressed_ratio, psnr);
    end


end


%% convert_3d_ind
function [x, y, z] = convert_3d_ind(w, h, f, line_ind)
    z = floor( (line_ind - 1) / (w*h)) + 1;
    y = floor( (line_ind - (z-1) * (w*h) - 1 ) / w) + 1;
    x = floor( (line_ind - (z-1) * (w*h) - (y-1) * w) );
end
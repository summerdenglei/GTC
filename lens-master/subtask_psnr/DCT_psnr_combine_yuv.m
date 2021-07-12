%% --------------------
% 2013/10/05
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

function [psnr, compressed_ratio] = DCT_psnr_combine_yuv(num_chunks, group_size, video_name, frames, width, height)
    addpath('../utils/YUV2Image');
    addpath('../utils/mirt_dctn');
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
    input_dir = '../data/video/';
    chunk_width = 44;
    chunk_height = 36;
    % chunk_width = 352;
    % chunk_height = 288;
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
    group_raw_video = zeros(video.width, video.height, group_size, 3);
    
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
        
        group_raw_video(:, :, g_ind, 1) = imgYuv(:,:,1)';
        group_raw_video(:, :, g_ind, 2) = imgYuv(:,:,2)';
        group_raw_video(:, :, g_ind, 3) = imgYuv(:,:,3)';


        if g_ind ~= group_size & k ~= video.frames
            %% not enough frames for this group
            continue;
        end


        %% The last group may not have enough frames
        %%   make those values 0 
        if k == video.frames
            group_raw_video(:, :, g_ind+1:group_size) = 0;
            group_raw_video(:, :, g_ind+1:group_size) = 0;
            group_raw_video(:, :, g_ind+1:group_size) = 0;
        end



        %% --------------------
        %% 3D DCT
        %% --------------------
        group_dct = mirt_dctn(group_raw_video);
        

        %% --------------------
        %% bit map of DCT
        %% --------------------
        if DEBUG2 == 1
            fprintf('  bit map of DCT: \n');
        end

        bit_map = zeros(num_chunk_w, num_chunk_h, group_size, 3);
        
        %% the bit map will increase the size of the compressed video
        compressed_size = compressed_size + (num_chunk_w*num_chunk_h*group_size*3)/8;

        for chunk_w_ind = [1:num_chunk_w]
            w_start = (chunk_w_ind-1) * chunk_width + 1;
            w_end   = chunk_w_ind * chunk_width;

            for chunk_h_ind = [1:num_chunk_h]
                h_start = (chunk_h_ind-1) * chunk_height + 1;
                h_end   = chunk_h_ind * chunk_height;

                for chunk_f_ind = [1:group_size]
                    for yuv_ind = [1:3]

                        %% what if this chunk is remove
                        tmp_group_dct = group_dct;
                        tmp_group_dct(w_start:w_end, h_start:h_end, chunk_f_ind, yuv_ind) = 0;
                    
                        %% inverted dct
                        tmp_group_idct = mirt_idctn(tmp_group_dct);
                    
                        %% calculate the error
                        bit_map(chunk_w_ind, chunk_h_ind, chunk_f_ind, yuv_ind) = sum((double(tmp_group_idct(:)) - double(group_raw_video(:))) .^ 2);
                    
                        if DEBUG1 == 1
                            fprintf('  w=%d, h=%d, f=%d, yuv=%d: err=%f\n', chunk_w_ind, chunk_h_ind, chunk_f_ind, yuv_ind, bit_map(chunk_w_ind, chunk_h_ind, chunk_f_ind, yuv_ind));
                        end
                    end
                end
            end
        end


        %% --------------------
        %% sort bit map to find the max ones
        %% --------------------
        selected_group_dct = zeros(video.width, video.height, group_size, 3);

        [err_sort, err_ind_sort] = sort(bit_map(:), 'descend');
        for selected_ind = [1:min(num_chunks, length(err_sort))]
            this_ind = err_ind_sort(selected_ind);
            [chunk_ind_x, chunk_ind_y, chunk_ind_z, chunk_ind_m] = convert_4d_ind(num_chunk_w, num_chunk_h, group_size, 3, this_ind);

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
                fprintf('  ind=%d, (w, h f) = (%d, %d, %d), chunk (x, y, z, m) = (%d, %d, %d, %d), w=%d:%d, h=%d:%d\n', this_ind, num_chunk_w, num_chunk_h, group_size, chunk_ind_x, chunk_ind_y, chunk_ind_z, chunk_ind_m, w_start, w_end, h_start, h_end);
            end

            selected_group_dct(w_start:w_end, h_start:h_end, chunk_ind_z, chunk_ind_m) = group_dct(w_start:w_end, h_start:h_end, chunk_ind_z, chunk_ind_m);
        end


        %% --------------------
        %  Inverse DCT
        %% --------------------
        compressed_video = mirt_idctn(selected_group_dct);
        

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
        
            compressed_mov(this_k).imgYuv(:,:,1) = compressed_video(:, :, this_g_ind, 1)';
            compressed_mov(this_k).imgYuv(:,:,2) = compressed_video(:, :, this_g_ind, 2)';
            compressed_mov(this_k).imgYuv(:,:,3) = compressed_video(:, :, this_g_ind, 3)';
        end

    end %% end for all frames

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
function [x, y, z, m] = convert_4d_ind(w, h, f, yuv, line_ind)
    m = floor( (line_ind - 1) / (w*h*f)) + 1;
    z = floor( (line_ind - (m-1) * (w*h*f) - 1 ) / (w*h)) + 1;
    y = floor( (line_ind - (m-1) * (w*h*f) - (z-1) * (w*h) - 1 ) / w ) + 1;
    x = floor( (line_ind - (m-1) * (w*h*f) - (z-1) * (w*h) - (y-1) * w ) );
end
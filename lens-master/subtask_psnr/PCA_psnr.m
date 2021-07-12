%% --------------------
% 2013/09/24
% Yi-Chao Chen @ UT Austin
%
% PCA_psnr
% 
% @input (optional) num_PC: num of PCs to use (i.e. rank)
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

function PCA_psnr(num_PC, video_name, frames, width, height)
    addpath('../utils/YUV2Image');
    addpath('../utils/mirt_dctn');
    addpath('../utils');

    %% --------------------
    % Debugs
    %% --------------------
    DEBUG0 = 0;     %% don't print 
    DEBUG1 = 1;     %% print 
    DEBUG2 = 0;     %% program flow


    %% --------------------
    % Input
    %% --------------------
    if nargin == 1
        video.file = 'stefan_cif.yuv';
        video.frames = 90;  %% 90
        video.width = 352;
        video.height = 288;
    elseif nargin == 4
        video.file = video_name;
        video.frames = frames;
        video.width = width;
        video.height = height;
    else
        num_PC = 90;
        video.file = 'stefan_cif.yuv';
        video.frames = 90;  %% 90
        video.width = 352;
        video.height = 288;
    end


    %% --------------------
    % Variables
    %% --------------------
    input_dir = '../data/video/';
    raw_video_vector = zeros(video.frames, video.width * video.height * 3);
    % num_PCs = [1 50 video.frames-1];
    num_PCs = [num_PC];
    frag_size = 90;
    

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
    for k = 1:video.frames  
        % [h, w, p] = size(mov(k).cdata);
        imgYuv = mov(k).imgYuv;
        [h, w, p] = size(imgYuv);
        raw_video_vector(k, :) = reshape(imgYuv, 1, h*w*p);

        if DEBUG0 == 1
            fprintf('frame %d: w=%d, h=%d, p=%d\n', k, w, h, p);
        end


        %% --------------------
        %  DEBUG:
        %    find out the max values of YUV
        if DEBUG0 == 1
            max_y = max(max(imgYuv(:,:,1)));
            max_u = max(max(imgYuv(:,:,2)));
            max_v = max(max(imgYuv(:,:,3)));
            fprintf('  max y = %d, u = %d, v =%d\n', max_y, max_u, max_v);
        end
        %% --------------------

    end %% end for all frames


    %% --------------------
    %  fragment the complete video
    %% --------------------
    num_frag = ceil(size(raw_video_vector, 2) / frag_size);

    if DEBUG0
        size(raw_video_vector, 2)
        frag_size
        num_frag
    end

    for frag_i = [1:num_frag]

        start_ind = (frag_i-1) * frag_size + 1;
        if frag_i == num_frag
            end_ind = size(raw_video_vector, 2);
        else
            end_ind = (frag_i) * frag_size;
        end

        if DEBUG0
            fprintf('  frag %d: %d~%d\n', frag_i, start_ind, end_ind);
        end

        fragments(frag_i).raw_video_vector = raw_video_vector(:, start_ind:end_ind);


        %% --------------------
        %  PCA
        %% --------------------
        if DEBUG0 == 1
            fprintf('calculate PCA:\n');
        end

        [fragments(frag_i).latent, ...
         fragments(frag_i).U, ...
         fragments(frag_i).eigenvector] = calculate_PCA(fragments(frag_i).raw_video_vector);


        cnt_r = 1;
        for r = num_PCs
            %% --------------------
            %  Compressed video:
            %% --------------------
            this_r = min(r, length(fragments(frag_i).latent));
            pc(cnt_r).compressed_video_vector = PCA_compress(fragments(frag_i).latent, fragments(frag_i).U, fragments(frag_i).eigenvector, this_r);
            
            if frag_i == 1
                pc(cnt_r).compressed_size = (1 + video.frames + frag_size) * this_r;
            else
                pc(cnt_r).compressed_size = pc(cnt_r).compressed_size + (1 + video.frames + frag_size) * this_r;
            end

            cnt_r = cnt_r + 1;
        end
        fragments(frag_i).pc = pc;
    end


    cnt_r = 1;
    for r = num_PCs
        %% --------------------
        %  assemble fragments
        %% --------------------
        compressed_video_vector = zeros(size(raw_video_vector));
        compressed_size = 0;
        for frag_i = [1:num_frag]
            start_ind = (frag_i-1) * frag_size + 1;
            if frag_i == num_frag
                end_ind = size(raw_video_vector, 2);
            else
                end_ind = (frag_i) * frag_size;
            end

            pc = fragments(frag_i).pc;
            
            compressed_video_vector(:, start_ind:end_ind) = pc(cnt_r).compressed_video_vector;
            compressed_size = pc(cnt_r).compressed_size;
        end

        for k = 1:video.frames
            compressed_mov(k).imgYuv = reshape(compressed_video_vector(k, :), video.height, video.width, 3);
        end


        %% --------------------
        %  PSNR
        %% --------------------
        psnr = calculate_psnr(mov, compressed_mov, video.frames);
        fprintf('r=%d, size=%d, PSNR=%f\n', r, compressed_size, psnr);

        cnt_r = cnt_r + 1;
    end

end


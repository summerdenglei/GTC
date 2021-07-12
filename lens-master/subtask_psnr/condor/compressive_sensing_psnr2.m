%% --------------------
% 2013/09/24
% Yi-Chao Chen @ UT Austin
%
% compressive_sensing_psnr2
% 
% @input (optional) r: rank
% @input (optional) group_size: group x frames to do PCA
% @input (optional) video_name: the name of raw video (assume the video format: YUV CIF 4:2:0)
% @input (optional) frames: number of frames to analyze
% @input (optional) width: the width of the video
% @input (optional) height: the height of the video
%
%% --------------------

function [psnr_srmf, compressed_ratio_srmf, psnr_base, compressed_ratio_base] = compressive_sensing_psnr2(r, group_size, video_name, frames, width, height)
    addpath('/u/yichao/anomaly_compression/utils/YUV2Image');
    addpath('/u/yichao/anomaly_compression/utils/mirt_dctn');
    addpath('/u/yichao/anomaly_compression/utils/compressive_sensing');
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
        r = 5;
        group_size = 4;
        video.file = 'stefan_cif.yuv';
        video.frames = 90;  %% 90
        video.width = 352;
        video.height = 288;
    end


    %% --------------------
    % Variables
    %% --------------------
    input_dir = '/u/yichao/anomaly_compression/condor_data/video/';
    

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
    compressed_size_base = 0;
    compressed_size_srmf = 0;
    group_raw_video_vector_y = zeros(video.width, video.height, group_size);
    group_raw_video_vector_u = zeros(video.width, video.height, group_size);
    group_raw_video_vector_v = zeros(video.width, video.height, group_size);

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
        
        group_raw_video_vector_y(:, :, g_ind) = imgYuv(:,:,1)';
        group_raw_video_vector_u(:, :, g_ind) = imgYuv(:,:,2)';
        group_raw_video_vector_v(:, :, g_ind) = imgYuv(:,:,3)';



        if g_ind ~= group_size & k ~= video.frames
            %% not enough frames for this group
            continue;
        end


        %% The last group may not have enough frames
        %%   make those values 0 
        if k == video.frames & g_ind ~= group_size
            if DEBUG2
                fprintf('  not enough frames\n');
            end

            group_raw_video_y(:, :, g_ind+1:group_size) = 0;
            group_raw_video_u(:, :, g_ind+1:group_size) = 0;
            group_raw_video_v(:, :, g_ind+1:group_size) = 0;
        end
        

        %% --------------------
        %  DCT
        %% --------------------
        % group_raw_video_vector_y = mirt_dctn(group_raw_video_vector_y);
        % group_raw_video_vector_u = mirt_dctn(group_raw_video_vector_u);
        % group_raw_video_vector_v = mirt_dctn(group_raw_video_vector_v);



        %% --------------------
        %  Compressive Sensing
        %% --------------------
        rank_y = r; %min(r, rank(group_raw_video_vector_y));
        rank_u = r; %min(r, rank(group_raw_video_vector_u));
        rank_v = r; %min(r, rank(group_raw_video_vector_v));
        lambda = 0.01;

        meanY2 = mean(group_raw_video_vector_y(:).^2);
        meanY = mean(group_raw_video_vector_y(:));
        meanU2 = mean(group_raw_video_vector_u(:).^2);
        meanU = mean(group_raw_video_vector_u(:));
        meanV2 = mean(group_raw_video_vector_v(:).^2);
        meanV = mean(group_raw_video_vector_v(:));
        sx = size(group_raw_video_vector_y);
        nx = prod(sx);
        n  = length(sx);

        M = ones(sx);

        if DEBUG2
            fprintf('  - base\n');
        end
        [A_y, b_y] = XM2Ab(group_raw_video_vector_y, M);
        [A_u, b_u] = XM2Ab(group_raw_video_vector_u, M);
        [A_v, b_v] = XM2Ab(group_raw_video_vector_v, M);
        BaseY = EstimateBaseline(A_y,b_y,sx);
        BaseU = EstimateBaseline(A_u,b_u,sx);
        BaseV = EstimateBaseline(A_v,b_v,sx);
        compressed_size_base = compressed_size_base + prod(size(BaseY)) + prod(size(BaseU)) + prod(size(BaseV));

        %%%%%%%%

        if DEBUG2
            fprintf('  - SRMF\n');
        end
        Cons_y = ConfigSRTF(A_y,b_y,group_raw_video_vector_y,M,sx,rank_y,rank_y,lambda,true);
        Cons_u = ConfigSRTF(A_u,b_u,group_raw_video_vector_u,M,sx,rank_u,rank_u,lambda,true);
        Cons_v = ConfigSRTF(A_v,b_v,group_raw_video_vector_v,M,sx,rank_v,rank_v,lambda,true);
        [u4_y,v4_y,w4_y] = SRTF(group_raw_video_vector_y, rank_y, M, Cons_y, 1000, 100, 50);
        [u4_u,v4_u,w4_u] = SRTF(group_raw_video_vector_u, rank_u, M, Cons_u, 1000, 100, 50);
        [u4_v,v4_v,w4_v] = SRTF(group_raw_video_vector_v, rank_v, M, Cons_v, 1000, 100, 50);

        compressed_size_srmf = compressed_size_srmf + (prod(size(u4_y)) + prod(size(u4_u)) + prod(size(u4_v))) * 3;

        if DEBUG1
            fprintf('    compressed size = %f\n', compressed_size_srmf);
        end
        
        Z_y = tensorprod(u4_y, v4_y, w4_y);
        Z_u = tensorprod(u4_u, v4_u, w4_u);
        Z_v = tensorprod(u4_v, v4_v, w4_v);
        Z_y = max(0, Z_y);
        Z_u = max(0, Z_u);
        Z_v = max(0, Z_v);
        Z_srmf_y = Z_y;
        Z_srmf_u = Z_u;
        Z_srmf_v = Z_v;

        %%%%%%%%
        % SRMF + KNN
        % maxDist = 3;
        % EPS = 1e-3;
        % for i = 1:sx(1)
        %   for j = 1:sx(2)
        %     ind = find((M(i,:)==1) & (abs((1:sx(n)) - j) <= maxDist));
        %     if (~isempty(ind))
        %       Y  = Z_srmf_y(:,ind);
        %       C  = Y'*Y;
        %       nc = size(C,1);
        %       C  = C + max(eps,EPS*trace(C)/nc)*speye(nc);
        %       w  = C\(Y'*Z_srmf_y(:,j));
        %       w  = reshape(w,1,nc);
        %       Z_y(i,j) = sum(group_raw_video_vector_y(i,ind).*w);

        %       Y  = Z_srmf_u(:,ind);
        %       C  = Y'*Y;
        %       nc = size(C,1);
        %       C  = C + max(eps,EPS*trace(C)/nc)*speye(nc);
        %       w  = C\(Y'*Z_srmf_u(:,j));
        %       w  = reshape(w,1,nc);
        %       Z_u(i,j) = sum(group_raw_video_vector_u(i,ind).*w);

        %       Y  = Z_srmf_v(:,ind);
        %       C  = Y'*Y;
        %       nc = size(C,1);
        %       C  = C + max(eps,EPS*trace(C)/nc)*speye(nc);
        %       w  = C\(Y'*Z_srmf_v(:,j));
        %       w  = reshape(w,1,nc);
        %       Z_v(i,j) = sum(group_raw_video_vector_v(i,ind).*w);
        %     end
        %   end
        % end

        % Z_srmf_knn_y = Z_y;
        % Z_srmf_knn_u = Z_u;
        % Z_srmf_knn_v = Z_v;


        %% --------------------
        %  Compressed video:
        %% --------------------
        compressed_video_vector_y = Z_srmf_y;
        compressed_video_vector_u = Z_srmf_u;
        compressed_video_vector_v = Z_srmf_v;

        compressed_video_vector_base_y = BaseY;
        compressed_video_vector_base_u = BaseU;
        compressed_video_vector_base_v = BaseV;


        %% --------------------
        %  Inverse DCT
        %% --------------------
        % compressed_video_vector_y = mirt_idctn(compressed_video_vector_y);
        % compressed_video_vector_u = mirt_idctn(compressed_video_vector_u);
        % compressed_video_vector_v = mirt_idctn(compressed_video_vector_v);


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

            compressed_mov(this_k).imgYuv(:,:,1) = compressed_video_vector_y(:, :, this_g_ind)';
            compressed_mov(this_k).imgYuv(:,:,2) = compressed_video_vector_u(:, :, this_g_ind)';
            compressed_mov(this_k).imgYuv(:,:,3) = compressed_video_vector_v(:, :, this_g_ind)';

            compressed_base_mov(this_k).imgYuv(:,:,1) = compressed_video_vector_base_y(:, :, this_g_ind)';
            compressed_base_mov(this_k).imgYuv(:,:,2) = compressed_video_vector_base_u(:, :, this_g_ind)';
            compressed_base_mov(this_k).imgYuv(:,:,3) = compressed_video_vector_base_v(:, :, this_g_ind)';

        end

    end %% end for all frames

    %% --------------------
    %  PSNR
    %% --------------------
    original_size = video.frames * video.width * video.height * 3;
    
    psnr_srmf = calculate_psnr(mov, compressed_mov, video.frames);
    compressed_ratio_srmf = compressed_size_srmf / original_size;

    if DEBUG3 == 1
        fprintf('size=%d/%d=%f, PSNR=%f\n', compressed_size_srmf, original_size, compressed_ratio_srmf, psnr_srmf);
    end


    psnr_base = calculate_psnr(mov, compressed_base_mov, video.frames);
    compressed_ratio_base = compressed_size_base / original_size;

    if DEBUG3 == 1
        fprintf('size=%d/%d=%f, PSNR=%f\n', compressed_size_base, original_size, compressed_ratio_base, psnr_base);
    end


end


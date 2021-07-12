%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Yi-Chao Chen
%% 2013.10.08 @ UT Austin
%%
%% - Input:
%%
%% - Output:
%%
% e.g.
%   sanity_check('TM_Airport_period5_.exp0.', 300, 300, 12)
%%     
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function sanity_check(filename, width, height, num_frames)

    addpath('../utils/YUV2Image');
    addpath('../utils/mirt_dctn');
    addpath('../utils/compressive_sensing');
    addpath('../utils');
    addpath('../subtask_psnr');

    %% --------------------
    %% DEBUG
    %% --------------------
    DEBUG0 = 0;
    DEBUG1 = 1;
    DEBUG2 = 1;


    %% --------------------
    %% Variable
    %% --------------------
    % input_tm_dir = '../processed_data/subtask_process_4sq/TM/';
    input_tm_dir    = '../processed_data/subtask_inject_error/TM_err/';
    input_mpeg_dir  = '../processed_data/subtask_TM_to_video/comp_video/';
    input_video_dir = '../processed_data/subtask_TM_to_video/video/';
    input_gt_dir    = '../processed_data/subtask_inject_error/errs/';
    input_pca_dir   = '../condor_data/subtask_psnr/comp_video/';
    input_dct_dir   = '../condor_data/subtask_psnr/comp_video/';
    input_cs_dir    = '../condor_data/subtask_psnr/comp_video/';


    %% --------------------
    %% test
    %% --------------------
    TEST = 1;
    if TEST == 0
        subSampleMat = [1, 1, 1; 1, 1, 1; 1, 1, 1];
        % subSampleMat = [1, 1; 1, 1];
        a = 10 * eye(4, 4);
        a = kron(a, subSampleMat);
        a(size(a, 1), 2) = 999

        % a(size(a, 1), size(a, 1)+3) = 10
        dcta = mirt_dctn(a);
        dcta = dcta / 1000;
        dcta(abs(dcta) < 0.01) = 0;
        dcta = dcta * 1000
        dct = mirt_idctn(dcta)
        abs(dct - a)

        fprintf('----------------------------------\n');

        r = 8;
        [latent, U, eigenvector] = calculate_PCA(a);
        pca = PCA_compress(latent, U, eigenvector, r)
        abs(pca - a)

        fprintf('----------------------------------\n');

        r = 6;
        M = ones(size(a));
        [A, b] = XM2Ab(a, M);
        Cons = ConfigSRTF(A,b, a, M, size(a), r, true);
        [u, v, w] = SRTF(a, r, M, Cons, 1, 1, 10);
        srmf = tensorprod(u, v, w)
        abs(srmf - a)

        return
    end  
    %% end TEST
    %% --------------------


    %% --------------------
    %% main starts here
    %% --------------------
    
    %% --------------------
    %% read video
    %% --------------------
    if DEBUG2, fprintf('read video\n'); end
    video_filename = [input_video_dir, filename '.yuv'];
    mov = loadFileYuv(video_filename, width, height, 1:num_frames);
    video_data = zeros(width, height, num_frames, 3);
    for f = [1:num_frames]
        video_data(:, :, f, 1) = mov(f).imgYuv(:, :, 1)';
        video_data(:, :, f, 2) = mov(f).imgYuv(:, :, 2)';
        video_data(:, :, f, 3) = mov(f).imgYuv(:, :, 3)';
    end


    %% --------------------
    %% read mpeg compressed video
    %% --------------------
    if DEBUG2, fprintf('read MPEG\n'); end
    mpeg_filename = [input_mpeg_dir, filename '.b700.mpeg_dec.yuv'];
    mov_mpeg = loadFileYuv(mpeg_filename, width, height, 1:num_frames);
    mpeg_data = zeros(width, height, num_frames, 3);
    for f = [1:num_frames]
        mpeg_data(:, :, f, 1) = mov_mpeg(f).imgYuv(:, :, 1)';
        mpeg_data(:, :, f, 2) = mov_mpeg(f).imgYuv(:, :, 2)';
        mpeg_data(:, :, f, 3) = mov_mpeg(f).imgYuv(:, :, 3)';
    end


    %% --------------------
    %% read PCA output
    %% --------------------
    if DEBUG2, fprintf('read PCA\n'); end
    pca_filename = [input_pca_dir, filename '.yuv.PCA.4.15.0.12.300.300.yuv'];
    mov_pca = loadFileYuv(pca_filename, width, height, 1:num_frames);
    pca_data = zeros(width, height, num_frames, 3);
    for f = [1:num_frames]
        pca_data(:, :, f, 1) = mov_pca(f).imgYuv(:, :, 1)';
        pca_data(:, :, f, 2) = mov_pca(f).imgYuv(:, :, 2)';
        pca_data(:, :, f, 3) = mov_pca(f).imgYuv(:, :, 3)';
    end


    %% --------------------
    %% read DCT output
    %% --------------------
    if DEBUG2, fprintf('read 3DDCT\n'); end
    dct_filename = [input_dct_dir, filename '.yuv.3DDCT.4.150.12.300.300.yuv'];
    mov_dct = loadFileYuv(dct_filename, width, height, 1:num_frames);
    dct_data = zeros(width, height, num_frames, 3);
    for f = [1:num_frames]
        dct_data(:, :, f, 1) = mov_dct(f).imgYuv(:, :, 1)';
        dct_data(:, :, f, 2) = mov_dct(f).imgYuv(:, :, 2)';
        dct_data(:, :, f, 3) = mov_dct(f).imgYuv(:, :, 3)';
    end


    %% --------------------
    %% read Compressive sensing output
    %% --------------------
    if DEBUG2, fprintf('read CS\n'); end
    cs_filename = [input_cs_dir, filename '.yuv.comp_sen.4.100.12.300.300.yuv'];
    fprintf('  file=%s\n', cs_filename);
    mov_cs = loadFileYuv(cs_filename, width, height, 1:num_frames);
    cs_data = zeros(width, height, num_frames, 3);
    for f = [1:num_frames]
        cs_data(:, :, f, 1) = mov_cs(f).imgYuv(:, :, 1)';
        cs_data(:, :, f, 2) = mov_cs(f).imgYuv(:, :, 2)';
        cs_data(:, :, f, 3) = mov_cs(f).imgYuv(:, :, 3)';
    end



    %% --------------------
    %% read tm
    %% --------------------
    if DEBUG2, fprintf('read TM\n'); end

    TM = zeros(width, height, num_frames);
    for f = [1:num_frames]
        tm_filename = [input_tm_dir filename int2str(f-1) '.txt'];
        data = load(tm_filename);
        TM(:, :, f) = data(1:width, 1:height);
    end



    %% --------------------
    %% read ground truth
    %% --------------------
    if DEBUG2, fprintf('read ground truth\n'); end

    for frame = [0:num_frames-1]
        if DEBUG2, fprintf('  frame %d\n', frame); end

        this_gt_file = [input_gt_dir filename int2str(frame) '.err.txt'];
        if DEBUG0, fprintf('    file = %s\n', this_gt_file); end
        
        if frame == 0
            ground_truth = load(this_gt_file);
        else
            tmp = load(this_gt_file);
            tmp(1, :) = tmp(1, :) + frame * width * height;

            ground_truth = [ground_truth, tmp];
        end
    end

    if DEBUG1, 
        fprintf('  size of ground truth: %d, %d\n', size(ground_truth)); 
    end

    
    %% --------------------
    %% comparison
    %% --------------------
    range = 1:15;
    fprintf('TM\n');
    TM(range, range, 1)
    fprintf('video\n');
    video_data(range, range, 1, 1)
    fprintf('mpeg\n');
    mpeg_data(range, range, 1, 1)
    fprintf('pca\n');
    pca_data(range, range, 1, 1)
    fprintf('dct\n');
    dct_data(range, range, 1, 1)
    fprintf('cs\n');
    cs_data(range, range, 1, 1)
    
    fprintf('\nground truth\n');
    ground_truth(2, range)
    
    fprintf('ground truth in TM\n');
    TM_y = TM(:, :, 1);
    TM_y(ground_truth(1, range))
    
    fprintf('ground truth in video\n');
    video_data_y = video_data(:, :, 1, 1);
    video_data_y(ground_truth(1, range))

    fprintf('ground truth in mpeg\n');
    mpeg_data_y = mpeg_data(:, :, 1, 1);
    mpeg_data_y(ground_truth(1, range))

    fprintf('ground truth in pca\n');
    pca_data_y = pca_data(:, :, 1, 1);
    pca_data_y(ground_truth(1, range))

    fprintf('ground truth in dct\n');
    dct_data_y = dct_data(:, :, 1, 1);
    dct_data_y(ground_truth(1, range))

    fprintf('ground truth in cs\n');
    cs_data_y = cs_data(:, :, 1, 1);
    cs_data_y(ground_truth(1, range))
end
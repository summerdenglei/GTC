
output_dir = '../processed_data/subtask_psnr/pca_psnr_output/';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Fragment
% for i = [1:10:89 90]
%     fprintf('# PCs = %d\n', i);
%     PCA_psnr(i);
% end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Frame + DCT
% file_name = 'psnr_frame_dct.txt';
% fh = fopen([output_dir file_name], 'w');
% dct_threshs = [0];
% ranks = [1:2:15 20:10:90];

% for dct_thresh = dct_threshs
%     for r = ranks
%         video = 'stefan_cif.yuv';
%         [psnr, compressed_ratio] = PCA_psnr_by_frame(r, dct_thresh, video, 90, 352, 288);
%         fprintf('%s, %d, %d, %f, %f\n', video, dct_thresh, r, compressed_ratio, psnr);
%         fprintf(fh, '%s, %d, %d, %f, %f\n', video, dct_thresh, r, compressed_ratio, psnr);
%     end
% end

% for dct_thresh = dct_threshs
%     for r = ranks
%         video = 'bus_cif.yuv';
%         [psnr, compressed_ratio] = PCA_psnr_by_frame(r, dct_thresh, video, 150, 352, 288);
%         fprintf('%s, %d, %d, %f, %f\n', video, dct_thresh, r, compressed_ratio, psnr);
%         fprintf(fh, '%s, %d, %d, %f, %f\n', video, dct_thresh, r, compressed_ratio, psnr);
%     end
% end

% for dct_thresh = dct_threshs
%     for r = ranks
%         video = 'foreman_cif.yuv';
%         [psnr, compressed_ratio] = PCA_psnr_by_frame(r, dct_thresh, video, 300, 352, 288);
%         fprintf('%s, %d, %d, %f, %f\n', video, dct_thresh, r, compressed_ratio, psnr);
%         fprintf(fh, '%s, %d, %d, %f, %f\n', video, dct_thresh, r, compressed_ratio, psnr);
%     end
% end

% for dct_thresh = dct_threshs
%     for r = ranks
%         video = 'coastguard_cif.yuv';
%         [psnr, compressed_ratio] = PCA_psnr_by_frame(r, dct_thresh, video, 300, 352, 288);
%         fprintf('%s, %d, %d, %f, %f\n', video, dct_thresh, r, compressed_ratio, psnr);
%         fprintf(fh, '%s, %d, %d, %f, %f\n', video, dct_thresh, r, compressed_ratio, psnr);

%     end
% end

% for dct_thresh = dct_threshs
%     for r = ranks
%         video = 'highway_cif.yuv';
%         [psnr, compressed_ratio] = PCA_psnr_by_frame(r, dct_thresh, video, 300, 352, 288);
%         fprintf('%s, %d, %d, %f, %f\n', video, dct_thresh, r, compressed_ratio, psnr);
%         fprintf(fh, '%s, %d, %d, %f, %f\n', video, dct_thresh, r, compressed_ratio, psnr);
%     end
% end

% fclose(fh);




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Group Frames + DCT
file_name = 'psnr_group_frame_dct.txt';
fh = fopen([output_dir file_name], 'w');
dct_threshs = [0];
ranks = [1:2:15];
group_sizes = [4, 8, 16];

dct_thresh = 0;
for group_size = group_sizes
    for r = ranks
        video = 'stefan_cif.yuv';
        [psnr, compressed_ratio] = PCA_psnr_by_frame(r, dct_thresh, group_size, video, 90, 352, 288);
        fprintf('%s, %d, %d, %d, %f, %f\n', video, dct_thresh, r, group_size, compressed_ratio, psnr);
        fprintf(fh, '%s, %d, %d, %d, %f, %f\n', video, dct_thresh, r, group_size, compressed_ratio, psnr);
    end
end

dct_thresh = 0;
for group_size = group_sizes
    for r = ranks
        video = 'bus_cif.yuv';
        [psnr, compressed_ratio] = PCA_psnr_by_frame(r, dct_thresh, group_size, video, 150, 352, 288);
        fprintf('%s, %d, %d, %d, %f, %f\n', video, dct_thresh, r, group_size, compressed_ratio, psnr);
        fprintf(fh, '%s, %d, %d, %d, %f, %f\n', video, dct_thresh, r, group_size, compressed_ratio, psnr);
    end
end

dct_thresh = 0;
for group_size = group_sizes
    for r = ranks
        video = 'foreman_cif.yuv';
        [psnr, compressed_ratio] = PCA_psnr_by_frame(r, dct_thresh, group_size, video, 300, 352, 288);
        fprintf('%s, %d, %d, %d, %f, %f\n', video, dct_thresh, r, group_size, compressed_ratio, psnr);
        fprintf(fh, '%s, %d, %d, %d, %f, %f\n', video, dct_thresh, r, group_size, compressed_ratio, psnr);
    end
end

dct_thresh = 0;
for group_size = group_sizes
    for r = ranks
        video = 'coastguard_cif.yuv';
        [psnr, compressed_ratio] = PCA_psnr_by_frame(r, dct_thresh, group_size, video, 300, 352, 288);
        fprintf('%s, %d, %d, %d, %f, %f\n', video, dct_thresh, r, group_size, compressed_ratio, psnr);
        fprintf(fh, '%s, %d, %d, %d, %f, %f\n', video, dct_thresh, r, group_size, compressed_ratio, psnr);

    end
end

dct_thresh = 0;
for group_size = group_sizes
    for r = ranks
        video = 'highway_cif.yuv';
        [psnr, compressed_ratio] = PCA_psnr_by_frame(r, dct_thresh, group_size, video, 300, 352, 288);
        fprintf('%s, %d, %d, %d, %f, %f\n', video, dct_thresh, r, group_size, compressed_ratio, psnr);
        fprintf(fh, '%s, %d, %d, %d, %f, %f\n', video, dct_thresh, r, group_size, compressed_ratio, psnr);
    end
end

fclose(fh);




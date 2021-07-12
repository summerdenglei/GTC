
output_dir = '../processed_data/subtask_psnr/pca_psnr_output/';


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Group Frames + DCT
file_name = 'psnr_dct_combine_yuv.txt';
fh = fopen([output_dir file_name], 'w');
group_sizes = [4, 8, 16];
max_chunks = [10 30 50 70 90];

for group_size = group_sizes
    for num_chunks = max_chunks
        video = 'stefan_cif.yuv';
        [psnr, compressed_ratio] = DCT_psnr_combine_yuv(num_chunks, group_size, video, 90, 352, 288);
        fprintf('%s, %d, %d, %f, %f\n', video, num_chunks, group_size, compressed_ratio, psnr);
        fprintf(fh, '%s, %d, %d, %f, %f\n', video, num_chunks, group_size, compressed_ratio, psnr);
    end
end

for group_size = group_sizes
    for num_chunks = max_chunks
        video = 'bus_cif.yuv';
        [psnr, compressed_ratio] = DCT_psnr_combine_yuv(num_chunks, group_size, video, 150, 352, 288);
        fprintf('%s, %d, %d, %f, %f\n', video, num_chunks, group_size, compressed_ratio, psnr);
        fprintf(fh, '%s, %d, %d, %f, %f\n', video, num_chunks, group_size, compressed_ratio, psnr);
    end
end

for group_size = group_sizes
    for num_chunks = max_chunks
        video = 'foreman_cif.yuv';
        [psnr, compressed_ratio] = DCT_psnr_combine_yuv(num_chunks, group_size, video, 300, 352, 288);
        fprintf('%s, %d, %d, %f, %f\n', video, num_chunks, group_size, compressed_ratio, psnr);
        fprintf(fh, '%s, %d, %d, %f, %f\n', video, num_chunks, group_size, compressed_ratio, psnr);
    end
end

for group_size = group_sizes
    for num_chunks = max_chunks
        video = 'coastguard_cif.yuv';
        [psnr, compressed_ratio] = DCT_psnr_combine_yuv(num_chunks, group_size, video, 300, 352, 288);
        fprintf('%s, %d, %d, %f, %f\n', video, num_chunks, group_size, compressed_ratio, psnr);
        fprintf(fh, '%s, %d, %d, %f, %f\n', video, num_chunks, group_size, compressed_ratio, psnr);

    end
end

for group_size = group_sizes
    for num_chunks = max_chunks
        video = 'highway_cif.yuv';
        [psnr, compressed_ratio] = DCT_psnr_combine_yuv(num_chunks, group_size, video, 300, 352, 288);
        fprintf('%s, %d, %d, %f, %f\n', video, num_chunks, group_size, compressed_ratio, psnr);
        fprintf(fh, '%s, %d, %d, %f, %f\n', video, num_chunks, group_size, compressed_ratio, psnr);
    end
end

fclose(fh);




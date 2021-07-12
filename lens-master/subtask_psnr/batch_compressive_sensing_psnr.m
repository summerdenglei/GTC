
output_dir = '../processed_data/subtask_psnr/pca_psnr_output/';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Compressive_sensing
file_name = 'psnr_compressive_sensing.txt';
fh = fopen([output_dir file_name], 'w');
ranks = [10:20:90];
group_sizes = [4, 8, 16, 30];

for group_size = group_sizes
    for r = ranks
        video = 'stefan_cif.yuv';
        [psnr_srmf, ratio_srmf, psnr_base, ratio_base] = compressive_sensing_psnr(r, group_size, video, 90, 352, 288);
        fprintf('%s, %d, %d, %f, %f, %f, %f\n', video, r, group_size, ratio_srmf, psnr_srmf, ratio_base, psnr_base);
        fprintf(fh, '%s, %d, %d, %f, %f, %f, %f\n', video, r, group_size, ratio_srmf, psnr_srmf, ratio_base, psnr_base);
    end
end

for group_size = group_sizes
    for r = ranks
        video = 'bus_cif.yuv';
        [psnr_srmf, ratio_srmf, psnr_base, ratio_base] = compressive_sensing_psnr(r, group_size, video, 150, 352, 288);
        fprintf('%s, %d, %d, %f, %f, %f, %f\n', video, r, group_size, ratio_srmf, psnr_srmf, ratio_base, psnr_base);
        fprintf(fh, '%s, %d, %d, %f, %f, %f, %f\n', video, r, group_size, ratio_srmf, psnr_srmf, ratio_base, psnr_base);
    end
end

for group_size = group_sizes
    for r = ranks
        video = 'foreman_cif.yuv';
        [psnr_srmf, ratio_srmf, psnr_base, ratio_base] = compressive_sensing_psnr(r, group_size, video, 300, 352, 288);
        fprintf('%s, %d, %d, %f, %f, %f, %f\n', video, r, group_size, ratio_srmf, psnr_srmf, ratio_base, psnr_base);
        fprintf(fh, '%s, %d, %d, %f, %f, %f, %f\n', video, r, group_size, ratio_srmf, psnr_srmf, ratio_base, psnr_base);
    end
end

for group_size = group_sizes
    for r = ranks
        video = 'coastguard_cif.yuv';
        [psnr_srmf, ratio_srmf, psnr_base, ratio_base] = compressive_sensing_psnr(r, group_size, video, 300, 352, 288);
        fprintf('%s, %d, %d, %f, %f, %f, %f\n', video, r, group_size, ratio_srmf, psnr_srmf, ratio_base, psnr_base);
        fprintf(fh, '%s, %d, %d, %f, %f, %f, %f\n', video, r, group_size, ratio_srmf, psnr_srmf, ratio_base, psnr_base);

    end
end

for group_size = group_sizes
    for r = ranks
        video = 'highway_cif.yuv';
        [psnr_srmf, ratio_srmf, psnr_base, ratio_base] = compressive_sensing_psnr(r, group_size, video, 300, 352, 288);
        fprintf('%s, %d, %d, %f, %f, %f, %f\n', video, r, group_size, ratio_srmf, psnr_srmf, ratio_base, psnr_base);
        fprintf(fh, '%s, %d, %d, %f, %f, %f, %f\n', video, r, group_size, ratio_srmf, psnr_srmf, ratio_base, psnr_base);
    end
end

fclose(fh);




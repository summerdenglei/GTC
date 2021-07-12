% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %% video
% input_raw_dir  = '../data/video/';
% input_comp_dir = '../processed_data/video/';
% output_dir     = '../processed_data/subtask_psnr/mpeg_psnr_output/';

% file_name = 'psnr_frame_dct.txt';
% fh = fopen([output_dir file_name], 'w');

% for b = [10, 100:100:700]
%     video = 'stefan_cif';
%     psnr = yuv_psnr([input_raw_dir video '.yuv'], [input_comp_dir video '.b' int2str(b) '.mpeg_dec.yuv'], 90, 352, 288);
%     fprintf('%s, %d, %f\n', video, b, psnr);
%     fprintf(fh, '%s, %d, %f\n', video, b, psnr);

%     video = 'bus_cif';
%     psnr = yuv_psnr([input_raw_dir video '.yuv'], [input_comp_dir video '.b' int2str(b) '.mpeg_dec.yuv'], 150, 352, 288);
%     fprintf('%s, %d, %f\n', video, b, psnr);
%     fprintf(fh, '%s, %d, %f\n', video, b, psnr);

%     video = 'foreman_cif';
%     psnr = yuv_psnr([input_raw_dir video '.yuv'], [input_comp_dir video '.b' int2str(b) '.mpeg_dec.yuv'], 300, 352, 288);
%     fprintf('%s, %d, %f\n', video, b, psnr);
%     fprintf(fh, '%s, %d, %f\n', video, b, psnr);

%     video = 'coastguard_cif';
%     psnr = yuv_psnr([input_raw_dir video '.yuv'], [input_comp_dir video '.b' int2str(b) '.mpeg_dec.yuv'], 300, 352, 288);
%     fprintf('%s, %d, %f\n', video, b, psnr);
%     fprintf(fh, '%s, %d, %f\n', video, b, psnr);

%     video = 'highway_cif';
%     psnr = yuv_psnr([input_raw_dir video '.yuv'], [input_comp_dir video '.b' int2str(b) '.mpeg_dec.yuv'], 300, 352, 288);
%     fprintf('%s, %d, %f\n', video, b, psnr);
%     fprintf(fh, '%s, %d, %f\n', video, b, psnr);
% end

% fclose(fh);



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 4sq Human TM
input_raw_dir  = '../processed_data/subtask_TM_to_video/video/';
input_comp_dir = '../processed_data/subtask_TM_to_video/comp_video/';
output_dir     = '../processed_data/subtask_psnr/mpeg_psnr_output/';

file_name = '4sq_human_TM.txt';
fh = fopen([output_dir file_name], 'w');

for b = [10, 100:100:700]
    video = 'TM_Airport_period5_';
    psnr = yuv_psnr([input_raw_dir video '.yuv'], [input_comp_dir video '.b' int2str(b) '.mpeg_dec.yuv'], 12, 300, 300);
    fprintf('%s, %d, %f\n', video, b, psnr);
    fprintf(fh, '%s, %d, %f\n', video, b, psnr);

    video = 'TM_Austin_period5_';
    psnr = yuv_psnr([input_raw_dir video '.yuv'], [input_comp_dir video '.b' int2str(b) '.mpeg_dec.yuv'], 12, 300, 300);
    fprintf('%s, %d, %f\n', video, b, psnr);
    fprintf(fh, '%s, %d, %f\n', video, b, psnr);

    video = 'TM_Manhattan_period5_';
    psnr = yuv_psnr([input_raw_dir video '.yuv'], [input_comp_dir video '.b' int2str(b) '.mpeg_dec.yuv'], 12, 500, 500);
    fprintf('%s, %d, %f\n', video, b, psnr);
    fprintf(fh, '%s, %d, %f\n', video, b, psnr);

    video = 'TM_San_Francisco_period5_';
    psnr = yuv_psnr([input_raw_dir video '.yuv'], [input_comp_dir video '.b' int2str(b) '.mpeg_dec.yuv'], 12, 300, 300);
    fprintf('%s, %d, %f\n', video, b, psnr);
    fprintf(fh, '%s, %d, %f\n', video, b, psnr);
end

fclose(fh);


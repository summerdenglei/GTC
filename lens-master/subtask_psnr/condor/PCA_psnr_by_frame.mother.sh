#!/bin/bash

matlab -r "[psnr, compressed_ratio] = PCA_psnr_by_frame(RANK, DCT_THRESH, GRP_SIZE, 'VIDEO_NAME.yuv', NUM_FRAMES, WIDTH, HEIGHT); fh = fopen(['/u/yichao/anomaly_compression/condor_data/subtask_psnr/condor/output/PCA_psnr_by_frame.VIDEO_NAME.GRP_SIZE.RANK.DCT_THRESH.NUM_FRAMES.WIDTH.HEIGHT.txt'], 'w'); fprintf(fh, '%f, %f\n', compressed_ratio, psnr); fclose(fh); exit;"
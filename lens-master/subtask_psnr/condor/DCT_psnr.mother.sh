#!/bin/bash

matlab -r "[psnr, compressed_ratio] = DCT_psnr(NUM_CHUNKS, GRP_SIZE, 'VIDEO_NAME.yuv', NUM_FRAMES, WIDTH, HEIGHT); fh = fopen(['/u/yichao/anomaly_compression/condor_data/subtask_psnr/condor/output/DCT_psnr.VIDEO_NAME.GRP_SIZE.NUM_CHUNKS.NUM_FRAMES.WIDTH.HEIGHT.txt'], 'w'); fprintf(fh, '%f, %f\n', compressed_ratio, psnr); fclose(fh); exit;"
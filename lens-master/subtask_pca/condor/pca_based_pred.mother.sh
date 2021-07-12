#!/bin/bash

matlab -r "out_file = ['/u/yichao/anomaly_compression/condor_data/subtask_pca/condor/output/pca_based_pred.FILENAME.NUM_FRAMES.WIDTH.HEIGHT.BLOCK_WIDTH.BLOCK_HEIGHT.rRANK.OPT_SWAP_MAT.OPT_DIM.DROP_ELE_MODE.DROP_MODE.elemELEM_FRAC.lossLOSS_RATE.burstBURST_SIZE.seedSEED.txt']; if(exist(out_file)), exit; end; [mse, mae, cc, ratio] = pca_based_pred('INPUT_DIR', 'FILENAME', NUM_FRAMES, WIDTH, HEIGHT, BLOCK_WIDTH, BLOCK_HEIGHT, RANK, 'OPT_SWAP_MAT', 'OPT_DIM', 'DROP_ELE_MODE', 'DROP_MODE', ELEM_FRAC, LOSS_RATE, BURST_SIZE, SEED); fh = fopen(out_file, 'w'); fprintf(fh, '%f, %f, %f, %f\n', mse, mae, cc, ratio); fclose(fh); exit;"

# bash run_pca_based_pred.sh /v/filer4b/software/matlab-2011a 'INPUT_DIR', 'FILENAME' NUM_FRAMES WIDTH HEIGHT BLOCK_WIDTH BLOCK_HEIGHT RANK OPT_SWAP_MAT LOSS_RATE SEED

#!/bin/bash

matlab -r "out_file = ['/u/yichao/anomaly_compression/condor_data/subtask_3ddct/condor/output/dct_based_pred.FILENAME.NUM_FRAMES.WIDTH.HEIGHT.GROUP_SIZE.OPT_SWAP_MAT.OPT_TYPE.cwCHUNK_WIDTH.chCHUNK_HEIGHT.ncSEL_CHUNKS.quanQUANTIZATION.DROP_ELE_MODE.DROP_MODE.elemELEM_FRAC.lossLOSS_RATE.burstBURST_SIZE.seedSEED.txt']; if(exist(out_file)), exit; end; [mse, mae, cc, ratio] = dct_based_pred('INPUT_DIR', 'FILENAME', NUM_FRAMES, WIDTH, HEIGHT, GROUP_SIZE, 'OPT_SWAP_MAT', 'OPT_TYPE', CHUNK_WIDTH, CHUNK_HEIGHT, SEL_CHUNKS, QUANTIZATION, 'DROP_ELE_MODE', 'DROP_MODE', ELEM_FRAC, LOSS_RATE, BURST_SIZE, SEED); fh = fopen(out_file, 'w'); fprintf(fh, '%f, %f, %f, %f', mse, mae, cc, ratio); fclose(fh); exit;"

# /v/filer4b/v27q001/ut-wireless/Han/matlabR2008a/bin/matlab -r "[mse, mae, cc, ratio] = dct_based_pred('INPUT_DIR', 'FILENAME', NUM_FRAMES, WIDTH, HEIGHT, GROUP_SIZE, OPT_SWAP_MAT, OPT_TYPE, CHUNK_WIDTH, CHUNK_HEIGHT, SEL_CHUNKS, QUANTIZATION, LOSS_RATE, SEED); exit;"
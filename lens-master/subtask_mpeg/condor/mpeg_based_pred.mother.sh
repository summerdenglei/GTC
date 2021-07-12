#!/bin/bash

matlab -r "out_file = ['/u/yichao/anomaly_compression/condor_data/subtask_mpeg/condor/output/mpeg_based_pred.FILENAME.NUM_FRAMES.WIDTH.HEIGHT.bwBLOCK_WIDTH.bhBLOCK_HEIGHT.OPT_DELTA.OPT_FRAME_BLOCK.OPT_SWAP_MAT.OPT_FILL_IN.DROP_ELE_MODE.DROP_MODE.elemELEM_FRAC.lossLOSS_RATE.burstBURST_SIZE.seedSEED.txt']; if(exist(out_file)), exit; end; [mse, mae, cc, ratio] = mpeg_based_pred('INPUT_DIR', 'FILENAME', NUM_FRAMES, WIDTH, HEIGHT, BLOCK_WIDTH, BLOCK_HEIGHT, 'OPT_DELTA', [OPT_FRAMES], [OPT_BLOCKS], 'OPT_SWAP_MAT', 'OPT_FILL_IN', 'DROP_ELE_MODE', 'DROP_MODE', ELEM_FRAC, LOSS_RATE, BURST_SIZE, SEED); fh = fopen(out_file, 'w'); fprintf(fh, '%f, %f, %f, %f\n', mse, mae, cc, ratio); fclose(fh); exit;"
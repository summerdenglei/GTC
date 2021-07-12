

fh = fopen('../processed_data/subtask_detect_anomaly/output/detect_anomaly.2013.10.11.r2.output.txt', 'w');

for expnum = [0, 1, 2]
    %% mpeg
    method = 'MPEG';
    for vb = [1 3 5 7 9 10 15 20 30 40 50 100 200 300 400 500 600 700]
        for thresh = [1 10:10:200]
            [tp, tn, fp, fn] = detect_anomaly(['TM_Airport_period5_.exp' int2str(expnum) '..b' int2str(vb) '.mpeg_dec.yuv.txt'], ['TM_Airport_period5_.exp' int2str(expnum) '.'], 12, 300, 300, thresh);

            fprintf(fh, 'TM_Airport_period5_.exp%d, %s, %d, %d, %d, %d, %d, %d\n', expnum, method, vb, thresh, tp, tn, fp, fn);
        end
    end


    %% PCA
    method = 'PCA';
    for grp_size = [4]
        for r = [1 3 5 10 15 20 30 40 50 60 70 80 90 100 150 200 250]
            for thresh = [1 10:10:200]
                [tp, tn, fp, fn] = detect_anomaly(['TM_Airport_period5_.exp' int2str(expnum) '..yuv.' method '.' int2str(grp_size) '.' int2str(r) '.0.12.300.300.yuv.txt'], ['TM_Airport_period5_.exp' int2str(expnum) '.'], 12, 300, 300, thresh);

                fprintf(fh, 'TM_Airport_period5_.exp%d, %s, %d, %d, %d, %d, %d, %d, %d\n', expnum, method, grp_size, r, thresh, tp, tn, fp, fn);
            end
        end
    end


    %% 3DDCT
    method = '3DDCT';
    for grp_size = [4]
        for num_chunks = [1 3 5 10 15 30 50 70 100 150 200 250]
            for thresh = [1 10:10:200]
                [tp, tn, fp, fn] = detect_anomaly(['TM_Airport_period5_.exp' int2str(expnum) '..yuv.' method '.' int2str(grp_size) '.' int2str(num_chunks) '.12.300.300.yuv.txt'], ['TM_Airport_period5_.exp' int2str(expnum) '.'], 12, 300, 300, thresh);

                fprintf(fh, 'TM_Airport_period5_.exp%d, %s, %d, %d, %d, %d, %d, %d, %d\n', expnum, method, grp_size, num_chunks, thresh, tp, tn, fp, fn);
            end
        end
    end


    %% compressive sensing
    method = 'comp_sen';
    for grp_size = [4]
        for r = [1 3 5 10 15 20 30 50 70 100 150]
            for thresh = [1 10:10:200]
                [tp, tn, fp, fn] = detect_anomaly(['TM_Airport_period5_.exp' int2str(expnum) '..yuv.' method '.' int2str(grp_size) '.' int2str(r) '.12.300.300.yuv.txt'], ['TM_Airport_period5_.exp' int2str(expnum) '.'], 12, 300, 300, thresh);

                fprintf(fh, 'TM_Airport_period5_.exp%d, %s, %d, %d, %d, %d, %d, %d, %d\n', expnum, method, grp_size, r, thresh, tp, tn, fp, fn);
            end
        end
    end
end

fclose(fh);
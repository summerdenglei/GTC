%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Yi-Chao Chen
%% 2014.02.22 @ UT Austin
%%
%% - Input:
%%   @sample_mode:
%%     1) know_all: know all CSI in the history
%%     2) rand_fix: know "num_known_ch" channels in the history, and select a fix set of channels to probe
%%     3) rand: know "num_known_ch" channels in the history, and randomly select different channels to probe everytime
%%     4) equal_fix: know "num_known_ch" channels in the history, and select channels in an equal space sample distribution
%%     5) equal: 
%%   @pred_method:
%%     1) lens_st_knn
%%     2) srmf_lens_st_knn
%%   @schemes
%%     1) our: our scheme
%%     2) cspy: CSpy
%%
%% - Output:
%%
%%
%% e.g.
%%  lens_channel_sel('static_trace1.ant1', 16, 'know_all', 0, 'srmf_knn', 'our+cspy')
%%     
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function lens_channel_sel(trace_name, r, sample_mode, num_known_ch, pred_method, schemes)
    addpath('/u/yichao/anomaly_compression/utils');
    addpath('/u/yichao/anomaly_compression/utils/lens');
    addpath('/u/yichao/anomaly_compression/utils/compressive_sensing');
    addpath('/u/yichao/anomaly_compression/utils/wireless');
    addpath('/u/yichao/anomaly_compression/utils/linux-80211n-csitool-supplementary');


    rand('seed', 1);
    randn('seed', 1);


    %% --------------------
    %% DEBUG
    %% --------------------
    DEBUG0 = 0;
    DEBUG1 = 1;
    DEBUG2 = 1;
    DEBUG3 = 1;

    NUM_PRED = 30;
    FRAME_LEN = 1000 * 8;


    %% --------------------
    %% Constant
    %% --------------------
    channels = [36, 40, 44, 48, 149, 153, 157, 161, 165];
    num_channels = length(channels);
    num_sc = 30;        %% # subcarriers per channel

    
    %% --------------------
    %% Variable
    %% --------------------
    input_dir      = '/u/yichao/anomaly_compression/processed_data/subtask_parse_csi_channel/csi/';
    input_cspy_dir = '/u/yichao/anomaly_compression/processed_data/subtask_channel_selection/svm_results/';
    output_dir     = '/u/yichao/anomaly_compression/processed_data/subtask_channel_selection/';


    %% --------------------
    %% Check input
    %% --------------------
    % if nargin < 1, arg = 1; end
    % if nargin < 1, arg = 1; end


    %% --------------------
    %% Main starts
    %% --------------------

    %% --------------------
    %% read CSI trace
    %% --------------------
    if(DEBUG2); fprintf('read CSI trace\n'); end;

    tmp_phase = load([input_dir trace_name '.phase.txt']);
    tmp_mag = load([input_dir trace_name '.mag.txt']);
    csi = tmp_mag .* exp(i*tmp_phase);
    sx = size(csi);
    if(DEBUG1); fprintf('  size: %d, %d\n', sx); end
    

    %% --------------------
    %% read CSpy prediction
    %% --------------------
    if strfind(schemes, 'cspy')
        for ch = 1:num_channels
            this_filename = [input_cspy_dir trace_name '.ch' num2str(ch) '.txt.predict'];
            if ~exist(this_filename, 'file'); continue; end;
            cspy_sci_all{ch} = load(this_filename);
        end
    end


    %% --------------------
    %% simulate prediction over time
    %% --------------------
    if(DEBUG2); fprintf('simulate prediction over time\n'); end

    % tmp = ceil(sx(1)/2) + randperm(ceil(sx(1)/2)-1);
    tmp = 200 + randperm(min(200, sx(1)-201));
    pred_pkts = sort(tmp(1:NUM_PRED));
    if(DEBUG1)
        fprintf('  predicting pkts: ');
        fprintf('%d, ', pred_pkts);
        fprintf('\n');
    end

    csi_real = zeros(sx(2), NUM_PRED);
    csi_pred = zeros(sx(2), NUM_PRED);
    cspy_sci = zeros(num_channels, NUM_PRED);
    
    
    for pii = 1:NUM_PRED
        pkti = pred_pkts(pii);
        %% use packet 1:pkti to predict packet pkti+1
        data = csi(1:pkti+1, :).';
        this_rank = min(rank(data), r);
        csi_real(:, pii) = data(:, end);

        M = sample_channels(size(data), sample_mode, num_known_ch);
        if(DEBUG1); fprintf('  num missing: %d / %d\n', prod(size(data))-nnz(M), prod(size(data))); end;


        %% --------------------
        %% predict CSIs
        %% --------------------
        if strfind(schemes, 'our')
            est = complete_matrix(data, M, pred_method, this_rank);
            csi_pred(:, pii) = est(:, end);
        end


        %% --------------------
        %% CSpy prediction
        %% --------------------
        if strfind(schemes, 'cspy')
            for ch = 1:num_channels
                cspy_sci(ch, pii) = cspy_sci_all{ch}(pkti+1);
            end
        end
        

        % data(1:8, end-5:end).'
    end
    


    %% --------------------
    %% evaluate CSI prediction
    %% --------------------
    if strfind(schemes, 'our')
        if(DEBUG2); fprintf('evaluate CSI prediction\n'); end

        % csi_real(1:8).'
        % csi_pred(1:8).'
        

        meanX2 = mean(abs(csi_real).^2);
        meanX = mean(abs(csi_real));
        mse = mean(( abs(csi_real) - max(0,abs(csi_pred)) ).^2) / meanX2;
        mae = mean(abs(abs(csi_real) - max(0,abs(csi_pred)))) / meanX;
        cc  = corrcoef(abs(csi_real),max(0,abs(csi_pred)));
        cc  = cc(1,2);
        if(DEBUG3); fprintf('mse=%f, mae=%f, cc=%f\n', mse, mae, cc); end
    end


    %% --------------------
    %% predict strongest channel
    %% --------------------
    if(DEBUG2); fprintf('predict strongest channel\n'); end

    real_ch_tputs = zeros(num_channels, NUM_PRED);
    pred_ch_tputs = zeros(num_channels, NUM_PRED);
    
    for t = 1:NUM_PRED
        for chi = 1:num_channels
            ch_std = (chi-1) * num_sc + 1;
            ch_end = chi * num_sc;

            %% ground truth
            [tput, mcs_index] = calculate_tput(csi_real(ch_std:ch_end, t), FRAME_LEN);
            real_ch_tputs(chi, t) = tput;

            %% based on prediction
            if strfind(schemes, 'our')
                [tput, mcs_index] = calculate_tput(csi_pred(ch_std:ch_end, t), FRAME_LEN);
                pred_ch_tputs(chi, t) = tput;
            end
        end
    end

    
    %% oracle    
    [best_real_tput, best_real_sci] = max(real_ch_tputs);
    avg_real_tput_channels = mean(real_ch_tputs);

    %% our scheme
    if strfind(schemes, 'our')
        [tmp, best_pred_sci] = max(pred_ch_tputs);
        best_pred_tput = ones(1, NUM_PRED);
        for t = 1:NUM_PRED
            best_pred_tput(t) = real_ch_tputs(best_pred_sci(t), t);
        end
    end

    %% random
    if strfind(schemes, 'our')
        rand_sci = round(rand(1, NUM_PRED) * (num_channels-1)) + 1;
        rand_tput = ones(1, NUM_PRED);
        for t = 1:NUM_PRED
            rand_tput(t) = real_ch_tputs(rand_sci(t), t);
        end
    end

    %% cspy
    if strfind(schemes, 'cspy')
        cspy_tput = ones(num_channels, NUM_PRED);
        for ch = 1:num_channels
            for t = 1:NUM_PRED
                cspy_tput(ch, t) = real_ch_tputs(cspy_sci(ch, t), t);
            end
        end
    end


    % best_real_sci
    % best_real_tput
    % best_pred_sci
    % best_pred_tput
    % rand_sci
    % rand_tput
    % avg_real_tput_channels


    avg_real_tput = calculate_avg_tput(best_real_tput);
    if strfind(schemes, 'our')
        avg_pred_tput = calculate_avg_tput(best_pred_tput); 
        pred_sci_accuracy = nnz(best_real_sci == best_pred_sci) / NUM_PRED;
        pred_tput_accuracy = nnz(best_pred_tput./best_real_tput > 0.9) / NUM_PRED;
        pred_tput_fp = nnz(best_pred_tput < avg_real_tput_channels) / NUM_PRED;
    end

    if strfind(schemes, 'our')
        avg_rand_tput = calculate_avg_tput(rand_tput); 
        rand_sci_accuracy = nnz(best_real_sci == rand_sci) / NUM_PRED;
        rand_tput_accuracy = nnz(rand_tput./best_real_tput > 0.9) / NUM_PRED;
        rand_tput_fp = nnz(rand_tput < avg_real_tput_channels) / NUM_PRED;
    end

    if strfind(schemes, 'cspy')
        avg_cspy_tput = zeros(num_channels, 1);
        cspy_sci_accuracy  = zeros(num_channels, 1);
        cspy_tput_accuracy = zeros(num_channels, 1);
        cspy_tput_fp       = zeros(num_channels, 1);
        for ch = 1:num_channels
            avg_cspy_tput(ch) = calculate_avg_tput(cspy_tput(ch, :));
            cspy_sci_accuracy(ch) = nnz(best_real_sci == cspy_sci(ch,:)) / NUM_PRED;
            cspy_tput_accuracy(ch) = nnz(cspy_tput(ch,:) ./ best_real_tput > 0.9) / NUM_PRED;
            cspy_tput_fp(ch) = nnz(cspy_tput(ch,:) < avg_real_tput_channels) / NUM_PRED;
        end
    end


    if(DEBUG3)
        if strfind(schemes, 'our')
            fprintf(['Prediction: ' pred_method '\n']);
            fprintf('  SCI accuracy = %f\n', pred_sci_accuracy);
            fprintf('  Tput accuracy = %f\n', pred_tput_accuracy);
            fprintf('  Tput fp = %f\n', pred_tput_fp);
            fprintf('  Avg tput = %f / %f = %f\n', avg_pred_tput, avg_real_tput, avg_pred_tput / avg_real_tput);
        end

        if strfind(schemes, 'our')
            fprintf(['Random\n']);
            fprintf('  SCI accuracy = %f\n', rand_sci_accuracy);
            fprintf('  Tput accuracy = %f\n', rand_tput_accuracy);
            fprintf('  Tput fp = %f\n', rand_tput_fp);
            fprintf('  Avg tput = %f / %f = %f\n', avg_rand_tput, avg_real_tput, avg_rand_tput / avg_real_tput);
        end

        if strfind(schemes, 'cspy')
            for ch = 1:num_channels
                fprintf(['CSpy channel ' num2str(ch) '\n']);
                fprintf('  SCI accuracy = %f\n', cspy_sci_accuracy(ch));
                fprintf('  Tput accuracy = %f\n', cspy_tput_accuracy(ch));
                fprintf('  Tput fp = %f\n', cspy_tput_fp(ch));
                fprintf('  Avg tput = %f / %f = %f\n', avg_cspy_tput(ch), avg_real_tput, avg_cspy_tput(ch) / avg_real_tput);
            end
        end
    end


    if strfind(schemes, 'our')
        dlmwrite([output_dir 'results/' trace_name '.r' num2str(r) '.' sample_mode '.ch' num2str(num_known_ch) '.' pred_method '.accuracy.txt' ], [pred_sci_accuracy, pred_tput_accuracy, pred_tput_fp, avg_pred_tput, rand_sci_accuracy, rand_tput_accuracy, rand_tput_fp, avg_rand_tput, avg_real_tput]);
        dlmwrite([output_dir 'results/' trace_name '.r' num2str(r) '.' sample_mode '.ch' num2str(num_known_ch) '.' pred_method '.ch_tputs.txt' ], real_ch_tputs);
        dlmwrite([output_dir 'results/' trace_name '.r' num2str(r) '.' sample_mode '.ch' num2str(num_known_ch) '.' pred_method '.pred_sci.txt' ], best_pred_sci);
        dlmwrite([output_dir 'results/' trace_name '.r' num2str(r) '.' sample_mode '.ch' num2str(num_known_ch) '.' pred_method '.mse.txt' ], [mse, mae, cc]);
    end
    

    if strfind(schemes, 'cspy')
        dlmwrite([output_dir 'results/' trace_name '.cspy.txt' ], [cspy_sci_accuracy, cspy_tput_accuracy, cspy_tput_fp, avg_cspy_tput]);
    end
    

    dlmwrite([output_dir 'results/' trace_name '.r' num2str(r) '.' sample_mode '.ch' num2str(num_known_ch) '.' pred_method '.csi_real.txt'], csi_real);
    dlmwrite([output_dir 'results/' trace_name '.r' num2str(r) '.' sample_mode '.ch' num2str(num_known_ch) '.' pred_method '.csi_pred.txt'], csi_pred);

end



%% sample_channels: function description
%%   1) know_all: know all CSI in the history
%%   2) rand_fix: know "num_known_ch" channels in the history, and select a fix set of channels to probe
%%   3) rand: know "num_known_ch" channels in the history, and randomly select different channels to probe everytime
%%   4) equal: know "num_known_ch" channels in the history, and select channels in an equal space sample distribution
function [m] = sample_channels(sx, sample_mode, num_known_ch)
    DEBUG0 = 0;
    DEBUG1 = 0;

    num_channels = 9;
    num_sc = 30;

    %% missing -> 0s
    %% row: subcarriers
    %% col: time
    m = ones(sx);
    m(:, end) = 0;  %% predict the last column


    if (strcmp(sample_mode, 'know_all') | (num_channels == num_known_ch) )
        %% do nothing
    elseif strcmp(sample_mode, 'rand')
        for t = 1:sx(2)-1
            tmp = randperm(num_channels);
            not_sel_ch_inds = sort(tmp(1:num_channels-num_known_ch));
            for ns = not_sel_ch_inds
                ch_std = (ns-1)*num_sc + 1;
                ch_end = ns*num_sc;
                
                m(ch_std:ch_end, t) = 0;
            end
        end
    elseif strcmp(sample_mode, 'rand_fix')
        tmp = randperm(num_channels);
        not_sel_ch_inds = sort(tmp(1:num_channels-num_known_ch));
        for ns = not_sel_ch_inds
            ch_std = (ns-1)*num_sc + 1;
            ch_end = ns*num_sc;
            if(DEBUG1); fprintf('    not selected channel %d: %d-%d\n', ns, ch_std, ch_end); end;

            m(ch_std:ch_end, :) = 0;
        end

    elseif strcmp(sample_mode, 'base_rand_fix')
        tmp = randperm(num_channels);
        not_sel_ch_inds = sort(tmp(1:num_channels-num_known_ch));
        len = size(m, 2);
        for ns = not_sel_ch_inds
            ch_std = (ns-1)*num_sc + 1;
            ch_end = ns*num_sc;
            if(DEBUG1); fprintf('    not selected channel %d: %d-%d\n', ns, ch_std, ch_end); end;

            m(ch_std:ch_end, ceil(len/2):end) = 0;
        end

    elseif strcmp(sample_mode, 'equal')
        for t = 1:sx(2)-1
            if num_known_ch == 1
                sel_ch_inds = [5];
            elseif num_known_ch == 2
                sel_ch_inds = [3,7];
            elseif num_known_ch == 3
                sel_ch_inds = [3,6,8];
            elseif num_known_ch == 4
                sel_ch_inds = [2,4,6,8];
            elseif num_known_ch == 5
                sel_ch_inds = [2,4,5,7,9];
            elseif num_known_ch == 6
                sel_ch_inds = [1,3,4,5,7,9];
            elseif num_known_ch == 7
                sel_ch_inds = [1,3,4,5,7,8,9];
            elseif num_known_ch == 8
                sel_ch_inds = [1,2,3,4,5,7,8,9];
            elseif num_known_ch == 9
                sel_ch_inds = [1,2,3,4,5,6,7,8,9];
            else
                error(['wrong number of known channels: ' int2str(num_known_ch)]);
            end

            sel_ch_inds = mod(sel_ch_inds + t - 2, num_channels) + 1;

            not_sel_ch_inds = setxor([1:num_channels], sel_ch_inds);
            for ns = not_sel_ch_inds
                ch_std = (ns-1)*num_sc + 1;
                ch_end = ns*num_sc;
                
                m(ch_std:ch_end, t) = 0;
            end
        end

    elseif strcmp(sample_mode, 'equal_fix')
        if num_known_ch == 1
            sel_ch_inds = [5];
        elseif num_known_ch == 2
            sel_ch_inds = [3,7];
        elseif num_known_ch == 3
            sel_ch_inds = [3,6,8];
        elseif num_known_ch == 4
            sel_ch_inds = [2,4,6,8];
        elseif num_known_ch == 5
            sel_ch_inds = [2,4,5,7,9];
        elseif num_known_ch == 6
            sel_ch_inds = [1,3,4,5,7,9];
        elseif num_known_ch == 7
            sel_ch_inds = [1,3,4,5,7,8,9];
        elseif num_known_ch == 8
            sel_ch_inds = [1,2,3,4,5,7,8,9];
        elseif num_known_ch == 9
            sel_ch_inds = [1,2,3,4,5,6,7,8,9];
        else
            error(['wrong number of known channels: ' int2str(num_known_ch)]);
        end

        not_sel_ch_inds = setxor([1:num_channels], sel_ch_inds);
        for ns = not_sel_ch_inds
            ch_std = (ns-1)*num_sc + 1;
            ch_end = ns*num_sc;
            if(DEBUG1); fprintf('    not selected channel %d: %d-%d\n', ns, ch_std, ch_end); end;

            m(ch_std:ch_end, :) = 0;
        end

    elseif strcmp(sample_mode, 'base_equal_fix')
        len = size(m, 2);

        if num_known_ch == 1
            sel_ch_inds = [5];
        elseif num_known_ch == 2
            sel_ch_inds = [3,7];
        elseif num_known_ch == 3
            sel_ch_inds = [3,6,8];
        elseif num_known_ch == 4
            sel_ch_inds = [2,4,6,8];
        elseif num_known_ch == 5
            sel_ch_inds = [2,4,5,7,9];
        elseif num_known_ch == 6
            sel_ch_inds = [1,3,4,5,7,9];
        elseif num_known_ch == 7
            sel_ch_inds = [1,3,4,5,7,8,9];
        elseif num_known_ch == 8
            sel_ch_inds = [1,2,3,4,5,7,8,9];
        elseif num_known_ch == 9
            sel_ch_inds = [1,2,3,4,5,6,7,8,9];
        else
            error(['wrong number of known channels: ' int2str(num_known_ch)]);
        end

        not_sel_ch_inds = setxor([1:num_channels], sel_ch_inds);
        for ns = not_sel_ch_inds
            ch_std = (ns-1)*num_sc + 1;
            ch_end = ns*num_sc;
            if(DEBUG1); fprintf('    not selected channel %d: %d-%d\n', ns, ch_std, ch_end); end;

            m(ch_std:ch_end, ceil(len/2):end) = 0;
        end
            
    else
        error(['wrong sample mode: ' sample_mode]);
    end
            

end



%% complete_matrix
function [est] = complete_matrix(data, M, pred_method, r)

    epsilon = 0.01;
    maxDist = 3;
    EPS = 1e-3;
    period = 1; %% temporal stability for SRMF
    alpha = 1;
    lambda = 1;


    if strcmp(pred_method, 'lens_st_knn')
        A = speye(size(data, 1));
        B = speye(size(data, 1));
        C = speye(size(data, 1));
        E = ~M;
        F = ones(size(data));

        soft = 1;
        sigma0 = [];
        
        [x,y,z,w, u,v,s,t, sigma] = lens_st(data, r, A,B,C, E,F, sigma0, soft);

        %% KNN
        est = x+s+t;
        Z = est;

        for i = 1:size(Z,1)
            for j = find(M(i,:) == 0);
                ind = find((M(i,:)==1) & (abs((1:size(Z,2)) - j) <= maxDist));
                if (~isempty(ind))
                    Y  = est(:,ind);
                    C  = Y'*Y;
                    nc = size(C,1);
                    C  = C + max(eps,EPS*trace(C)/nc)*speye(nc);
                    w  = C\(Y'*est(:,j));
                    w  = reshape(w,1,nc);
                    Z(i,j) = sum(est(i,ind).*w);
                end
            end
        end

        est = Z + y;

    elseif strcmp(pred_method, 'lens_st_v2_knn')
        A = speye(size(data, 1));
        B = speye(size(data, 1));
        C = speye(size(data, 1));
        E = ~M;
        F = ones(size(data));

        soft = 1;
        sigma0 = [];
        
        [x,y,z,w, u,v,s,t, sigma] = lens_st_v2(data, r, A,B,C, E,F, sigma0, soft);

        %% KNN
        est = x+s+t;
        Z = est;

        for i = 1:size(Z,1)
            for j = find(M(i,:) == 0);
                ind = find((M(i,:)==1) & (abs((1:size(Z,2)) - j) <= maxDist));
                if (~isempty(ind))
                    Y  = est(:,ind);
                    C  = Y'*Y;
                    nc = size(C,1);
                    C  = C + max(eps,EPS*trace(C)/nc)*speye(nc);
                    w  = C\(Y'*est(:,j));
                    w  = reshape(w,1,nc);
                    Z(i,j) = sum(est(i,ind).*w);
                end
            end
        end

        est = Z + y;

    elseif strcmp(pred_method, 'lens3_knn')
        this_r = r * 1.5;
        sx = size(data);
        A = speye(sx(1));
        B = speye(sx(1));
        C = speye(sx(1));
        E = ~M;
        F = ones(sx);

        soft = 1;
        CC = zeros(sx(2), 1); CC(1,1) = 1;
        RR = zeros(1, sx(2)); RR(1,1) = 1; RR(1,2) = -1;
        P = eye(sx(1)); 
        Q = toeplitz(CC, RR);
        K = zeros(sx);

        [x,y,z,w,enable_B,sig,gamma] = lens3(data,this_r,A,B,C,E,P,Q,K,[],soft);
        
        if (enable_B)
            % est1 = x+y;
            % est2 = A*x+B*y;

            %% KNN
            est = x;
            Z = est;

            for i = 1:size(Z,1)
                for j = find(M(i,:) == 0);
                    ind = find((M(i,:)==1) & (abs((1:size(Z,2)) - j) <= maxDist));
                    if (~isempty(ind))
                        Y  = est(:,ind);
                        C  = Y'*Y;
                        nc = size(C,1);
                        C  = C + max(eps,EPS*trace(C)/nc)*speye(nc);
                        w  = C\(Y'*est(:,j));
                        w  = reshape(w,1,nc);
                        Z(i,j) = sum(est(i,ind).*w);
                    end
                end
            end

            est = Z + y;
        else
            % est1 = x;
            % est2 = A*x;

            %% KNN
            est = x;
            Z = est;

            for i = 1:size(Z,1)
                for j = find(M(i,:) == 0);
                    ind = find((M(i,:)==1) & (abs((1:size(Z,2)) - j) <= maxDist));
                    if (~isempty(ind))
                        Y  = est(:,ind);
                        C  = Y'*Y;
                        nc = size(C,1);
                        C  = C + max(eps,EPS*trace(C)/nc)*speye(nc);
                        w  = C\(Y'*est(:,j));
                        w  = reshape(w,1,nc);
                        Z(i,j) = sum(est(i,ind).*w);
                    end
                end
            end

            est = Z;
        end  

    elseif strcmp(pred_method, 'srmf_lens_st_knn')

        %% LENS-ST
        A = speye(size(data, 1));
        B = speye(size(data, 1));
        C = speye(size(data, 1));
        E = ~M;
        F = ones(size(data));

        soft = 1;
        sigma0 = [];
        
        [x,y,z,w, u,v,s,t, sigma] = lens_st(data, r, A,B,C, E,F, sigma0, soft);

        %% KNN
        est = x+s+t;
        Z = est;

        for i = 1:size(Z,1)
            for j = find(M(i,:) == 0);
                ind = find((M(i,:)==1) & (abs((1:size(Z,2)) - j) <= maxDist));
                if (~isempty(ind))
                    Y  = est(:,ind);
                    C  = Y'*Y;
                    nc = size(C,1);
                    C  = C + max(eps,EPS*trace(C)/nc)*speye(nc);
                    w  = C\(Y'*est(:,j));
                    w  = reshape(w,1,nc);
                    Z(i,j) = sum(est(i,ind).*w);
                end
            end
        end

        est_lens = Z + y;


        %% SRMF
        new_M = M;
        new_M(abs(y) > 0) = 0;

        [A, b] = XM2Ab(data, new_M);
        config = ConfigSRTF(A, b, data, new_M, size(data), r, r, epsilon, true, period);
        [u4, v4] = SRMF(data, r, new_M, config, alpha, lambda, 50);
        
        est = u4 * v4';
        est = max(0, est);

        Z = est;

        for i = 1:size(Z,1)
            for j = find(new_M(i,:) == 0);
                ind = find((new_M(i,:)==1) & (abs((1:size(Z,2)) - j) <= maxDist));
                if (~isempty(ind))
                    Y  = est(:,ind);
                    C  = Y'*Y;
                    nc = size(C,1);
                    C  = C + max(eps,EPS*trace(C)/nc)*speye(nc);
                    w  = C\(Y'*est(:,j));
                    w  = reshape(w,1,nc);
                    Z(i,j) = sum(data(i,ind).*w);
                end
            end
        end

        est_srmf = Z;

        %% Combine
        tmp = size(M);
        if (nnz(~M) / tmp(1) / tmp(2) >= 0.9)
            use_srmf = ones(tmp);
        else
            % this_thresh = mean(abs(y(:))) + 2 * std(abs(y(:)));
            use_srmf = (abs(y) == 0);
        end
        use_lens = ~use_srmf;
        est(find(use_srmf>0)) = est_srmf(find(use_srmf>0));
        est(find(use_lens>0)) = est_lens(find(use_lens>0));

    elseif strcmp(pred_method, 'srmf_lens_st_v2_knn')

        %% LENS-ST
        A = speye(size(data, 1));
        B = speye(size(data, 1));
        C = speye(size(data, 1));
        E = ~M;
        F = ones(size(data));

        soft = 1;
        sigma0 = [];
        
        [x,y,z,w, u,v,s,t, sigma] = lens_st_v2(data, r, A,B,C, E,F, sigma0, soft);

        %% KNN
        est = x+s+t;
        Z = est;

        for i = 1:size(Z,1)
            for j = find(M(i,:) == 0);
                ind = find((M(i,:)==1) & (abs((1:size(Z,2)) - j) <= maxDist));
                if (~isempty(ind))
                    Y  = est(:,ind);
                    C  = Y'*Y;
                    nc = size(C,1);
                    C  = C + max(eps,EPS*trace(C)/nc)*speye(nc);
                    w  = C\(Y'*est(:,j));
                    w  = reshape(w,1,nc);
                    Z(i,j) = sum(est(i,ind).*w);
                end
            end
        end

        est_lens = Z + y;


        %% SRMF
        new_M = M;
        new_M(abs(y) > 0) = 0;

        [A, b] = XM2Ab(data, new_M);
        config = ConfigSRTF(A, b, data, new_M, size(data), r, r, epsilon, true, period);
        [u4, v4] = SRMF(data, r, new_M, config, alpha, lambda, 50);
        
        est = u4 * v4';
        est = max(0, est);

        Z = est;

        for i = 1:size(Z,1)
            for j = find(new_M(i,:) == 0);
                ind = find((new_M(i,:)==1) & (abs((1:size(Z,2)) - j) <= maxDist));
                if (~isempty(ind))
                    Y  = est(:,ind);
                    C  = Y'*Y;
                    nc = size(C,1);
                    C  = C + max(eps,EPS*trace(C)/nc)*speye(nc);
                    w  = C\(Y'*est(:,j));
                    w  = reshape(w,1,nc);
                    Z(i,j) = sum(data(i,ind).*w);
                end
            end
        end

        est_srmf = Z;

        %% Combine
        tmp = size(M);
        if (nnz(~M) / tmp(1) / tmp(2) >= 0.9)
            use_srmf = ones(tmp);
        else
            % this_thresh = mean(abs(y(:))) + 2 * std(abs(y(:)));
            use_srmf = (abs(y) == 0);
        end
        use_lens = ~use_srmf;
        est(find(use_srmf>0)) = est_srmf(find(use_srmf>0));
        est(find(use_lens>0)) = est_lens(find(use_lens>0));

    elseif strcmp(pred_method, 'srmf_knn')
        [A, b] = XM2Ab(data, M);
        config = ConfigSRTF(A, b, data, M, size(data), r, r, epsilon, true, period);
        [u4, v4] = SRMF(data, r, M, config, alpha, lambda, 50);
        
        est = u4 * v4';
        est = max(0, est);

        Z = est;

        for i = 1:size(Z,1)
            for j = find(M(i,:) == 0);
                ind = find((M(i,:)==1) & (abs((1:size(Z,2)) - j) <= maxDist));
                if (~isempty(ind))
                    Y  = est(:,ind);
                    C  = Y'*Y;
                    nc = size(C,1);
                    C  = C + max(eps,EPS*trace(C)/nc)*speye(nc);
                    w  = C\(Y'*est(:,j));
                    w  = reshape(w,1,nc);
                    Z(i,j) = sum(data(i,ind).*w);
                end
            end
        end

        est = Z;

    else
        error(['wrong prediction method: ' pred_method]);
    end

end


%% calculate_avg_tput
function [avg_tput] = calculate_avg_tput(tputs)
    etx = sum(sum(1 ./ tputs(:)));
    avg_tput = length(tputs(:)) / etx;
end

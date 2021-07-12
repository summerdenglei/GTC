%% --------------------
% 2013/09/24
% Yi-Chao Chen @ UT Austin
%
% calculate_PCA
% 
% @input data: the T*N matrix, where T is # of frames, N is # of pixels
%
%% --------------------

function [latent,U,eigenvector] = calculate_PCA(data)

    %% --------------------
    % Debugs
    %% --------------------
    DEBUG0 = 0;     %% don't print 
    DEBUG1 = 1;     %% print 
    DEBUG2 = 1;     %% program flow

    
    % [COEFF,SCORE,latent] = princomp(data, 'econ');
    [COEFF,SCORE,latent] = princomp(data);
    eigenvector = COEFF;
    
    max_num_PC = length(latent);
    U = zeros(size(data));
    for i = 1:max_num_PC,
        if(latent(i, 1) == 0),
            continue;
        end
        U(:, i) = data * eigenvector(:, i) / sqrt(latent(i, 1));
    end

    if DEBUG0
        fprintf('  size of latent: ');
        fprintf('%d, ', size(latent));
        fprintf('\n  size of U: ');
        fprintf('%d, ', size(U));
        fprintf('\n  size of eigenvector: ');
        fprintf('%d, ', size(eigenvector));
        fprintf('\n');
    end

end
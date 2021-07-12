%% --------------------
% 2013/09/24
% Yi-Chao Chen @ UT Austin
%
% PCA_compress
% 
% @input latent:      PCA output
% @input U:           PCA output
% @input eigenvector: PCA output
% @input num_PC:      number of PCs to represent the video
%
%% --------------------

function [compressed_video_vector] = PCA_compress(latent, U, eigenvector, num_PC)
    
    %% --------------------
    % Debugs
    %% --------------------
    DEBUG0 = 0;     %% don't print 
    DEBUG1 = 1;     %% print 
    DEBUG2 = 0;     %% program flow


    %% --------------------
    %  compressing video using PCA
    %    use only "max_num_PC" PCs to store all pixels of a frame
    %% --------------------
    if DEBUG2
        fprintf('compress video using PCA: # PC = %d\n', num_PC);
    end
    

    %% --------------------
    %  calculate compressed mov:
    %    X` = sum_(i=1-r) delta_i * u_i * v_i' 
    %% --------------------
    compressed_video_vector = sqrt(latent(1)) * U(:, 1) * eigenvector(:, 1)';
    for i = 2:num_PC,
        compressed_video_vector = compressed_video_vector + sqrt(latent(i)) * U(:, i) * eigenvector(:, i)';
    end

end


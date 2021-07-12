%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Yi-Chao Chen
%% 2013.10.19 @ UT Austin
%%
%% - Input:
%%   @const: the constant to scale the gravity model
%%      set const to 0 to enumerate it to get the best one.
%%   @opt_dist: option to determine if the gravity model takes distance into consideration
%%      1: gravity model = c * M1 * M2 / dist^2
%%      0: gravity model = c * M1 * M2
%%
%% - Output:
%%
%% e.g.
%%   [coeff] = gravity('TM_Airport_period5_.exp0.', 12, 300, 300)
%%     
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [coeff] = gravity(filename, num_frames, width, height, const, opt_dist)
    addpath('../utils');

    %% --------------------
    %% DEBUG
    %% --------------------
    DEBUG0 = 0;
    DEBUG1 = 1;
    DEBUG2 = 1;


    %% --------------------
    %% Variable
    %% --------------------
    input_TM_dir  = '../processed_data/subtask_inject_error/TM_err/';
    input_4sq_dir = '../processed_data/subtask_process_4sq/TM/';
    output_dir    = '../processed_data/subtask_gravity/output/';


    %% --------------------
    %% Check input
    %% --------------------
    if nargin < 5, const = 0; end
    if nargin < 6, opt_dist = 1; end
    

    %% --------------------
    %% Main starts
    %% --------------------

    %% --------------------
    %% Read location and mass of each venue
    %% --------------------
    if DEBUG2, fprintf('Read location and mass of each venue\n'); end
    [location, mass] = get_venue_info([input_4sq_dir filename], '4sq', width, height);

    if DEBUG0
        fprintf('  size of location: %d, %d\n', size(location));
        fprintf('  size of mass: %d, %d\n', size(mass));
    end

    %% --------------------
    %% M1 * M2, distance
    %% --------------------
    m1m2 = mass * mass';
    distance = get_dist_mat(location, 'latlng');
    if DEBUG0
        fprintf('  size of m1m2: %d, %d\n', size(m1m2));
        fprintf('  size of distance: %d, %d\n', size(distance));
    end


    %% --------------------
    %% Read data matrix
    %% --------------------
    if DEBUG2, fprintf('read data matrix\n'); end

    data = zeros(width, height, num_frames);
    for frame = [0:num_frames-1]
        if DEBUG0, fprintf('  frame %d\n', frame); end

        %% load data matrix
        this_matrix_file = [input_TM_dir filename int2str(frame) '.txt'];
        if DEBUG0, fprintf('    file = %s\n', this_matrix_file); end
        
        tmp = load(this_matrix_file);
        data(:,:,frame+1) = tmp(1:width, 1:height);
        this_frame = data(:,:,frame+1);

        %% --------------------
        %% Estimate the constant of the model
        %% --------------------
        this_const = const;
        if const == 0
            if DEBUG2, fprintf('Estimate the constant of the model\n'); end

            if opt_dist == 1
                %% --------------------
                %% a) c * M1 * M2 / dist(1,2)^2
                %% --------------------
                min_delta = -1;
                min_c = -1;
                base = m1m2 ./ power(distance, 2);
                for c = power(10, [-20:-10])
                    
                    gravity_model = c * base;
                    delta = sum(abs(gravity_model(:) - this_frame(:)));
                    if DEBUG0, fprintf('    const=%e, delta=%f\n', c, delta); end

                    if (delta < min_delta) | (min_c < 0)
                        min_delta = delta;
                        min_c = c;
                    end
                end

            elseif opt_dist == 0
                %% --------------------
                %% b) c * M1 * M2
                %% --------------------
                base = m1m2;
                for c = power(10, [-20:-10])
                    
                    gravity_model = c * base;
                    delta = sum(abs(gravity_model(:) - this_frame(:)));
                    if DEBUG0, fprintf('    const=%e, delta=%f\n', c, delta); end

                    if (delta < min_delta) | (min_c < 0)
                        min_delta = delta;
                        min_c = c;
                    end
                end
            else
                fprintf('opt_dist error\n');
                return;
            end

            this_const = min_c;
            if DEBUG2, fprintf('  frame %d, const=%e, delta=%f, frame_sum=%f\n', frame, min_c, min_delta, sum(this_frame(:))); end
        end


        %% --------------------
        %% Calculate the gravity model
        %% --------------------
        if DEBUG2, fprintf('Calculate the gravity model\n'); end

        if opt_dist == 1
            %% --------------------
            %% a) c * M1 * M2 / dist(1,2)^2
            %% --------------------
            model = this_const * m1m2 ./ power(distance, 2);
        elseif opt_dist == 0
            %% --------------------
            %% b) c * M1 * M2
            %% --------------------
            model = this_const * m1m2;
        end
        

        [R, P] = corrcoef(this_frame(:), model(:)); 
        coeff(frame+1) = R(2,1);
        fprintf('  frame %d, correlation coefficient = %f\n', frame, coeff(frame+1));
    end

    if DEBUG0, fprintf('  size of ground truth: %d, %d\n', size(ground_truth)); end
    if DEBUG0, fprintf('  size of data matrix: %d, %d, %d\n', size(data)); end

end


%% get_dist_array
function [dist_mat] = get_dist_mat(location, dist_type)
    
    if dist_type == 'latlng'
        n = size(location, 1);
        dist_mat = zeros(n, n);
        for i = 1:n
            for j = i:n
                dist = pos2dist(location(i,1), location(i,2), location(j,1), location(j,2), 2);
                % fprintf('(%f,%f) (%f,%f)=%f\n', location(i,1), location(i,2), location(j,1), location(j,2), dist);
                
                dist_mat(i,j) = dist;
                dist_mat(j,i) = dist;
            end
        end
        dist_mat(dist_mat == 0) = 1;
    end
end

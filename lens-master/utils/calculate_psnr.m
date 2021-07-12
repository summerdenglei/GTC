%% --------------------
% 2013/09/24
% Yi-Chao Chen @ UT Austin
%
% calculate_psnr
%% --------------------

function [psnr] = calculate_psnr(mov1, mov2, frames)
    for k = 1:frames
        mse(k) = sum((double(mov1(k).imgYuv(:)) - double(mov2(k).imgYuv(:))) .^ 2) / length(mov1(k).imgYuv(:));
    end

    msemean = (sum(mse) / length(mse));
    %% compute the psnr 
    if msemean ~= 0
        psnr = 10*log10((255^2)/msemean);
    else
        psnr = Inf;
    end
end



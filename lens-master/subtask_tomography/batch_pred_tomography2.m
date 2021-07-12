%% batch_pred_tomography: function description
function batch_pred_tomography()


    if(0)
        fprintf('=====================\nAnomaly Size:\n');

        trace_name = 'abilene'
        num_anom = 0.05;
        sigma_mags = [0, 0.1, 0.5, 1, 1.5, 2, 2.5, 3, 5];
        ret = zeros(8, length(sigma_mags));
        
        for si = 1:length(sigma_mags)
            sigma_mag = sigma_mags(si);

            [mad_lens3, mad_base, mad_srmf, mad_gvt, mad_tg, mad_tg_lens3, mad_tg_srmf, mad_tg_base] = pred_tomography(num_anom, sigma_mag, trace_name);
            ret(1, si) = mad_lens3;
            ret(2, si) = mad_base;
            ret(3, si) = mad_srmf;
            ret(4, si) = mad_gvt;
            ret(5, si) = mad_tg;
            ret(6, si) = mad_tg_srmf;
            ret(7, si) = mad_tg_lens3;
            ret(8, si) = mad_tg_base;
        end

        dlmwrite(['results.anom_size.' trace_name '.txt'], [sigma_mags', ret'], 'delimiter', '\t');
    end
    


    if(1)
        fprintf('=====================\nNumber of Anomalies\n');

        trace_name = 'abilene'
        num_anoms = [0, 0.01, 0.02, 0.04, 0.08, 0.16, 0.2];
        sigma_mag = 1;
        ret = zeros(3, length(num_anoms));
        
        for ni = 1:length(num_anoms)
            num_anom = num_anoms(ni);

            [mad_lens3, mad_base, mad_srmf, mad_gvt, mad_tg, mad_tg_lens3, mad_tg_srmf, mad_tg_base] = pred_tomography(num_anom, sigma_mag, trace_name);
            ret(1, ni) = mad_lens3;
            ret(2, ni) = mad_base;
            ret(3, ni) = mad_srmf;
            ret(4, ni) = mad_gvt;
            ret(5, ni) = mad_tg;
            ret(6, ni) = mad_tg_srmf;
            ret(7, ni) = mad_tg_lens3;
            ret(8, ni) = mad_tg_base;
        end
        dlmwrite(['results.num_anom.' trace_name '.txt'], [num_anoms', ret'], 'delimiter', '\t');
    end


end

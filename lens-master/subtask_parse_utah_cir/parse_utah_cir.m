% PURPOSE: Plot power delay profiles from all measurements.  Serves as an
%          example of how to access data in savedSig.mat.
%
% AUTHOR: Neal Patwari (August 2007)
%
% NOTES:
% - Multiple  measurements were taken at each link.  Usually, 5
%     measurements exist, but occasionally, interference reduced the number 
%     of valid measurements.  "length(savedStartTime_ns{tx,rx})" is the
%     number of valid measurements on link (tx,rx).
% - The time in ns of the first sample was saved for each measurement.
%     This start time varies because only samples after the noise
%     threshold trigger were saved.
% - Each measurement record has only 50 samples - after
%     50*8.333 ns after the first multipath, there was no multipath.
% - Effectively, any sample prior the first sample or after the last sample
%     is effectively zero.
% - The sampling period delta_t is 8.333 ns, the same for all measurements.
% 
% REFERENCES:
%
% [1]  N. Patwari, A. O. Hero, M. Perkins, N. S. Correal, R. J. O'Dea, 
%      Relative Location Estimation in Wireless Sensor Networks, IEEE 
%      Transactions on Signal Processing, vol. 51, no. 8, August 2003, 
%      pp. 2137-2148.
% [2]  N. Patwari and S. K. Kasera, Robust Location Distinction using 
%      Temporal Link Signatures, to appear in 13th Int. Conf. on Mobile 
%      Computing and Networking (Mobicom-07), Montreal, QC, Sept 12, 2007.
% [3]  SPAN Lab website: http://span.ece.utah.edu
%

load '../data/utah_cir/savedSig/savedSig.mat' % Contains: savedSig savedStartTime_ns delta_t

% for tx = 1:44,
for tx = 1:3,
    % for rx = 1:44,
    for rx = 1:3,
        
        fprintf('tx=%d, rx=%d: length = %d\n', tx, rx, length(savedStartTime_ns{tx,rx}));

        % Multiple measurements were taken at each link.
        for meast = 1:length(savedStartTime_ns{tx,rx}),
            t = savedStartTime_ns{tx,rx}(meast) + (0:49)*delta_t;
            

            % abs(savedSig{tx,rx}(meast,:))
            % Plot the magnitude in dB (relative to transmit power)
            % figure(1);
            % plot(t, 20*log10(abs(savedSig{tx,rx}(meast,:))))
            % set(gca,'FontSize',16);
            % set(gca,'xlim',[-50 550])
            % title(sprintf('Tx %d Rx %d Measurement %d', tx, rx, meast));
            % ylabel('Channel power gain (dB)')
            % xlabel('Time (ns)')
            
            % % Plot the real and imaginary parts separately
            % figure(2);
            % subplot(2,1,1);
            % plot(t, real(savedSig{tx,rx}(meast,:)));
            % set(gca,'FontSize',16);
            % set(gca,'xlim',[-50 550])
            % ylabel('Real')
            % title(sprintf('Tx %d Rx %d Measurement %d', tx, rx, meast));
            % subplot(2,1,2);
            % plot(t, imag(savedSig{tx,rx}(meast,:)));
            % set(gca,'FontSize',16);
            % set(gca,'xlim',[-50 550])
            % ylabel('Imag')
            % xlabel('Time (ns)')
            
            % pause
        end
    end
end

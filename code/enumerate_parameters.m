function enumerate_parameters()
% =================================================================
% Generates parameter_grid.csv with all 744 instances.
% Writes to <repo_root>/data/parameter_grid.csv.
% =================================================================

% --- Output folder (absolute path, independent of pwd) ---
repo_root  = 'C:\Users\chris\Documents\GitHub\secure-dlsc-ugk-cyclic';
data_dir   = fullfile(repo_root, 'data');
output_csv = fullfile(data_dir, 'parameter_grid.csv');

if ~exist(data_dir, 'dir')
    mkdir(data_dir);
    fprintf('Created folder: %s\n', data_dir);
end

% --- Parameter ranges ---
N_vals  = [4, 5, 6];
Nr_vals = 2:6;
S_vals  = 1:6;
q_vals  = [5, 7, 11];
L_vals  = 1:4;
Kc      = 1;

% --- Build rows ---
rows = {};
for N = N_vals
    for Nr = Nr_vals
        if Nr > N, continue; end
        for S = S_vals
            if S > N, continue; end
            for q = q_vals
                for L = L_vals
                    r = N - Nr + 1;
                    if S >= r
                        eta = Nr - 1;
                    else
                        eta = Nr - 1 + ceil((Nr - 1) / S);
                    end
                    rows(end+1, :) = {N, N, Nr, Kc, S, q, L, r, eta}; %#ok<AGROW>
                end
            end
        end
    end
end

% --- Write to CSV ---
T = cell2table(rows, 'VariableNames', ...
    {'N','K','Nr','Kc','S','q','L','r','eta_candidate'});
writetable(T, output_csv);
fprintf('Wrote %d rows to %s\n', height(T), output_csv);
end
function build_all_incidence()
% =================================================================
% Builds and saves the data- and key-incidence matrices for all
% structural configurations (N, Nr, S) with N in {4,5,6}.
%
% Outputs:
%   <repo_root>/data/incidence_matrices/config_N4_Nr2_S1.mat
%   <repo_root>/data/incidence_matrices/config_N4_Nr2_S2.mat
%   ... (one .mat file per configuration)
%   <repo_root>/data/incidence_summary.csv
% =================================================================

repo_root = 'C:\Users\chris\Documents\GitHub\secure-dlsc-ugk-cyclic';
data_dir  = fullfile(repo_root, 'data');
inc_dir   = fullfile(data_dir, 'incidence_matrices');
summary_csv = fullfile(data_dir, 'incidence_summary.csv');

if ~exist(data_dir, 'dir'), mkdir(data_dir); end
if ~exist(inc_dir, 'dir'),  mkdir(inc_dir);  end

rows = {};
for N = 4:6
    for Nr = 2:N
        r = N - Nr + 1;
        for S = 1:N
            MD = build_data_incidence(N, Nr);
            MK = build_key_incidence(N, S);

            % Save each configuration as a .mat file
            filename = sprintf('config_N%d_Nr%d_S%d.mat', N, Nr, S);
            save(fullfile(inc_dir, filename), 'N', 'Nr', 'S', 'r', 'MD', 'MK');

            % Summary row
            rows(end+1, :) = {N, Nr, S, r, size(MD,1), size(MD,2), ...
                size(MK,1), size(MK,2)}; %#ok<AGROW>
        end
    end
end

T = cell2table(rows, 'VariableNames', ...
    {'N','Nr','S','r','MD_rows','MD_cols','MK_rows','MK_cols'});
writetable(T, summary_csv);
fprintf('Wrote %d configurations to %s\n', height(T), inc_dir);
fprintf('Wrote summary to %s\n', summary_csv);
end

% =====================================================================
% Helper: build_data_incidence
% =====================================================================
function MD = build_data_incidence(N, Nr)
r = N - Nr + 1;
MD = zeros(N, N);
for k = 1:N
    for j = 0:r-1
        n = mod((k-1) + j, N) + 1;
        MD(n, k) = 1;
    end
end
end

% =====================================================================
% Helper: build_key_incidence
% =====================================================================
function MK = build_key_incidence(N, S)
key_subsets = nchoosek(1:N, S);
num_keys = size(key_subsets, 1);
MK = zeros(N, num_keys);
for g = 1:num_keys
    for idx = 1:S
        n = key_subsets(g, idx);
        MK(n, g) = 1;
    end
end
end
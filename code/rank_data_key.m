function rank_data_key()
    % =================================================================
    % Generates rank_data_key.csv with the modular ranks of the UGK
    % key-incidence matrices over GF(5), GF(7), and GF(11).
    %
    % Output: <repo_root>/data/rank_data_key.csv
    % =================================================================

    repo_root = 'C:\Users\chris\Documents\GitHub\secure-dlsc-ugk-cyclic';
    data_dir  = fullfile(repo_root, 'data');
    output_csv = fullfile(data_dir, 'rank_data_key.csv');

    if ~exist(data_dir, 'dir')
        mkdir(data_dir);
    end

    rows = {};
    for N = 4:6
        for S = 1:N
            MK = build_key_incidence(N, S);
            num_keys = size(MK, 2);
            rank5  = rank_mod(MK, 5);
            rank7  = rank_mod(MK, 7);
            rank11 = rank_mod(MK, 11);
            rows(end+1, :) = {N, S, num_keys, rank5, rank7, rank11}; %#ok<AGROW>
        end
    end

    T = cell2table(rows, 'VariableNames', ...
        {'N','S','num_keys','rank_GF5','rank_GF7','rank_GF11'});
    writetable(T, output_csv);
    fprintf('Wrote %d rows to %s\n', height(T), output_csv);
end

% =====================================================================
% Helper: build_key_incidence
% =====================================================================
function MK = build_key_incidence(N, S)
    % Builds the UGK key-incidence matrix M_K for a given (N, S).
    % Key groups are indexed by all S-subsets of [N].

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

% =====================================================================
% Helper: rank_mod
% =====================================================================
function r = rank_mod(M, p)
    [m, n] = size(M);
    M = mod(M, p);
    r = 0;
    pivot_row = 1;
    for col = 1:n
        if pivot_row > m, break; end
        piv = [];
        for row = pivot_row:m
            if mod(M(row, col), p) ~= 0
                piv = row;
                break;
            end
        end
        if isempty(piv), continue; end
        if piv ~= pivot_row
            temp = M(pivot_row, :);
            M(pivot_row, :) = M(piv, :);
            M(piv, :) = temp;
        end
        inv_pivot = pow_mod(M(pivot_row, col), p - 2, p);
        for row = pivot_row+1:m
            if mod(M(row, col), p) ~= 0
                factor = mod(M(row, col) * inv_pivot, p);
                M(row, :) = mod(M(row, :) - factor * M(pivot_row, :), p);
            end
        end
        pivot_row = pivot_row + 1;
        r = r + 1;
    end
end

% =====================================================================
% Helper: pow_mod
% =====================================================================
function y = pow_mod(base, exp, p)
    y = 1;
    base = mod(base, p);
    while exp > 0
        if mod(exp, 2) == 1
            y = mod(y * base, p);
        end
        exp = floor(exp / 2);
        base = mod(base * base, p);
    end
end
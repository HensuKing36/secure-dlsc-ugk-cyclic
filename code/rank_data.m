function rank_data()
    % =================================================================
    % Generates rank_data.csv with the modular ranks of the incidence
    % matrices over GF(5), GF(7), and GF(11).
    %
    % Output: <repo_root>/data/rank_data.csv
    %
    % The file has one row per structural configuration, with columns:
    %   N, Nr, r, rank_GF5, rank_GF7, rank_GF11, field_sensitive
    %
    % This script is self-contained: all helper functions (build_data_incidence,
    % rank_mod, inv_mod, pow_mod) are defined at the bottom of the file.
    % =================================================================

    % --- Output folder ---
    repo_root = 'C:\Users\chris\Documents\GitHub\secure-dlsc-ugk-cyclic';
    data_dir  = fullfile(repo_root, 'data');
    output_csv = fullfile(data_dir, 'rank_data.csv');

    if ~exist(data_dir, 'dir')
        mkdir(data_dir);
        fprintf('Created folder: %s\n', data_dir);
    end

    % --- Build rows ---
    rows = {};
    for N = 4:6
        for Nr = 2:N
            r = N - Nr + 1;
            MD = build_data_incidence(N, Nr);
            rank5  = rank_mod(MD, 5);
            rank7  = rank_mod(MD, 7);
            rank11 = rank_mod(MD, 11);
            field_sensitive = (rank5 ~= rank7) || (rank7 ~= rank11);
            rows(end+1, :) = {N, Nr, r, rank5, rank7, rank11, field_sensitive}; %#ok<AGROW>
        end
    end

    % --- Write to CSV ---
    T = cell2table(rows, 'VariableNames', ...
        {'N','Nr','r','rank_GF5','rank_GF7','rank_GF11','field_sensitive'});
    writetable(T, output_csv);
    fprintf('Wrote %d rows to %s\n', height(T), output_csv);
end

% =====================================================================
% Helper: build_data_incidence
% =====================================================================
function MD = build_data_incidence(N, Nr)
    % Builds the cyclic data-incidence matrix M_D for a given (N, Nr).
    % Under cyclic placement with window r = N - Nr + 1, dataset k is
    % stored on servers k, k+1, ..., k+r-1 (mod N).

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
% Helper: rank_mod
% =====================================================================
function r = rank_mod(M, p)
    % Computes the rank of matrix M over GF(p) using modular Gaussian
    % elimination. M is reduced in place; pivoting is done by the first
    % nonzero entry.

    [m, n] = size(M);
    M = mod(M, p);
    r = 0;
    pivot_row = 1;
    for col = 1:n
        if pivot_row > m
            break;
        end

        % Find a pivot in the current column, below the current row.
        piv = [];
        for row = pivot_row:m
            if mod(M(row, col), p) ~= 0
                piv = row;
                break;
            end
        end
        if isempty(piv)
            continue;
        end

        % Swap rows to bring the pivot to pivot_row.
        if piv ~= pivot_row
            temp = M(pivot_row, :);
            M(pivot_row, :) = M(piv, :);
            M(piv, :) = temp;
        end

        % Eliminate all entries below the pivot in this column.
        pivot_val = M(pivot_row, col);
        inv_pivot = inv_mod(pivot_val, p);
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
% Helper: inv_mod
% =====================================================================
function x = inv_mod(a, p)
    % Computes the modular inverse of a mod p using Fermat's little
    % theorem. Valid only when p is prime and a is not divisible by p.
    x = pow_mod(a, p - 2, p);
end

% =====================================================================
% Helper: pow_mod
% =====================================================================
function y = pow_mod(base, exp, p)
    % Computes base^exp mod p using fast exponentiation.
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
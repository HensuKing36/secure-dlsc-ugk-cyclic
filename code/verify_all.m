function verify_all()
    % =================================================================
    % Runs the finite-field verification pipeline over a small grid of
    % (N, Nr, S, q, L) instances.
    % Writes to <repo_root>/data/verification_log.txt and
    % <repo_root>/data/verification_summary.csv.
    % =================================================================

    repo_root   = 'C:\Users\chris\Documents\GitHub\secure-dlsc-ugk-cyclic';
    data_dir    = fullfile(repo_root, 'data');
    log_file    = fullfile(data_dir, 'verification_log.txt');
    summary_csv = fullfile(data_dir, 'verification_summary.csv');

    if ~exist(data_dir, 'dir'), mkdir(data_dir); end

    fid = fopen(log_file, 'w');
    fprintf(fid, '%-4s %-4s %-4s %-4s %-4s %-6s %-8s %-8s %-8s\n', ...
        'N','Nr','S','q','L','eta','recovery','secrecy','outcome');
    fprintf(fid, '%s\n', repmat('-', 1, 70));

    summary_rows = {};

    for N = 4:5
        for Nr = 2:N
            for S = max(1, N-Nr) : N
                for q = [5, 7]
                    for L = 1:2
                        [best_eta, rec_ok, sec_ok] = search_encoder(N, Nr, S, q, L, 30);

                        if rec_ok && sec_ok
                            outcome = 'PASS';
                        elseif rec_ok
                            outcome = 'SECFAIL';
                        elseif sec_ok
                            outcome = 'RECFAIL';
                        else
                            outcome = 'BOTHFAIL';
                        end

                        if isinf(best_eta)
                            eta_str = '--';
                        else
                            eta_str = sprintf('%d', best_eta);
                        end

                        fprintf(fid, '%-4d %-4d %-4d %-4d %-4d %-6s %-8s %-8s %-8s\n', ...
                            N, Nr, S, q, L, eta_str, ...
                            bool_str(rec_ok), bool_str(sec_ok), outcome);

                        summary_rows(end+1, :) = {N, Nr, S, q, L, ...
                            best_eta, rec_ok, sec_ok, outcome}; %#ok<AGROW>
                    end
                end
            end
        end
    end

    fclose(fid);

    T = cell2table(summary_rows, 'VariableNames', ...
        {'N','Nr','S','q','L','eta','recovery','secrecy','outcome'});
    writetable(T, summary_csv);

    fprintf('Wrote verification log to %s\n', log_file);
    fprintf('Wrote verification summary to %s\n', summary_csv);
end

% =====================================================================
function [best_eta, rec_ok, sec_ok] = search_encoder(N, Nr, S, q, L, trials)
    best_eta = Inf;
    rec_ok = false;
    sec_ok = false;
    F = ones(1, N);
    for trial = 1:trials
        X = random_encoder(N, Nr, S, L, q);
        [r_ok, s_ok] = check_encoder(X, F, q, N, Nr, L);
        eta = count_used_keys(X, L);
        if r_ok && s_ok && eta < best_eta
            best_eta = eta;
            rec_ok = r_ok;
            sec_ok = s_ok;
        end
    end
end

% =====================================================================
function X = random_encoder(N, Nr, S, L, q)
    key_subsets = nchoosek(1:N, S);
    num_keys = size(key_subsets, 1);
    total_cols = N*L + num_keys*L;
    total_rows = N*L;
    X = zeros(total_rows, total_cols);

    for n = 1:N
        for l = 1:L
            row = (n-1)*L + l;
            for k = 1:N
                if stores_dataset(n, k, N, Nr)
                    col = (k-1)*L + l;
                    X(row, col) = randi([0, q-1]);
                end
            end
            for g = 1:num_keys
                if any(key_subsets(g, :) == n)
                    col = N*L + (g-1)*L + l;
                    X(row, col) = randi([0, q-1]);
                end
            end
        end
    end
end

% =====================================================================
function b = stores_dataset(n, k, N, Nr)
    r = N - Nr + 1;
    window = mod((k-1) + (0:r-1), N) + 1;
    b = any(window == n);
end

% =====================================================================
function [rec_ok, sec_ok] = check_encoder(X, F, q, N, Nr, L)
    k_data = N * L;
    M_data = X(:, 1:k_data);
    M_mask = X(:, k_data+1:end);

    % ---- Recovery check ----
    rec_ok = true;
    subsets = nchoosek(1:N, Nr);
    rank_F = rank_mod(F, q);
    for s = 1:size(subsets, 1)
        R = subsets(s, :);
        rows_R = [];
        for n = R
            rows_R = [rows_R, (n-1)*L + (1:L)]; %#ok<AGROW>
        end
        if rank_mod(M_data(rows_R, :), q) < rank_F
            rec_ok = false;
            break;
        end
    end

    % ---- Secrecy check ----
    rank_mask = rank_mod(M_mask, q);
    sec_ok = (rank_mask >= N - 1);
end

% =====================================================================
function eta = count_used_keys(X, L)
    mask_cols = X(:, end - L*L + 1 : end);
    num_nonzero = sum(any(mask_cols ~= 0, 1));
    eta = max(1, ceil(num_nonzero / L));
end

% =====================================================================
function s = bool_str(b)
    if b, s = 'PASS'; else, s = 'FAIL'; end
end
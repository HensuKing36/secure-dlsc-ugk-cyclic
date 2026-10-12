function r = rank_mod(M, p)
% =================================================================
% Computes the rank of matrix M over GF(p) using modular Gaussian
% elimination. Requires p to be prime.
% =================================================================

[m, n] = size(M);
M = mod(M, p);
r = 0;
pivot_row = 1;
for col = 1:n
    if pivot_row > m, break; end

    % Find pivot
    piv = [];
    for row = pivot_row:m
        if mod(M(row, col), p) ~= 0
            piv = row;
            break;
        end
    end
    if isempty(piv), continue; end

    % Swap rows
    if piv ~= pivot_row
        temp = M(pivot_row, :);
        M(pivot_row, :) = M(piv, :);
        M(piv, :) = temp;
    end

    % Eliminate below
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
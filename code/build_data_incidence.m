function MD = build_data_incidence(N, Nr)
% =================================================================
% Builds the cyclic data-incidence matrix M_D for a given (N, Nr).
%
% Under cyclic placement with window r = N - Nr + 1, dataset k is
% stored on servers k, k+1, ..., k+r-1 (mod N).
% =================================================================

r = N - Nr + 1;
MD = zeros(N, N);
for k = 1:N
    for j = 0:r-1
        n = mod((k-1) + j, N) + 1;
        MD(n, k) = 1;
    end
end
end
function y = pow_mod(base, exp, p)
% =================================================================
% Computes base^exp mod p using fast exponentiation.
%
% Inputs:
%   base -- integer base
%   exp  -- nonnegative integer exponent
%   p    -- positive integer modulus
%
% Output:
%   y    -- base^exp mod p, in the range [0, p-1]
% =================================================================

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
% Test File

% Rename
reduit(rename, Z ?= X, [Z ?= X, W ?= f(Z,c,b), Y ?= Z], Q).
reduit(rename, Z ?= X, [Z ?= X, X ?= f(Z,c,b), Y ?= Z], Q).

% Decompose
reduit(decompose, f(X, d, a) ?= f(Z, c, b), [f(X, d, a) ?= f(Z, c, b), Z ?= X, Y ?= Z], Q).

% Orient
reduit(orient, f(a, b, c) ?= A, [f(a, b, c) ?= A, f(A, d, a) ?= f(Z, c, b), Z ?= X, Y ?= A], Q).
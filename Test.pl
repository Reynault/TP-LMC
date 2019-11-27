% Test File

% Rename
reduit(rename, Z ?= X, [Z ?= X, W ?= f(Z,c,b), Y ?= Z], Q).
reduit(rename, Z ?= X, [Z ?= X, X ?= f(Z,c,b), Y ?= Z], Q).

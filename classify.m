function [ TY ] = classify( family, method, TX, X, Y )
%COPULA.CLASSIFY 

% Size and dimensions of the training dataset
n = size(X);
% Size of the test dataset
t = size(TX, 1);

% Obtain list of classes
K = unique(Y);
numClasses = numel(K);
% Test that classes are ordered
assert(isequal(K, sort(K)), 'Classes do not have the right order.');

% Compute prior probabilities for each class
p = zeros(numClasses, 1);
for i=1:numClasses
    p(i) = sum(Y == K(i)) / n;
end

% Fit a copula for each class depending on the fit method
dbg('copulas.classify', 3, 'Fitting copulas for class.\n');
L = cell(numClasses, 1);
for i=1:numClasses
    L{i} = likelihoodForClass(family, method, X(Y == i), TX);
end

% Compute posterior probabilities for each class.
PP = zeros(n, numClasses);
for i=1:numClasses
    PP(i) = prod(L{i}, 2) * p(i);
end

% For each sample choose class with the highest likelihood and if they are
% same use highest copula likelihood, otherwise choose randomly.
TY = zeros(t, 1);
for i=1:t
    maxIndices = allmax(PP(i, :));
    if numel(maxIndices) == 1
        TY(i) = maxIndices;
    else
        maxIndices = allmax(L(i, 1));
        if numel(maxIndices) == 1
            TY(i) = maxIndices;
        else
            % Choose random value
            TY(i) = randi(numClasses);     
        end   
    end    
end

end


function [ L ] = likelihoodForClass(family, method, X, TX)
%EVALUATECLASS Evaluates likelihood of a single class

% Fit a copula for each class depending on the fit method
dbg('copulas.classify', 3, 'Fitting copulas for class.\n');
      
% Run preprocessing if required.
if ismember(family, {'claytonhac*', 'gumbelhac*', 'frankhac*'})
    P = hac.preprocess( family(1:end-4), X, method );
    X = X * P;
    % Test data need to be preprocessed too
    TX = TX * P;
    family = family(1:end-1);
end
    
% Uniform data 
if strcmp(method, 'CML')  
    U = uniform(X);
elseif strcmp(method, 'IFM')
    margins = fitmargins(X);
    U = pit(X, {margins.ProbDist});
else
    error('Unknown method %s', method);
end        

% Fit copula to uniformed data
copulaparams = copula.fit(family, U);

% Compute likelihood for estimated copula
dbg('copulas.classify', 3, 'Computing likelihood for class %d.\n', i);

[n, d] = size(X);
L = zeros(n, d+1);
if strcmp(method, 'CML')
    L(:,1) = copula.pdf(copulaparams, empcdf(X, TX));
    L(:,2:d+1) = emppdf(X, TX);
elseif strcmp(method, 'IFM')
    L(:,1) = copula.pdf(copulaparams, pit(TX, {margins.ProbDist}));
    L(:,2:d+1) = problike(TX, {margins.ProbDist});
else
    error('Unknown method %s', method);
end

end

function [ xi ] = allmax( x )
%ALLMAX Given a vector x provides indices of all maximum values.
xi = find(x == max(x));
end


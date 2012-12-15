%% FX Rates 
% Dataset consists of 4 columns: CAD, EUR, GBP, JPY

names = {'CAD', 'EUR', 'GBP', 'JPY'};

%% Read prices data and create returns

fxPrices = csvread('../Data/fxdata-small.txt');
fxReturns = price2ret(fxPrices);
uniformFxReturns = uniform(fxReturns);

[n, d] = size(fxReturns);

cad = fxReturns(:,1);
eur = fxReturns(:,2);
gbp = fxReturns(:,3);
jpy = fxReturns(:,4);

%% Basic statistics

mean(fxReturns);
std(fxReturns);
kurtosis(fxReturns);
skewness(fxReturns);

%% Plot prices

figure
for i=1:d
    subplot(2,2,i);
    plot(fxPrices(:,i));
    title(names{i});
end

%% Plot returns

figure
for i=1:d
    subplot(2,2,i);
    plot(fxReturns(:,i));
    ylim([-0.05, 0.05]);
    title(names{i});
end

%% Fit ARMA/GARCH model CAD

[h, p, stat, critical] = lbqtest(cad-mean(cad), [10 15 20]')
[ coeff, errors, LLF, innovations, sigmas, summary ] = armagarchfit(cad, 0, 0, 1, 1);
garchdisp(coeff, errors);
garchplot(innovations, sigmas, cad);
plot(innovations./sigmas);
stdInnovations = (innovations./sigmas);
autocorr(stdInnovations.^2);
[h, p, stat, critical] = lbqtest(stdInnovations.^2, [10 15 20]')

%% Fit ARMA/GARCH model EUR

[h, p, stat, critical] = lbqtest(eur-mean(eur), [10 15 20]')


%% Fit ARMA/GARCH model GBP

[h, p, stat, critical] = lbqtest(gbp-mean(gbp), [10 15 20]')
[ coeff, errors, LLF, innovations, sigmas, summary ] = armagarchfit(gbp, 0, 0, 1, 1);
garchdisp(coeff, errors);
garchplot(innovations, sigmas, gbp);
plot(innovations./sigmas);
stdInnovations = (innovations./sigmas);
autocorr(stdInnovations.^2);
[h, p, stat, critical] = lbqtest(stdInnovations.^2, [10 15 20]')


%% Fit ARMA/GARCH model JPY

[h, p, stat, critical] = lbqtest(jpy-mean(jpy), [10 15 20]')
[ coeff, errors, LLF, innovations, sigmas, summary ] = armagarchfit(jpy, 0, 0, 1, 1);
garchdisp(coeff, errors);
garchplot(innovations, sigmas, jpy);
plot(innovations./sigmas);
stdInnovations = (innovations./sigmas);
autocorr(stdInnovations.^2);
[h, p, stat, critical] = lbqtest(stdInnovations.^2, [10 15 20]')

%% Convert each series to standardized residuals later in fitting

fxInnovations = zeros(n, d);
for i=1:d
    [~, ~, ~, innovations, sigmas] = armagarchfit(fxReturns(:,i), 0, 0, 1, 1);
    fxInnovations(:,i) = innovations ./ sigmas;
end

%% Perform fit using CML

copula.eval('gaussian', uniformFxReturns, 1000);
copula.eval('t', uniformFxReturns, 10);
copula.eval('clayton', uniformFxReturns, 1000);
copula.eval('gumbel', uniformFxReturns, 1000);
copula.eval('frank', uniformFxReturns, 1000);
copula.eval('claytonhac', uniformFxReturns, 10, 'okhrin');
copula.eval('gumbelhac', uniformFxReturns, 10, 'okhrin');
copula.eval('frankhac', uniformFxReturns, 10, 'okhrin');

%% Perform fit using IFM

dists = {'tlocationscale', 'tlocationscale', 'tlocationscale', 'tlocationscale'};
pitFxInnovations = pit(fxInnovations, dists);
copula.eval('gaussian', pitFxInnovations, 1000);
copula.eval('t', pitFxInnovations, 10);
copula.eval('clayton', pitFxInnovations, 1000);
copula.eval('gumbel', pitFxInnovations, 1000);
copula.eval('frank', pitFxInnovations, 1000);
copula.eval('claytonhac', pitFxInnovations, 0, 'okhrin');
copula.eval('gumbelhac', pitFxInnovations, 0, 'okhrin');
copula.eval('frankhac', pitFxInnovations, 0, 'okhrin');




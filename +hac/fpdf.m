function [ Y ] = fastpdf( family, U, tree )
%HACPDF Probability distribution function of family of HAC.
%   Derives and evalutes symbolic expression of density function for given
%   HAC.

% Compose high level symbolic functions
[expr, params] = hac.fpdf.expr(tree);

% Perform its derivations in all variables
fexpr = sym(expr);
vars = symvar(fexpr);
for i=1:numel(vars)
    fexpr = diff(fexpr, vars(i));
end

% Replace terms inside it with variables
[inexpr, terms] = hac.fpdf.substitute(char(fexpr));

% Convert infix expression into its postfix form
postexpr = hac.fpdf.in2post(inexpr);

%Evaluate the postfix form




end
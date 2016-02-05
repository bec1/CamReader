function out = fit2dgaussian(xdata,ydata,seed,fixedparams)
% Does a 2d fit of a gaussian with tilt angle to the data and returns a
% vector with the optimized parameter set

% ----------------------------------------------------- %
% Parameters in seed and fixedparams                    %
% ----------------------------------------------------- %
% 1 Gaussian Amplitude      5 Horizontal Gaussian width %
% 2 Offset                  6 Vertical Gaussian width   %
% 3 Horizontal position     7 Tilt angle                %
% 4 Vertical position                                   %
% ----------------------------------------------------- %

lb = [0,-8.4,0,0,eps,eps,0]; % lower bounds
ub = [10^4,10^4,2048,2048,2048,2048,pi/4]; % upper bounds

% Take into account the fixed parameters
numparams = 7-sum(fixedparams(:)); % Number of varied parameters
variedparams = [];  % List of the indexes of these
for k = 1:7
    if fixedparams(k) == 0
        variedparams = cat(2,variedparams,k);
    end % if
end % for

lb = lb(variedparams);
ub = ub(variedparams);

fitf = @(p,xdata)f(p,xdata,seed,fixedparams,variedparams); % Function to be
% called by the fitting routine, does the interface to the real function
% and takes into account the fixed parameters

reducedseed = zeros(1,numparams); % The seed for the varied parameters only.
l=1;
for k=1:7
    if fixedparams(k) == 0
        reducedseed(l) = seed(k);
        l = l+1;
    end % if
end % for

% Do the fit!
options = optimset('Jacobian','on','TolX',1e-1,'TolFun',1e-4);
params = ...
    lsqcurvefit(fitf,reducedseed,xdata,ydata,lb,ub,options);

% Prepare the output
out = zeros(1,7);
l = 1;
for k = 1:7
    if fixedparams(k) == 0
        out(1,k) = params(l);
        l = l+1;
    else
        out(1,k) = seed(k);
    end % if
end % for

end % fit2dgaussian

% The actual fitting function: a gaussian with tilt angle
function [F,J] = f(q,xdata,seed,fixed,variedparams)
% Construct the argument vector from the fixed (seed) and varied (q)
% parameters.
% p1 the overall ampl, p(2) offset, p(3) x0 p(4) y0 p(5) Xvariance P(6)
% Yvariance p(7) tilting angle.
numparams = 7-sum(fixed(:));
p = [];
l = 1;
for k = 1:size(seed,2)
    if fixed(k) == 1
        p = cat(2,p,seed(k));
    else
        p = cat(2,p,q(l));
        l = l + 1;
    end
end

% Calculate the function
X =  (xdata{2}-p(3))*cos(p(7))+(xdata{1}-p(4))*sin(p(7));
Y = -(xdata{2}-p(3))*sin(p(7))+(xdata{1}-p(4))*cos(p(7));

F=p(1)*exp(-(X.^2/(2*p(5)^2)+Y.^2/(2*p(6)^2)))+p(2);

% If requested (evidently, we do), calculate the Jacobian. We do not
% optimize this to the last: we always calculate the full jacobian and then
% only take what corresponds to actually varied parameters. The loss in
% speed is negligible.
if nargout > 1
    numpoints = size(X,1)*size(X,2);
  
    K = zeros(numpoints,7);
      K(:,1) = reshape((F-p(2))/p(1),numpoints,1);
      K(:,2) = 1;
      K(:,3) = reshape((F-p(2)).*(X/p(5)^2*cos(p(7))-Y/p(6)^2*sin(p(7))),numpoints,1);
      K(:,4) = reshape((F-p(2)).*(X/p(5)^2*sin(p(7))+Y/p(6)^2*cos(p(7))),numpoints,1);
      K(:,5) = reshape((F-p(2)).*X.^2/p(5)^3,numpoints,1);
      K(:,6) = reshape((F-p(2)).*Y.^2/p(6)^3,numpoints,1);
      K(:,7) = reshape((F-p(2)).*X.*Y*(1/p(6)^2-1/p(5)^2),numpoints,1);
      
    J=K(:,variedparams);
end % if
end % f


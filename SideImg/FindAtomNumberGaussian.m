function atomnumber = FindAtomNumberGaussian( img )
%FINDATOMNUMBERG Summary of this function goes here
%   Detailed explanation goes here
[Xc,Yc]=CMass(img);
[Yr,Xr]=size(img);
sigma0=sqrt(Xr*Yr)/2;
P = FitGaussian( img,Xc,Yc,sigma0);
if isnan(P)
    atomnumber = nan;
else 
    atomnumber=P(3)^2*P(4)*2*pi;
end
end


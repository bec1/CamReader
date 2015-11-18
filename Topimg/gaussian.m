function Y = gaussian(X,sigma,Xc,Yc,a,b)
dX=X{1}-Xc;
dY=X{2}-Yc;
r=dX.^2+dY.^2;
Y=a*exp(-r/(2*(sigma.^2)))+b;
end


function P = FitGaussian( Image,Xc1,Yc1,sigma )
%P(1): x0, P(2): y0, P(3):sigma, P(4):A (amplitute) P(5):B(offset)
RangeX=size(Image,2);
RangeY=size(Image,1);
[X,Y]=meshgrid(1:RangeX,1:RangeY);
X=X(:);
Y=Y(:);
Xdata={X,Y};
Ydata=Image(:);
a=max(Ydata)-min(Ydata);
b=min(Ydata);
fitfun = @(p,X)(gaussian(X,p(3),p(1),p(2),p(4),p(5)));
try
    P=nlinfit(Xdata,Ydata,fitfun,[Xc1,Yc1,sigma,a,b]);
catch 
    disp('Warning: Gaussian fit failed')
    P = nan;
end
end


[X,Y]=meshgrid(-2.5:0.02:2.5,-2.5:0.02:2.5);
G=exp(-X.^2-Y.^2/2-(X-Y).^2/10)*10^3;
imagesc(G)
GaussianFittingFunction(G)
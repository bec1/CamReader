function [ Xc,Yc ] = CMass( image )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
[m,n]=size(image);
Sum=0;
SumX=0;
SumY=0;
for i=1:n
    for j=1: m
        Sum=Sum+image(j,i);
        SumX=SumX+i*image(j,i);
        SumY=SumY+j*image(j,i);
    end
end
Xc=SumX/Sum;
Yc=SumY/Sum;
end


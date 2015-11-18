function img=Readaia(filename)
%read the absorption image from aia or fits file
% For aia files, load the three base images (with atoms, without atoms,
% background), calculate the absorption image and prepare everything
% for display
% For fits files, just load the image and do the log.

%get the file format first
dotpos = findstr('.',filename);
format=filename(max(dotpos)+1:end);

if (strcmp(format, 'aia'))
    fid=fopen(filename,'r');
    header=fread(fid,5,'uint8');
    sizes=fread(fid,3,'uint16');
    rows=sizes(1);
    columns=sizes(2);
    I_fin=reshape(fread(fid,rows*columns,'uint16'),columns,rows);
    I_init=reshape(fread(fid,rows*columns,'uint16'),columns,rows);
    I_dark=reshape(fread(fid,rows*columns,'uint16'),columns,rows);
    fclose(fid);
    [m,n]=size(I_dark);
    img=zeros(m,n,3);
    img(:,:,1)=I_fin;
    img(:,:,2)=I_init;
    img(:,:,3)=I_dark;
end


end
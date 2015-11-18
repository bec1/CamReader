%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%
%   opens .aia files and creates a matrix of each frame
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



%data

folder= 'C:\Users\Tarik\BEC1\Data Analysis\2012\2012-08\2012-08-09\Resonance imgpower=.5 GPIB100 DC 50pct\';
a=dir([folder,'*.aia']);


%analysis parameters
roi=[185 305 10 125];
normsize=20;

%initialisation
all_norm_avg(length(a))=0;
all_norm_std(length(a))=0;
all_detunings(length(a))=0;

%physical constants
h=6.626068e-34;% Int. Units.
Gamma= 5.8724;%in MHz
Isat=25.4;%in W/m2
nu= 446.799677e12;% 6Li D2-line

%experimental parameters to be introduced by user !!!!
resonance_freq = 180; %in MHz 
tau_exp=0.40e-6;% GPIB 900 <-> 400ns
pix=16e-6;% pixelsize
mag=5.4;% magnification
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
adu=1.16;% e-/ADU for 5MHz, gain 3
qeff=0.91;% for 671nm
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%experimental paremeters deduced
Nsat = (qeff/adu)*Isat*(pix/mag)^2*tau_exp/(h*nu);

for(i=1:length(a))
    
    %%%%%%%%%%%%%% DO NOT CHANGE %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    s1=[folder,a(i).name];
    fid=fopen(s1,'r');
    header=fread(fid,5,'uint8');
    sizes=fread(fid,3,'uint16');
    rows=sizes(1);
    columns=sizes(2);
    I_fin=reshape(fread(fid,rows*columns,'uint16'),columns,rows);
    I_init=reshape(fread(fid,rows*columns,'uint16'),columns,rows);
    I_dark=reshape(fread(fid,rows*columns,'uint16'),columns,rows);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    
    %paremeters of the experiments
    params=[];
    values=[];
    while(not(feof(fid)))
        s=[];
        while(true)
            c=fread(fid,1,'char');
            if(c==0)
                break;
            end
            s=[s c];
        end
        params=[params char(s) ' '];
        values=[values fread(fid,1,'double')];
        fread(fid,1,'uint8');
    end
    
    %frames
    I_fin=1.0*(I_fin-I_dark);
    I_init=1.0*(I_init-I_dark);
    I_fin_roi=I_fin(roi(1):roi(2),roi(3):roi(4));
    I_init_roi=I_init(roi(1):roi(2),roi(3):roi(4));
    
    if i==1
        
        %for images processing
        %---------------------
        
        %whole window
        all_I_fin=zeros(size(I_fin,1),size(I_fin,2),length(a));
        all_I_init=zeros(size(I_init,1),size(I_init,2),length(a));
        all_I_ratio=zeros(size(all_I_fin));
        all_I_diff=zeros(size(all_I_fin));
        %roi
        all_I_fin_roi = zeros(size(I_fin_roi,1),size(I_fin_roi,2),length(a));
        all_I_init_roi = zeros(size(I_init_roi,1),size(I_init_roi,2),length(a));
        all_I_ratio_roi = zeros(size(all_I_fin_roi));
        all_I_diff_roi = zeros(size(all_I_fin_roi));
        all_norm = zeros(size(all_I_fin_roi));
        all_norm_nnan = zeros(size(all_I_fin_roi,1)*size(all_I_fin_roi,2));
        %renormalized arrays
        all_I_init_renorm = zeros(size(all_I_fin_roi));
        all_I_ratio_renorm = zeros(size(all_I_fin_roi));
        
        % for storing the parameters
        %----------------------------
        
        all_params=zeros(size(values,2),length(a));
    end
    
    %storing relevant quantities
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    all_I_fin(:,:,i)=I_fin;
    all_I_init(:,:,i)=I_init;
    all_I_ratio(:,:,i)=all_I_fin(:,:,i)./all_I_init(:,:,i);
    all_I_diff(:,:,i)=all_I_fin(:,:,i)- all_I_init(:,:,i);
    
    all_I_fin_roi(:,:,i)=I_fin_roi;
    all_I_init_roi(:,:,i)=I_init_roi;
    all_I_ratio_roi(:,:,i)=all_I_fin_roi(:,:,i)./all_I_init_roi(:,:,i);
    all_I_diff_roi(:,:,i)=all_I_fin_roi(:,:,i)- all_I_init_roi(:,:,i);
    
    all_norm(:,:,i) = all_I_ratio_roi(:,:,i);
    all_norm((normsize:(end-normsize)),:,i) = nan;
    
    
    %reshape into a 1D array 
    %remove non nan values and calculate de stats
    %----------------------
    
    all_norm_nnan=reshape(all_norm(:,:,i),[size(all_norm,1)*size(all_norm,2),1]);
    nans_indexes = find(isnan(all_norm_nnan));
    all_norm_nnan(nans_indexes) = [];
   
    all_norm_avg(i) = mean(all_norm_nnan);
    all_norm_std(i) = std(all_norm_nnan,1);
    all_I_init_renorm(:,:,i)=all_norm_avg(i).*all_I_init_roi(:,:,i);
    all_I_ratio_renorm(:,:,i)=all_I_fin_roi(:,:,i)./all_I_init_renorm(:,:,i);
    
    % storing parameters
    %%%%%%%%%%%%%%%%%%%%%%
    
    all_params(:,i)=values; 
    all_detunings= 2*(all_params(2,:)-resonance_freq)/Gamma;%delta/Gamma
    
end


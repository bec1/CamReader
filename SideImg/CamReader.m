function varargout = CamReader(varargin)
% CAMREADER MATLAB code for CamReader.fig
%      CAMREADER, by itself, creates a new CAMREADER or raises the existing
%      singleton*.
%
%      H = CAMREADER returns the handle to a new CAMREADER or the handle to
%      the existing singleton*.
%
%      CAMREADER('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in CAMREADER.M with the given input arguments.
%
%      CAMREADER('Property','Value',...) creates a new CAMREADER or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before CamReader_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to CamReader_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help CamReader

% Last Modified by GUIDE v2.5 04-Feb-2016 16:15:01

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @CamReader_OpeningFcn, ...
                   'gui_OutputFcn',  @CamReader_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before CamReader is made visible.
function CamReader_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to CamReader (see VARARGIN)

% Choose default command line output for CamReader
handles.output = hObject;
YearString=datestr(now,'yyyy');
MonthString = datestr(now,'yyyy-mm');
DateString = datestr(now,'yyyy-mm-dd');
handles.outfolder=['\\Elder-pc\j\Elder Backup Raw Images\',YearString,'\',MonthString,'\',DateString];
set(handles.OutFolder,'String',handles.outfolder);
username=getenv('USERNAME');
handles.secoutfolder=['C:\Users\',username,'\Dropbox (MIT)\BEC1\Image Data and Cicero Files\Data - Raw Images\',YearString,'\',MonthString,'\',DateString];
set(handles.SecOutFolder,'String',handles.secoutfolder);
ex=exist(handles.outfolder,'dir');
if (ex~=7)
    try
        mkdir(handles.outfolder);
    catch
        msgbox('Cannot find or create the default folder');
        set(handles.OutFolder,'String','C:\');
    end
end
ex=exist(handles.secoutfolder,'dir');
if (ex~=7)
    try
        mkdir(handles.secoutfolder);
    catch
        msgbox('Cannot find or create the secondary default folder');
        set(handles.OutFolder,'String','C:\secondary');
        mkdir('C:\secondary');
    end
end

%set up the input infolder
handles.infolder='C:\data\Side imaging';
set(handles.InFolder,'String',handles.infolder);

handles.list={};
handles.listshow={};
blank=zeros(64);
handles.img=image('Parent',handles.axes1,'CData',blank);
setappdata(gcf,   'CurrentImage'    , 0); 
%initialize the image space in GUI


%initialize the atom number counting parameter.
handles.sigma=str2double(get(handles.CrossSection,'string'));
handles.pixelsize=str2double(get(handles.PixelSize,'string'));
handels.satcount=str2double(get(handles.SatCount,'string'));
handles.xmin=round(str2double(get(handles.Xmin,'string')));
handles.xmax=round(str2double(get(handles.Xmax,'string')));
handles.ymin=round(str2double(get(handles.Ymin,'string')));
handles.ymax=round(str2double(get(handles.Ymax,'string')));
set(handles.Counting,'value',0);
set(handles.Bgsub,'value',0);
handles.scanning=false;

%setup the parameter table for fitting
Data=[{'Amplitude';'Offset';'X0';'Y0';'sigma_X';'sigma_Y';'theta'},{0;0;0;0;0;0;0}];
set(handles.ParaTab,'data',Data);
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes CamReader wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = CamReader_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on selection change in Imagelist.
function Imagelist_Callback(hObject, eventdata, handles)
% hObject    handle to Imagelist (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns Imagelist contents as cell array
%        contents{get(hObject,'Value')} returns selected item from Imagelist

var1=get(handles.Imagelist,'value');
var2=get(handles.Framelist,'value');
imgname=get(handles.Imagelist,'String');
img=fitsreadRL(handles.list{var1});
setappdata(gcf,   'CurrentImage'    , img); 
num=var2-1;
% img=fitsread([handles.outfolder,'\',imgname{var1}]);
% if num==0
%     frame=real(-log((img(:,:,1)-img(:,:,3))./(img(:,:,2)-img(:,:,3))));
% else
%     if num==4
%         frame=real(((img(:,:,1)-img(:,:,3))./(img(:,:,2)-img(:,:,3))));
%     else
%         frame=img(:,:,num);
%     end
% end

if num==0
    frame=real(-log((img(:,:,1)-img(:,:,3))./(img(:,:,2)-img(:,:,3))));
    if get(handles.AutoScaleRaw,'value')
        set(handles.Custom,'value',1);
    end
else
    if num==4
        frame=real(((img(:,:,1)-img(:,:,3))./(img(:,:,2)-img(:,:,3))));
        if get(handles.AutoScaleRaw,'value')
            set(handles.Custom,'value',1);
        end
    else
        if (num==1)||(num==2)||(num==3)
            frame=img(:,:,num);
            if get(handles.AutoScaleRaw,'value')
                set(handles.Rescale,'value',1);
            end
        else
            set(handles.Imagelist,'value',1);
            frame=real(-log((img(:,:,1)-img(:,:,3))./(img(:,:,2)-img(:,:,3))));
        end
    end
end


set(handles.NameTag,'String',handles.listshow{var1});
showimage(frame,handles);
if get(handles.Counting,'value') % do the atom counting
    %get all the initial parameter
    sigma=str2double(get(handles.CrossSection,'string'));
    pixelsize=str2double(get(handles.PixelSize,'string'));
    satcount=str2double(get(handles.SatCount,'string'));
    xmin=round(str2double(get(handles.Xmin,'string')));
    xmax=round(str2double(get(handles.Xmax,'string')));
    ymin=round(str2double(get(handles.Ymin,'string')));
    ymax=round(str2double(get(handles.Ymax,'string')));
    % crop the img
    Xr=size(img(:,:,1),2);
    Yr=size(img(:,:,1),1);
    xmin=max(1,xmin);
    xmax=min(Xr,xmax);
    ymin=max(1,ymin);
    ymax=min(Yr,ymax);
    atomcountimg=img;
    atomnumbermap=AtomNumber(atomcountimg,pixelsize,sigma, satcount);
    
%     if get(handles.Bgsub,'value')
%         bgimg = atomnumbermap(ymax:ymax+53, xmin:xmax,:);
%         [bgx,bgy] = size(bgimg);
%         bgCount = sum(sum(bgimg))/(bgx*bgy)
%     else 
%         bgCount = 0
%     end
    
    atomnumbermap = atomnumbermap(ymin:ymax,xmin:xmax);
    atomnumber=sum(sum(atomnumbermap));
    Pgaussian=GaussianFittingFunction( atomnumbermap );
    atomnumberG=Pgaussian(1)*Pgaussian(5)*Pgaussian(6)*2*pi;
    set(handles.AtomNumberG,'string',num2str(atomnumberG, '%10.3e' ));
    set(handles.AtomNumberP,'string',num2str(atomnumber, '%10.3e' ));
    DataP=num2cell(Pgaussian');
    set(handles.ParaTab,'data',[{'Amplitude';'Offset';'X0';'Y0';'sigma_X';'sigma_Y';'theta'},DataP]);
end
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function Imagelist_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Imagelist (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in Scan.
function Scan_Callback(hObject, eventdata, handles)
% hObject    handle to Scan (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.Scanning,'value',not(get(handles.Scanning,'value')));
guidata(hObject,handles);
while get(handles.Scanning,'value')
    NewFileList=dir([handles.infolder,'\*.fits']);
    N=size(NewFileList,1);
    newnamelist={};
    newnamelistshow={};
    pause(0.2);
    for i=1:N
        temp=NewFileList(i);
        newnamelist=[[handles.outfolder,'\',temp.name],newnamelist];
        newnamelistshow=[temp.name,newnamelistshow];
        copyfile([handles.infolder,'\',temp.name],[handles.secoutfolder]);
        if get(handles.SecAct,'value')
            movefile([handles.infolder,'\',temp.name],[handles.outfolder,'\',temp.name]);
        end
    end
    handles.list=[newnamelist,handles.list];
    handles.listshow=[newnamelistshow,handles.listshow];
    if N>0
        var2=get(handles.Framelist,'value');
        imgname=handles.list{1};
        imgnameshow=handles.listshow{1};
        num=var2-1;
        img=fitsreadRL(imgname);
        if num==0
            frame=real(-log((img(:,:,1)-img(:,:,3))./(img(:,:,2)-img(:,:,3))));
            if get(handles.AutoScaleRaw,'value')
                set(handles.Custom,'value',1);
            end
        else
            if num==4
                frame=real(((img(:,:,1)-img(:,:,3))./(img(:,:,2)-img(:,:,3))));
                if get(handles.AutoScaleRaw,'value')
                    set(handles.Custom,'value',1);
                end
            else
                if (num==1)||(num==2)||(num==3)
                    frame=img(:,:,num);
                    if get(handles.AutoScaleRaw,'value')
                        set(handles.Rescale,'value',1);
                    end
                else
                    set(handles.Imagelist,'value',1);
                    frame=real(-log((img(:,:,1)-img(:,:,3))./(img(:,:,2)-img(:,:,3))));
                end
            end
        end
        set(handles.NameTag,'String',imgnameshow);
        setappdata(gcf,   'CurrentImage'    , img); 
        guidata(hObject,handles);
        showimage(frame,handles);
        if get(handles.Counting,'value') % do the atom counting
            %get all the initial parameter
            sigma=str2double(get(handles.CrossSection,'string'));
            pixelsize=str2double(get(handles.PixelSize,'string'));
            satcount=str2double(get(handles.SatCount,'string'));
            xmin=round(str2double(get(handles.Xmin,'string')));
            xmax=round(str2double(get(handles.Xmax,'string')));
            ymin=round(str2double(get(handles.Ymin,'string')));
            ymax=round(str2double(get(handles.Ymax,'string')));
            % crop the img
            Xr=size(img(:,:,1),2);
            Yr=size(img(:,:,1),1);
            xmin=max(1,xmin);
            xmax=min(Xr,xmax);
            ymin=max(1,ymin);
            ymax=min(Yr,ymax);
             atomcountimg=img;
    atomnumbermap=AtomNumber(atomcountimg,pixelsize,sigma, satcount);
    
%     if get(handles.Bgsub,'value')
%         bgimg = atomnumbermap(ymax:ymax+53, xmin:xmax,:);
%         [bgx,bgy] = size(bgimg);
%         bgCount = sum(sum(bgimg))/(bgx*bgy)
%     else 
%         bgCount = 0
%     end
    
%     atomnumbermap = atomnumbermap(ymin:ymax,xmin:xmax) - bgCount;
            atomnumbermap = atomnumbermap(ymin:ymax,xmin:xmax);
            atomnumber=sum(sum(atomnumbermap));
            Pgaussian=GaussianFittingFunction( atomnumbermap );
            atomnumberG=Pgaussian(1)*Pgaussian(5)*Pgaussian(6)*2*pi;
            set(handles.AtomNumberG,'string',num2str(atomnumberG, '%10.3e' ));
            set(handles.AtomNumberP,'string',num2str(atomnumber, '%10.3e' ));
            DataP=num2cell(Pgaussian');
            set(handles.ParaTab,'data',[{'Amplitude';'Offset';'X0';'Y0';'sigma_X';'sigma_Y';'theta'},DataP]);
        end
    end
    set(handles.Imagelist,'String',handles.listshow);
    guidata(hObject,handles);
    pause(0.1);
end
guidata(hObject,handles);


% --- Executes on selection change in Framelist.
function Framelist_Callback(hObject, eventdata, handles)
% hObject    handle to Framelist (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns Framelist contents as cell array
%        contents{get(hObject,'Value')} returns selected item from Framelist
% var1=get(handles.Imagelist,'value');
% var2=get(handles.Framelist,'value');
% imgname=get(handles.Imagelist,'String');
% num=var2-1;
% img=fitsread([handles.outfolder,'\',imgname{var1}]);
% if num==0
%     frame=real(-log((img(:,:,1)-img(:,:,3))./(img(:,:,2)-img(:,:,3))));
% else
%     if num==4
%         frame=real(((img(:,:,1)-img(:,:,3))./(img(:,:,2)-img(:,:,3))));
%     else
%         frame=img(:,:,num);
%     end
% end
% set(handles.NameTag,'String',imgname{var1});
% showimage(frame,handles);
% guidata(hObject,handles);

var1=get(handles.Imagelist,'value');
var2=get(handles.Framelist,'value');
imgname=get(handles.Imagelist,'String');
img=fitsreadRL(handles.list{var1});
setappdata(gcf,   'CurrentImage'    , img); 
num=var2-1;
% img=fitsread([handles.outfolder,'\',imgname{var1}]);
% if num==0
%     frame=real(-log((img(:,:,1)-img(:,:,3))./(img(:,:,2)-img(:,:,3))));
% else
%     if num==4
%         frame=real(((img(:,:,1)-img(:,:,3))./(img(:,:,2)-img(:,:,3))));
%     else
%         frame=img(:,:,num);
%     end
% end

if num==0
    frame=real(-log((img(:,:,1)-img(:,:,3))./(img(:,:,2)-img(:,:,3))));
    if get(handles.AutoScaleRaw,'value')
        set(handles.Custom,'value',1);
    end
else
    if num==4
        frame=real(((img(:,:,1)-img(:,:,3))./(img(:,:,2)-img(:,:,3))));
        if get(handles.AutoScaleRaw,'value')
            set(handles.Custom,'value',1);
        end
    else
        if (num==1)||(num==2)||(num==3)
            frame=img(:,:,num);
            if get(handles.AutoScaleRaw,'value')
                set(handles.Rescale,'value',1);
            end
        else
            set(handles.Imagelist,'value',1);
            frame=real(-log((img(:,:,1)-img(:,:,3))./(img(:,:,2)-img(:,:,3))));
        end
    end
end

set(handles.NameTag,'String',imgname{var1});
showimage(frame,handles);

if get(handles.Counting,'value') % do the atom counting
    %get all the initial parameter
    sigma=str2double(get(handles.CrossSection,'string'));
    pixelsize=str2double(get(handles.PixelSize,'string'));
    satcount=str2double(get(handles.SatCount,'string'));
    xmin=round(str2double(get(handles.Xmin,'string')));
    xmax=round(str2double(get(handles.Xmax,'string')));
    ymin=round(str2double(get(handles.Ymin,'string')));
    ymax=round(str2double(get(handles.Ymax,'string')));
    % crop the img
    Xr=size(img(:,:,1),2);
    Yr=size(img(:,:,1),1);
    xmin=max(1,xmin);
    xmax=min(Xr,xmax);
    ymin=max(1,ymin);
    ymax=min(Yr,ymax);
    atomcountimg=img;
    atomnumbermap=AtomNumber(atomcountimg,pixelsize,sigma, satcount);
    
%     if get(handles.Bgsub,'value')
%         bgimg = atomnumbermap(ymax:ymax+53, xmin:xmax,:);
%         [bgx,bgy] = size(bgimg);
%         bgCount = sum(sum(bgimg))/(bgx*bgy)
%     else 
%         bgCount = 0
%     end
    
    atomnumbermap = atomnumbermap(ymin:ymax,xmin:xmax);
    atomnumber=sum(sum(atomnumbermap));
    Pgaussian=GaussianFittingFunction( atomnumbermap );
    atomnumberG=Pgaussian(1)*Pgaussian(5)*Pgaussian(6)*2*pi;
    set(handles.AtomNumberG,'string',num2str(atomnumberG, '%10.3e' ));
    set(handles.AtomNumberP,'string',num2str(atomnumber, '%10.3e' ));
    DataP=num2cell(Pgaussian');
    set(handles.ParaTab,'data',[{'Amplitude';'Offset';'X0';'Y0';'sigma_X';'sigma_Y';'theta'},DataP]);
end
guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function Framelist_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Framelist (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function NHInp_Callback(hObject, eventdata, handles)
% hObject    handle to NHInp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of NHInp as text
%        str2double(get(hObject,'String')) returns contents of NHInp as a double


% --- Executes during object creation, after setting all properties.
function NHInp_CreateFcn(hObject, eventdata, handles)
% hObject    handle to NHInp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in NameHead.
function NameHead_Callback(hObject, eventdata, handles)
% hObject    handle to NameHead (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.namehead=get(handles.NHInp,'String');
set(handles.NHDisp,'String',handles.namehead);
guidata(hObject,handles);

% --- Executes on button press in Browse.
function Browse_Callback(hObject, eventdata, handles)
% hObject    handle to Browse (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
folder_name = uigetdir;
set(handles.InFolder,'String',folder_name);
handles.infolder=folder_name;
guidata(hObject, handles);


% --- Executes on button press in Scanning.
function Scanning_Callback(hObject, eventdata, handles)
% hObject    handle to Scanning (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Scanning



function Min_Callback(hObject, eventdata, handles)
% hObject    handle to Min (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Min as text
%        str2double(get(hObject,'String')) returns contents of Min as a double


% --- Executes during object creation, after setting all properties.
function Min_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Min (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Max_Callback(hObject, eventdata, handles)
% hObject    handle to Max (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Max as text
%        str2double(get(hObject,'String')) returns contents of Max as a double


% --- Executes during object creation, after setting all properties.
function Max_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Max (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in Autosave.
function Autosave_Callback(hObject, eventdata, handles)
% hObject    handle to Autosave (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Autosave


% --- Executes on button press in OutBrowse.
function OutBrowse_Callback(hObject, eventdata, handles)
outdir=uigetdir;
handles.outfolder=outdir;
set(handles.OutFolder,'String',handles.outfolder);
guidata(hObject, handles);
% hObject    handle to OutBrowse (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function NameTag_Callback(hObject, eventdata, handles)
% hObject    handle to NameTag (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of NameTag as text
%        str2double(get(hObject,'String')) returns contents of NameTag as a double


% --- Executes during object creation, after setting all properties.
function NameTag_CreateFcn(hObject, eventdata, handles)
% hObject    handle to NameTag (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in AutoScaleRaw.
function AutoScaleRaw_Callback(hObject, eventdata, handles)
% hObject    handle to AutoScaleRaw (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of AutoScaleRaw


% --- Executes on button press in Custom.
function Custom_Callback(hObject, eventdata, handles)
% hObject    handle to Custom (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Custom


% --- Executes on button press in ROICrop.
function ROICrop_Callback(hObject, eventdata, handles)
% hObject    handle to ROICrop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[~,rect]=imcrop(handles.axes1);
xmin=round(rect(1));
ymin=round(rect(2));
xmax=round(rect(3))+xmin-1;
ymax=round(rect(4))+ymin-1;
set(handles.Xmin,'string',num2str(xmin));
set(handles.Xmax,'string',num2str(xmax));
set(handles.Ymin,'string',num2str(ymin));
set(handles.Ymax,'string',num2str(ymax));

img=getappdata(gcf,   'CurrentImage'  ); 

if get(handles.Counting,'value') % do the atom counting
    %get all the initial parameter
    sigma=str2double(get(handles.CrossSection,'string'));
    pixelsize=str2double(get(handles.PixelSize,'string'));
    satcount=str2double(get(handles.SatCount,'string'));
    % crop the img
    Xr=size(img(:,:,1),2);
    Yr=size(img(:,:,1),1);
    xmin=max(1,xmin);
    xmax=min(Xr,xmax);
    ymin=max(1,ymin);
    ymax=min(Yr,ymax);
    atomcountimg=img;
    atomnumbermap=AtomNumber(atomcountimg,pixelsize,sigma, satcount);
    
%     if get(handles.Bgsub,'value')
%         bgimg = atomnumbermap(ymax:ymax+53, xmin:xmax,:);
%         [bgx,bgy] = size(bgimg);
%         bgCount = sum(sum(bgimg))/(bgx*bgy)
%     else 
%         bgCount = 0
%     end
    
%     atomnumbermap = atomnumbermap(ymin:ymax,xmin:xmax) - bgCount;
    
    atomnumbermap = atomnumbermap(ymin:ymax,xmin:xmax);
    atomnumber=sum(sum(atomnumbermap));
    Pgaussian=GaussianFittingFunction( atomnumbermap );
    atomnumberG=Pgaussian(1)*Pgaussian(5)*Pgaussian(6)*2*pi;
    set(handles.AtomNumberG,'string',num2str(atomnumberG, '%10.3e' ));
    set(handles.AtomNumberP,'string',num2str(atomnumber, '%10.3e' ));
    DataP=num2cell(Pgaussian');
    set(handles.ParaTab,'data',[{'Amplitude';'Offset';'X0';'Y0';'sigma_X';'sigma_Y';'theta'},DataP]);
end

guidata(hObject,handles);


function Xmin_Callback(hObject, eventdata, handles)
% hObject    handle to Xmin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Xmin as text
%        str2double(get(hObject,'String')) returns contents of Xmin as a double


% --- Executes during object creation, after setting all properties.
function Xmin_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Xmin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Xmax_Callback(hObject, eventdata, handles)
% hObject    handle to Xmax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Xmax as text
%        str2double(get(hObject,'String')) returns contents of Xmax as a double


% --- Executes during object creation, after setting all properties.
function Xmax_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Xmax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Ymin_Callback(hObject, eventdata, handles)
% hObject    handle to Ymin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Ymin as text
%        str2double(get(hObject,'String')) returns contents of Ymin as a double


% --- Executes during object creation, after setting all properties.
function Ymin_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Ymin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Ymax_Callback(hObject, eventdata, handles)
% hObject    handle to Ymax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Ymax as text
%        str2double(get(hObject,'String')) returns contents of Ymax as a double


% --- Executes during object creation, after setting all properties.
function Ymax_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Ymax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function PixelSize_Callback(hObject, eventdata, handles)
% hObject    handle to PixelSize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of PixelSize as text
%        str2double(get(hObject,'String')) returns contents of PixelSize as a double


% --- Executes during object creation, after setting all properties.
function PixelSize_CreateFcn(hObject, eventdata, handles)
% hObject    handle to PixelSize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function CrossSection_Callback(hObject, eventdata, handles)
% hObject    handle to CrossSection (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of CrossSection as text
%        str2double(get(hObject,'String')) returns contents of CrossSection as a double


% --- Executes during object creation, after setting all properties.
function CrossSection_CreateFcn(hObject, eventdata, handles)
% hObject    handle to CrossSection (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function AtomNumberP_Callback(hObject, eventdata, handles)
% hObject    handle to AtomNumberP (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of AtomNumberP as text
%        str2double(get(hObject,'String')) returns contents of AtomNumberP as a double


% --- Executes during object creation, after setting all properties.
function AtomNumberP_CreateFcn(hObject, eventdata, handles)
% hObject    handle to AtomNumberP (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in Counting.
function Counting_Callback(hObject, eventdata, handles)
% hObject    handle to Counting (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Counting



function SatCount_Callback(hObject, eventdata, handles)
% hObject    handle to SatCount (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of SatCount as text
%        str2double(get(hObject,'String')) returns contents of SatCount as a double


% --- Executes during object creation, after setting all properties.
function SatCount_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SatCount (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function AtomNumberG_Callback(hObject, eventdata, handles)
% hObject    handle to AtomNumberG (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of AtomNumberG as text
%        str2double(get(hObject,'String')) returns contents of AtomNumberG as a double


% --- Executes during object creation, after setting all properties.
function AtomNumberG_CreateFcn(hObject, eventdata, handles)
% hObject    handle to AtomNumberG (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in SecOutBrowse.
function SecOutBrowse_Callback(hObject, eventdata, handles)
% hObject    handle to SecOutBrowse (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
secoutdir=uigetdir;
handles.secoutfolder=secoutdir;
set(handles.SecOutFolder,'String',handles.secoutfolder);
guidata(hObject, handles);
guidata(hObject,handles);


% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over Max.
function Max_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to Max (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in Bgsub.
function Bgsub_Callback(hObject, eventdata, handles)
% hObject    handle to Bgsub (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Bgsub


% --- Executes on button press in Gfit.
function Gfit_Callback(hObject, eventdata, handles)
% hObject    handle to Gfit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Gfit


% --- Executes on button press in SecAct.
function SecAct_Callback(hObject, eventdata, handles)
% hObject    handle to SecAct (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of SecAct

function showimage(img,handles)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
if get(handles.Direct,'Value')
    image(img,'Parent',handles.axes1,'CDataMapping','direct');
    colormap(handles.axes1,gray(32768));
end
if get(handles.Rescale,'Value')
    image(img,'Parent',handles.axes1,'CDataMapping','scaled');
    colormap(handles.axes1,gray(32768));
end
if get(handles.Custom,'Value')
    min=str2num(get(handles.Min,'string'));
    max=str2num(get(handles.Max,'string'));
    image(img,'Parent',handles.axes1,'CDataMapping','scaled');
    colormap(handles.axes1,gray(32768));
    caxis(handles.axes1,[min max]);
end
set(handles.axes1,'DataAspectRatioMode','manual','DataAspectRatio',[1 1 1],'YDir','normal') ;

end


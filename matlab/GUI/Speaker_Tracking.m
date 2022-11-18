function varargout = Speaker_Tracking(varargin)
% SPEAKER_TRACKING MATLAB code for Speaker_Tracking.fig
%      SPEAKER_TRACKING, by itself, creates a new SPEAKER_TRACKING or raises the existing
%      singleton*.
%
%      H = SPEAKER_TRACKING returns the handle to a new SPEAKER_TRACKING or the handle to
%      the existing singleton*.
%
%      SPEAKER_TRACKING('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SPEAKER_TRACKING.M with the given input arguments.
%
%      SPEAKER_TRACKING('Property','Value',...) creates a new SPEAKER_TRACKING or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Speaker_Tracking_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Speaker_Tracking_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help Speaker_Tracking

% Last Modified by GUIDE v2.5 27-Jun-2013 07:40:23

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Speaker_Tracking_OpeningFcn, ...
                   'gui_OutputFcn',  @Speaker_Tracking_OutputFcn, ...
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





% --- Executes just before Speaker_Tracking is made visible.
function Speaker_Tracking_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Speaker_Tracking (see VARARGIN)

% Choose default command line output for Speaker_Tracking
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes Speaker_Tracking wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = Speaker_Tracking_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in RS232_Connect.
function RS232_Connect_Callback(hObject, eventdata, handles)
% hObject    handle to RS232_Connect (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

SerialObject('connect', hObject, handles);



% --- Executes on button press in RS232_Disconnect.
function RS232_Disconnect_Callback(hObject, eventdata, handles)
% hObject    handle to RS232_Disconnect (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
SerialObject('disconnect', hObject, handles);



% --- Executes on selection change in RS232_Boudrate.
function RS232_Boudrate_Callback(hObject, eventdata, handles)
% hObject    handle to RS232_Boudrate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles = guidata(gcbo);
Str = get(hObject,'String');
handles.s.BaudRate = str2num( cell2mat( Str( get(hObject,'Value')) ) );
guidata(hObject, handles);
disp(handles.s);




% Hints: contents = cellstr(get(hObject,'String')) returns RS232_Boudrate contents as cell array
%        contents{get(hObject,'Value')} returns selected item from RS232_Boudrate


% --- Executes during object creation, after setting all properties.
function RS232_Boudrate_CreateFcn(hObject, eventdata, handles)
% hObject    handle to RS232_Boudrate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in RS232_Receive.
function RS232_Receive_Callback(hObject, eventdata, handles)
% hObject    handle to RS232_Receive (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


if( get(hObject,'Value') )
    % Start receiving data
    set(hObject, 'BackgroundColor', [0.6 1 0]);
    handles = guidata(gcbo);
    disp('Receiving ...')
else
    % Stop receiving data
    set(hObject, 'BackgroundColor', [1 0.4 0.4]);
end


while( get(hObject,'Value') )
    % PlotPolar( 0.1, 0.2, 1, 3, 12 );
    % drawnow;
    msg = fgets(handles.s); %get data from serial port
    % phi = rad2deg(str2num(msg(1:5))/1000);
    % theta = rad2deg(str2num(msg(7:11))/1000);
    
   %  fprintf('Phi: %3.2f, Theta: %3.2f\n', phi, theta);
     fprintf('Msg: %s\n', msg);
     pause(0.001); % macht probleme
    % fprintf('Received: %s', msg);
end
    
    




function SerialObject(param, hObject, handles)

switch param
    case 'connect'
        fprintf('Creating serial object ...\n');
        handles.s = serial( 'COM1', ...
                            'BaudRate', 9600, ...
                            'Terminator', 'CR', ...
                            'Parity','even', ...
                            'FlowControl', 'software', ...
                            'ReadAsyncMode', 'continuous', ...
                            'InputBufferSize', 26 );
        disp(handles.s);
        fprintf('Opening serial object ...\n');
        fopen(handles.s)
        fprintf('Done !\n');
        
      
    case 'disconnect'
        handles = guidata(gcbo);
        fprintf('Close serial object ...\n');
        fclose(handles.s)
        fprintf('Delete serial object ...\n');
        delete(handles.s)
        clear handles.s;
        fprintf('Done!\n');
end

 guidata(hObject, handles);
        


  

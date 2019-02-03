% This program uses the given example program as base code.
% Checked this was ok with the tutor.
% Brian Yuen
% z5115851



% ---------------------------------------
% Example program, useful for solving Asst3, MTRN2500 S2 2018
% Author: j.guivant@unsw.edu.au
% ---------------------------------------
% e.g. run it this way: 
%      Ass3final('C:\Users\brian\Desktop\Job and uni\Uni\MTRN2500\MTRN2500 S2 2018 Asst3 Files\Data\HomeC001\');

function Ass3final(folder)
clc();
if ~exist('folder','var'),
    disp('YOU must specify the folder, where the files are located!');
    disp('I assume some default folder:');
    % I assume a default value, in case the caller does not specify its
    % value.
    folder = 'C:\Users\brian\Desktop\Job and uni\Uni\MTRN2500\MTRN2500 S2 2018 Asst3 Files\Data';
 end;
disp('Using data from folder:');
disp(folder);
 
% load Depth and RGB images.
A = load([folder,'\PSLR_C01_120x160.mat']); CC=A.CC ; A=[];
A = load([folder,'\PSLR_D01_120x160.mat']); CR=A.CR ; A=[];

% length
L  = CR.N;

% Some global variable, for being shared (you may use nested functions, 
% in place of using globals).
global CCC; 
CCC=[]; CCC.flagPause=0; CCC.usefulPoint = 0; CCC.allignment = 0;
CCC.roll = 0; CCC.pitch = 0; CCC.rollSlider = 0; CCC.pitchSlider = 0;
CCC.outerRadius = 0; CCC.innerRadius = 0;
%------------------
% We create the necessary plots/images/figures/etc.

% Create figure, where we will show Depth and RGB images.
figure(2); clf();

% subfigure, for Depth 
subplot(211) ; 
RR=CR.R(:,:,1);
hd = imagesc(RR);
ax=axis();
title('Depth');
colormap gray;
set(gca(),'xdir','reverse');


% In another subfigure, we show the associated RGB image.
subplot(212) ; hc = image(CC.C(:,:,:,1));
title('RGB');
set(gca(),'xdir','reverse');


% .. another figure, for showing 3D points.
fig = figure(5) ; clf() ; 
ha=axes('position',[0.2,0.1,0.75,0.85]);
hp = plot3(ha,0,0,0,'.','markersize',2) ; 

%  Split the points into 2 groups, red and blue.
hold on;
redPoints = plot3(0,0,0,'.','markersize',2, 'color', 'red');

axis([0,3,-1.5,1.5,-0.4,0.9]);
title('3D');
xlabel('X (m)');
ylabel('Y (m)');
zlabel('Z (m)');
grid on;
rotate3d on ;




% Some control buttons (you may define extra buttons, for other purposes)
% (you may apply some cosmetics, for improving how they look.)
uicontrol('Style','pushbutton','String','Pause/Cont.','Position',[10,1,80,20],'Callback',{@MyCallBackA,1});
uicontrol('Style','pushbutton','String','ETC','Position',[90,1,80,20],'Callback',{@MyCallBackA,2});
uicontrol('Style','slider','Position',[10,25,40,150],'Callback',{@callbackPitchSlider});
uicontrol('Style','slider','Position',[10,200,40,150],'Callback',{@callbackRollSlider});
uicontrol('Style','checkbox','String','Useful points','Position',[75, 25, 100, 30],'Callback',{@callbackUsefulPoints});
uicontrol('Style','checkbox','String','Allignment','Position',[75, 50, 75, 30],'Callback',{@callbackAllignment});
uicontrol('Style','checkbox','String','Pitch','Position',[10, 175, 75, 30],'Callback',{@callbackPitch});
uicontrol('Style','checkbox','String','Roll','Position',[10, 350, 75, 30],'Callback',{@callbackRoll});

uicontrol('Style','edit','String','Outer Radius','Position',[150, 350, 75, 30],'Callback',{@callbackOuterRadius});
uicontrol('Style','edit','String','Inner Radius','Position',[150, 380, 75, 30],'Callback',{@callbackInnerRadius});

% We use HANDLES to functions, for specifying CALLBACK functions, associated to these
% control objects.

%--------------------------------------------
% imports my other m file containing my functions for modularity.
lib = LibraryBrian();
% This chunk of text sets the parameters of the useful zone and plots it

zHeight = 0.15;


i=0;
% Periodic loop!
while 1,
     tic;
   lib.plotCircle(CCC.innerRadius, CCC.outerRadius);
    while (CCC.flagPause), pause(0.3)  ; end       %stay here, if stopped.
    i=i+1;
    if i>L, break ; end;
    % Refresh RGB image, updating property 'cdata' of handle hc.
    set(hc,'cdata',CC.C(:,:,:,i));  % show RGB image
    
    RR=CR.R(:,:,i);                 % Depth image
    set(hd,'cdata',RR);             % show it.

   
    % "Processing"
    % obtain 3D points, for those pixels which are not faulty.
    iinz = find(RR>0);    %iinz=[]; <---- if empy, the function assumes ALL.
    
    [xx,yy,zz] = lib.getDepth(RR, iinz);  % Gets depth of the x,y,z points.
    
    %This chunk cuts away the noise before any other options are applied
    angle = pi*-10/180; 
    [xx, yy, zz] = lib.rotate(xx, yy, zz, angle);
    [xx, yy, zz] = lib.checkSize(xx, yy, zz);
    [xx,yy,zz] = lib.useful(xx, yy, zz);
    [xx, yy, zz] = lib.checkSize(xx, yy, zz);
    [xx, yy, zz] = lib.rotate(xx, yy, zz, -angle);
    
    
%     This section checks if the options in the GUI are being used.
    if CCC.pitch == 1
        [xx, yy, zz] = lib.checkSize(xx, yy, zz);
        % This turns the slider into a scaling factor, allows the angle to
        % be between -45 and 45 degrees.
        angle  = (CCC.pitchSlider*90*pi/180)-45*pi/180;
        [xx, yy, zz] = lib.rotate(xx, yy, zz, angle);
        
    end
        
    if CCC.allignment == 1
        [xx, yy, zz] = lib.checkSize(xx, yy, zz);
        angle = pi*-10/180; %The 10 degree angle correction
        [xx, yy, zz] = lib.rotate(xx, yy, zz, angle);
    end
    
    if CCC.roll == 1
        [xx, yy, zz] = lib.checkSize(xx, yy, zz);
        angle  = (CCC.rollSlider*90*pi/180)-45*pi/180;
        [xx, yy, zz] = lib.rotateRoll(xx, yy, zz, angle);
    end
%     This section points the points on the cloud depending on which option
%     is chosen.
    if CCC.usefulPoint == 1
%         [xxUseful, yyUseful, zzUseful] = lib.useful(xx, yy, zz);
        [xxRed, yyRed, zzRed] = lib.interest(xx, yy, zz, CCC.innerRadius, CCC.outerRadius, zHeight);
        [xxBlue, yyBlue, zzBlue] = lib.notInterest(xx, yy, zz, CCC.innerRadius, CCC.outerRadius, zHeight);

        set(hp,'xdata',xxBlue,'ydata',yyBlue,'zdata',zzBlue);
        set(redPoints,'xdata',xxRed,'ydata',yyRed,'zdata',zzRed);
        
    elseif CCC.usefulPoint == 0
        set(redPoints,'xdata',zeros(size(xx)),'ydata',zeros(size(xx)),'zdata',zeros(size(xx)));
        set(hp,'xdata',xx,'ydata',yy,'zdata',zz);  
    end;
     
    pause(0.1);     % freeze for about 0.1 second; approximtely.
     toc;
    end

end

% ---------------------------------------
% Callback function. I defined it, and associated it to certain GUI button,
function MyCallBackA(~,~,x)   
    global CCC;
        
    if (x==1)
       CCC.flagPause = ~CCC.flagPause; %Switch ON->OFF->ON -> and so on.
       disp(x);disp(CCC.flagPause);
       return;
    end;
    if (x==2)
        disp('you pressed ETC!');
        return;
    end;
    return;    
end

% ...............................................
% I associated the following function, as a callback function for one slider control.
% Each time a new value is set, in the slider, our function is called
function callbackPitchSlider(a,~,~)   
     global CCC;
    %  When the system calls our callback function,
    %  it offers us the handle of the slider object itself, through the argument
    %  "a"
    v = get(a,'value');     % the property "value" is the current
                            % value of the slider (position of the selector)
    % You may use it to set the value of certain relevant variable,
    % in your program.
    % Here, I just print its value, for testing purposes.
    CCC.pitchSlider = v;
    
    % BTW: the object ("a"), has many other properties; you may inspect them.  
    return;    
end
function callbackRollSlider(a,~,~)   
     global CCC;
   
    v = get(a,'value');    
    CCC.rollSlider = v;
    return;    
end

% ---------------------------------------
% I associated this function, as a callback function for one CheckBox.
% Each time the state of the checkbx is modified, our function is called
function callbackUsefulPoints(a,~,~)   
    global CCC;
    %  when the system calls our callback function,
    %  it offers us the handle of the object, through the argument
    %  "a"
    v = get(a,'value');     % the property "value" is the current
                            % value of the checkbox object.
    CCC.usefulPoint = ~CCC.usefulPoint;
    
%     disp(CCC.usefulPoint)
    % You may use it to set the value of certain relevant variable,
    % in your program.
    % Here, I just print its value, for testing purposes.
    
    % BTW: the object ("a"), has many other properties; you may inspect them.  
    return;    
end

% All of these callback functions are flags.

function callbackAllignment(a,~,~)   
    global CCC;
   
    CCC.allignment = ~CCC.allignment;
    

    return;    
end

function callbackPitch(a,~,~)   
    global CCC;
   
    CCC.pitch = ~CCC.pitch;
    return;    
end

function callbackRoll(a,~,~)   
    global CCC;
   
    CCC.roll = ~CCC.roll;
    return;    
end

function callbackOuterRadius(a,~,~)   
    global CCC;
    v = str2double(get(a, 'String'));
    
    CCC.outerRadius = v;
    return;    
end

function callbackInnerRadius(a,~,~)   
    global CCC;
    v = str2double(get(a, 'String'));
    
    CCC.innerRadius = v;
    return;    
end
% ---------------------------------------
% ---------------------------------------

% Example program, useful for solving Asst3
% By Jose Guivant (j.guivant@unsw.edu.au)

% ---------------------------------------




function out = mzoom(varargin)
%MZOOM   Zoom in and out on a 2-D plot.
%	Extra features added to ZOOM:
%		1. Arrow keys translate left & right by a whole screen, '<' and '>'
%		   translate by 1/20 of a screen width.
%		2. Features added to support multi-axis zooming, in particular
%		   'zoom out' needed to become xon,yon aware; a new function mzoom xout
%		   was added to handle this. See XZoomAll for taking advantage
%		   of these features.
%		3. The annoying 'zoom out' upon double click was replaced by
%		   alt-click, and now double-clicking spawns a new figure window
%		   with the selected axis (only if there are multiple axes in the
%		   original window).
%   MZOOM with no arguments toggles the zoom state.
%   MZOOM ON turns zoom on for the current figure, while  
%     MZOOM XON or MZOOM YON turns zoom on for the x or y axis only.
%   MZOOM OFF turns zoom off in the current figure.
%   MZOOM OUT returns the plot to its initial (full) zoom, while
%      MZOOM XOUT returns to full zoom along the x axis
%   MZOOM RESET clears the zoom out point, for the current axis only.
%
%   When zoom is on, click the left mouse button to zoom in on the
%   point under the mouse.  Click the right mouse button to zoom out
%   (shift-click on the Macintosh).  Each time you click, the axes
%   limits will be changed by a factor of 2 (in or out).  You can also
%   click and drag to zoom into an area.  Alt-clicking zooms out to
%   the point at which zoom was first turned on for this figure.  Note
%   that turning zoom on, then off does not reset the zoom point.
%   This may be done explicitly with MZOOM RESET.
%   
%   MZOOM(FIG,OPTION) applies the zoom command to the figure specified
%   by FIG. OPTION can be any of the above arguments.

%   MZOOM FILL scales a plot such that it is as big as possible
%   within the axis position rectangle for any azimuth and elevation.

%   Written by Tim Holy 2/17/99, based on "zoom":
%   Clay M. Thompson 1-25-93
%   Revised 11 Jan 94 by Steven L. Eddins
%   Copyright (c) 1984-98 by The MathWorks, Inc.
%   $Revision: 5.34 $  $Date: 1997/12/02 21:08:55 $

%   Note: zoom uses the userdata of the zlabel of the axis and
%   the figure buttondown and buttonmotion functions
%

switch nargin,
   
   %%%%%%%%%%%%%%%%%%%%%%%%%%
   %%% No Input Arguments %%%
   %%%%%%%%%%%%%%%%%%%%%%%%%%
case 0,
   fig=get(0,'currentfigure');
   if isempty(fig), return, end
   zoomCommand='toggle';
   
   %%%%%%%%%%%%%%%%%%%%%%%%%%
   %%% One Input Argument %%%
   %%%%%%%%%%%%%%%%%%%%%%%%%%
case 1,
   
   % If the argument is a string, the argument is a zoom command
   % (i.e. (on, off, down, xdown, etc.).  Otherwise, the argument is
   % assumed to be a figure handle, in which case all we do is
   % toggle the zoom status.
   
   if isstr(varargin{1}),
      fig=get(0,'currentfigure');
      if isempty(fig), return, end
      
      zoomCommand=varargin{1};
   else
      scale_factor=varargin{1};
      zoomCommand='scale';
      fig = gcf;
   end % if
   
   %%%%%%%%%%%%%%%%%%%%%%%%%%%
   %%% Two Input Arguments %%%
   %%%%%%%%%%%%%%%%%%%%%%%%%%%
case 2,
   fig=varargin{1};
   zoomCommand=varargin{2};
   
otherwise,
   error(nargchk(0, 2, nargin));
   
end % switch nargin

%
% handle 'off' commands first
%
if strcmp(zoomCommand,'off'),
   %
   % turn off zoom, and take a hike
   %
   state = getappdata(fig,'ZOOMFigureState');
   if ~isempty(state),
      uirestore(state);
      clruprop(fig,'ZOOMFigureState');
   end
   return
end % if

ax=get(fig,'currentaxes');

rbbox_mode = 0;
zoomx = 1; zoomy = 1; % Assume no constraints

zoomCommand=lower(zoomCommand);

if ~isempty(ax) & any(get(ax,'view')~=[0 90]) & ...
      ~(strcmp(zoomCommand,'scale') | strcmp(zoomCommand,'fill')),
   return % Do nothing
end

if strcmp(zoomCommand,'toggle'),
   state = getappdata(fig,'ZOOMFigureState');
   if isempty(state)
      mzoom(fig,'on');
   else
      mzoom(fig,'off');
   end
   return
end % if

% Catch constrained zoom
if strcmp(zoomCommand,'xdown'),
   zoomy = 0; zoomCommand = 'down'; % Constrain y
elseif strcmp(zoomCommand,'ydown')
   zoomx = 0; zoomCommand = 'down'; % Constrain x
end
if strcmp(zoomCommand,'xout'),
	zoomy = 0; zoomCommand = 'out';
end
% For the scale command, we need to know whether xon, yon, or on
if (strcmp(zoomCommand,'scale'))
	if (strcmp(get(fig,'WindowButtonDownFcn'),'mzoom xdown'))
		zoomy = 0;
	elseif (strcmp(get(fig,'WindowButtonDownFcn'),'mzoom ydown'))
		zoomx = 0;
	end
end

if strcmp(zoomCommand,'down'),
   % Activate axis that is clicked in
   allAxes = findobj(get(fig,'Children'),'flat','type','axes');
   ZOOM_found = 0;
   for i=1:length(allAxes),
      ax=allAxes(i);
      ZOOM_Pt1 = get(ax,'CurrentPoint');
      xlim = get(ax,'xlim');
      ylim = get(ax,'ylim');
      if (xlim(1) <= ZOOM_Pt1(1,1) & ZOOM_Pt1(1,1) <= xlim(2) & ...
            ylim(1) <= ZOOM_Pt1(1,2) & ZOOM_Pt1(1,2) <= ylim(2))
         ZOOM_found = 1;
         set(fig,'currentaxes',ax);
         break
      end % if
   end % for
   
   if ZOOM_found==0, return, end
   
   % Check for selection type
   selection_type = get(fig,'SelectionType');
   if (strcmp(selection_type, 'normal'))
      % Zoom in
      m = 1;
      scale_factor = 2; % the default zooming factor
  elseif (strcmp(selection_type, 'alt'))
      % Zoom all the way out
	  if (zoomy == 0)
		  mzoom(fig,'xout');
	  else
      	  mzoom(fig,'out');
	  end
      return;
   elseif (strcmp(selection_type, 'extend'))
      % Zoom partially out
      m = -1;
      scale_factor = 2;
   elseif (strcmp(selection_type, 'open') & length(allAxes) > 1)
	  % Create a new figure window with just this axis in it,
	  % and turn on zooming
	  newfig = figure;
	  newax = copyobj(ax,newfig);
	  set(newax,'Position',[0.1300    0.1100    0.7750    0.8150]);
	  limits = get(get(newax,'ZLabel'),'UserData');
	  if zoomx,
	  	set(newax,'xlim',limits(1,1:2)); % zoom out before starting zoom
	  end
	  if zoomy,
		set(newax,'ylim',limits(1,3:4));
	  end
	  if (zoomy == 0)
		  mzoom(newfig,'xon');
	  elseif (zoomx == 0)
		  mzoom(newfig,'yon');
	  else
		  mzoom(newfig,'on');
	  end
	  set(get(newax,'ZLabel'),'UserData',limits(1,:)); % Eliminate handles of connected axes 
	  set(newax,'xlim',get(ax,'xlim')); % zoom back in
	  set(newax,'ylim',get(ax,'ylim'));
	  return;
	else return;
    end
   
   ZOOM_Pt1 = get_currentpoint(ax);
   ZOOM_Pt2 = ZOOM_Pt1;
   center = ZOOM_Pt1;
   
   if (m == 1)
      % Zoom in
      units = get(fig,'units'); set(fig,'units','pixels')
      rbbox([get(fig,'currentpoint') 0 0],get(fig,'currentpoint'));
      ZOOM_Pt2 = get_currentpoint(ax);
      set(fig,'units',units)
      
      % Note the currentpoint is set by having a non-trivial up function.
      if min(abs(ZOOM_Pt1-ZOOM_Pt2)) >= ...
            min(.01*[diff(get_xlim(ax)) diff(get_ylim(ax))]),
         % determine axis from rbbox 
         a = [ZOOM_Pt1;ZOOM_Pt2]; a = [min(a);max(a)];
         
         % Undo the effect of get_currentpoint for log axes
         if strcmp(get(ax,'XScale'),'log'),
            a(1:2) = 10.^a(1:2);
         end
         if strcmp(get(ax,'YScale'),'log'),
            a(3:4) = 10.^a(3:4);
         end
         rbbox_mode = 1;
      end
   end
   limits = mzoom(fig,'getlimits');
   
elseif strcmp(zoomCommand,'scale'),
	return;		% This command doesn't seem to work very well
	if all(get(ax,'view')==[0 90]), % 2D zooming with scale_factor
      
      % Activate axis that is clicked in
      ZOOM_found = 0;
      ax = gca;
      xlim = get(ax,'xlim');
      ylim = get(ax,'ylim');
      ZOOM_Pt1 = [sum(xlim)/2 sum(ylim)/2];
      ZOOM_Pt2 = ZOOM_Pt1;
      center = ZOOM_Pt1;
      
      if (xlim(1) <= ZOOM_Pt1(1,1) & ZOOM_Pt1(1,1) <= xlim(2) & ...
            ylim(1) <= ZOOM_Pt1(1,2) & ZOOM_Pt1(1,2) <= ylim(2))
         ZOOM_found = 1;
      end % if
      
      if ZOOM_found==0, return, end
      
      if (scale_factor >= 1)
         m = 1;
      else
         m = -1;
      end
      
   else % 3D
      old_CameraViewAngle = get(ax,'CameraViewAngle')*pi/360;
      ncva = atan(tan(old_CameraViewAngle)*(1/scale_factor))*360/pi;
      set(ax,'CameraViewAngle',ncva);
      return;
   end
   
   limits = mzoom(fig,'getlimits');
   
elseif strcmp(zoomCommand,'on'),
   state = getappdata(fig,'ZOOMFigureState');
   if isempty(state),
      state = uisuspend(fig);
      setappdata(fig,'ZOOMFigureState',state);
   end
   set(fig,'windowbuttondownfcn','mzoom down', ...
      'windowbuttonupfcn','ones;', ...
      'windowbuttonmotionfcn','','buttondownfcn','', ...
      'interruptible','on');
   set(ax,'interruptible','on')
   set(fig,'KeyPressFcn','ArrowShiftCallback');
   return
   
elseif strcmp(zoomCommand, 'reset'),
   hZlabel = get(ax, 'Zlabel');
   ZlabelUserData = get(hZlabel, 'UserData');
   
   if IsZoomData(ZlabelUserData),
      set(hZlabel, 'UserData', []);
   end
   return
   
elseif strcmp(zoomCommand,'xon'),
   mzoom(fig,'on') % Set up userprop
   set(fig,'windowbuttondownfcn','mzoom xdown', ...
      'windowbuttonupfcn','ones;', ...
      'windowbuttonmotionfcn','','buttondownfcn','',...
      'interruptible','on');
   set(ax,'interruptible','on')
   set(fig,'KeyPressFcn','ArrowShiftCallback');
   return
   
elseif strcmp(zoomCommand,'yon'),
   mzoom(fig,'on') % Set up userprop
   set(fig,'windowbuttondownfcn','mzoom ydown', ...
      'windowbuttonupfcn','ones;', ...
      'windowbuttonmotionfcn','','buttondownfcn','',...
      'interruptible','on');
   set(ax,'interruptible','on')
   set(fig,'KeyPressFcn','ArrowShiftCallback');
   return
   
elseif strcmp(zoomCommand,'out'),
   limits = mzoom(fig,'getlimits');
   center = [sum(get_xlim(ax))/2 sum(get_ylim(ax))/2];
   m = -inf; % Zoom totally out
   
elseif strcmp(zoomCommand,'getlimits'), % Get axis limits
   limits = get(get(ax,'ZLabel'),'UserData');
   % Do simple checking of userdata
   if size(limits,2)==4 & size(limits,1)<=2, 
      if all(limits(1,[1 3])<limits(1,[2 4])), 
         getlimits = 0; out = limits(1,:); return   % Quick return
      else
         getlimits = -1; % Don't munge data
      end
   else
      if isempty(limits), getlimits = 1; else getlimits = -1; end
   end
   
   % If I've made it to here, we need to compute appropriate axis
   % limits.
   
   if isempty(get(get(ax,'ZLabel'),'userdata')),
      % Use quick method if possible
      xlim = get_xlim(ax); xmin = xlim(1); xmax = xlim(2); 
      ylim = get_ylim(ax); ymin = ylim(1); ymax = ylim(2); 
      
   elseif strcmp(get(ax,'xLimMode'),'auto') & ...
         strcmp(get(ax,'yLimMode'),'auto'),
      % Use automatic limits if possible
      xlim = get_xlim(ax); xmin = xlim(1); xmax = xlim(2); 
      ylim = get_ylim(ax); ymin = ylim(1); ymax = ylim(2); 
      
   else
      % Use slow method only if someone else is using the userdata
      h = get(ax,'Children');
      xmin = inf; xmax = -inf; ymin = inf; ymax = -inf;
      for i=1:length(h),
         t = get(h(i),'Type');
         if ~strcmp(t,'text'),
            if strcmp(t,'image'), % Determine axis limits for image
               x = get(h(i),'Xdata'); y = get(h(i),'Ydata');
               x = [min(min(x)) max(max(x))];
               y = [min(min(y)) max(max(y))];
               [ma,na] = size(get(h(i),'Cdata'));
               if na>1, dx = diff(x)/(na-1); else dx = 1; end
               if ma>1, dy = diff(y)/(ma-1); else dy = 1; end
               x = x + [-dx dx]/2; y = y + [-dy dy]/2;
            end
            xmin = min(xmin,min(min(x)));
            xmax = max(xmax,max(max(x)));
            ymin = min(ymin,min(min(y)));
            ymax = max(ymax,max(max(y)));
         end
      end
      
      % Use automatic limits if in use (override previous calculation)
      if strcmp(get(ax,'xLimMode'),'auto'),
         xlim = get_xlim(ax); xmin = xlim(1); xmax = xlim(2); 
      end
      if strcmp(get(ax,'yLimMode'),'auto'),
         ylim = get_ylim(ax); ymin = ylim(1); ymax = ylim(2); 
      end
   end
   
   limits = [xmin xmax ymin ymax];
   if getlimits~=-1, % Don't munge existing userdata.
      % Store limits in ZLabel userdata
      set(get(ax,'ZLabel'),'UserData',limits);
   end
   
   out = limits;
   return
   
elseif strcmp(zoomCommand,'getconnect'), % Get connected axes
   limits = get(get(ax,'ZLabel'),'UserData');
   if all(size(limits)==[2 4]), % Do simple checking
      out = limits(2,[1 2]);
   else
      out = [ax ax];
   end
   return
   
elseif strcmp(zoomCommand,'fill'),
   old_view = get(ax,'view');
   view(45,45);
   set(ax,'CameraViewAngleMode','auto');
   set(ax,'CameraViewAngle',get(ax,'CameraViewAngle'));
   view(old_view);
   return
   
else
   error(['Unknown option: ',zoomCommand,'.']);
end

%
% Actual zoom operation
%

if ~rbbox_mode,
   xmin = limits(1); xmax = limits(2); 
   ymin = limits(3); ymax = limits(4);
   
   if m==(-inf),
      dx = xmax-xmin;
      dy = ymax-ymin;
   else
      dx = diff(get_xlim(ax))*(scale_factor.^(-m-1)); dx = min(dx,xmax-xmin);
      dy = diff(get_ylim(ax))*(scale_factor.^(-m-1)); dy = min(dy,ymax-ymin);
   end
   
   % Limit zoom.
   center = max(center,[xmin ymin] + [dx dy]);
   center = min(center,[xmax ymax] - [dx dy]);
   a = [max(xmin,center(1)-dx) min(xmax,center(1)+dx) ...
         max(ymin,center(2)-dy) min(ymax,center(2)+dy)];
   
   % Check for log axes and return to linear values.
   if strcmp(get(ax,'XScale'),'log'),
      a(1:2) = 10.^a(1:2);
   end
   if strcmp(get(ax,'YScale'),'log'),
      a(3:4) = 10.^a(3:4);
   end
   
end

% Check for axis equal and update a as necessary
if strcmp(get(ax,'plotboxaspectratiomode'),'manual') & ...
   strcmp(get(ax,'dataaspectratiomode'),'manual')
   ratio = get(ax,'plotboxaspectratio')./get(ax,'dataaspectratio');
   dx = a(2)-a(1);
   dy = a(4)-a(3);
   [kmax,k] = max([dx dy]./ratio(1:2));
   if k==1
      dy = kmax*ratio(2);
      a(3:4) = mean(a(3:4))+[-dy dy]/2;
   else
     dx = kmax*ratio(1);
     a(1:2) = mean(a(1:2))+[-dx dx]/2;
   end
end

% Update circular list of connected axes
list = mzoom(fig,'getconnect'); % Circular list of connected axes.
if zoomx,
   if a(1)==a(2), return, end % Short circuit if zoom is moot.
   set(ax,'xlim',a(1:2))
   h = list(1);
   while h ~= ax,
      set(h,'xlim',a(1:2))
      % Get next axes in the list
      next = get(get(h,'ZLabel'),'UserData');
      if all(size(next)==[2 4]), h = next(2,1); else h = ax; end
   end
end
if zoomy,
   if a(3)==a(4), return, end % Short circuit if zoom is moot.
   set(ax,'ylim',a(3:4))
   h = list(2);
   while h ~= ax,
      set(h,'ylim',a(3:4))
      % Get next axes in the list
      next = get(get(h,'ZLabel'),'UserData');
      if all(size(next)==[2 4]), h = next(2,2); else h = ax; end
   end
end

function bZoomData = IsZoomData(data)
% Return 1 if the data represents zoom data
% Return 0 if someone else is using user data

if size(data,2)==4 & size(data,1)<=2, 
   if all(data(1,[1 3])<data(1,[2 4])), 
      bZoomData = 1;
   else
      bZoomData = 0;
   end
else
   bZoomData = 0;
end

function p = get_currentpoint(ax)
%GET_CURRENTPOINT Return equivalent linear scale current point
p = get(ax,'currentpoint'); p = p(1,1:2);
if strcmp(get(ax,'XScale'),'log'),
   p(1) = log10(p(1));
end
if strcmp(get(ax,'YScale'),'log'),
   p(2) = log10(p(2));
end

function xlim = get_xlim(ax)
%GET_XLIM Return equivalent linear scale xlim
xlim = get(ax,'xlim');
if strcmp(get(ax,'XScale'),'log'),
   xlim = log10(xlim);
end

function ylim = get_ylim(ax)
%GET_YLIM Return equivalent linear scale ylim
ylim = get(ax,'ylim');
if strcmp(get(ax,'YScale'),'log'),
   ylim = log10(ylim);
end

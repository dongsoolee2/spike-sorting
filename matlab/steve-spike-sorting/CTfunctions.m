function CTfunctions (action,h)
	if (nargin < 2)
		h = gcbf;
	end
	g=getuprop (h,'g');
	handles = getuprop(h,'handles');
	% Now find the companion axis to the callback axis
	[placeholder,chsel] = find(handles.cc == gcbo);
	selected=getuprop(handles.cc(chsel),'CTselected');
	selected=~selected;
	if (selected)
		set(handles.cc(chsel),'Color',[1 0.8 0.8])
	else
		set(handles.cc(chsel),'Color',[0.8 1 1])
	end
	setuprop(handles.cc(chsel),'CTselected',selected);
	selected=zeros(length(g.channels));
	for ch=1:length(g.channels)
		selected(ch)=getuprop(handles.cc(ch),'CTselected');
	end
	g.ctchannels=g.channels(find(selected));
	
	hctlist=getuprop(h,'hctlist');
	if (ishandle(hctlist))
		set(hctlist,'String',sprintf('cross talk: %s',num2str(g.ctchannels)));
	end
	setuprop(h,'g',g);

function fig = DoChannel(spikefiles,noisefiles,channel,deffilters,subrange,params,g)
% DoChannel: group one electrode's spike waveforms based on shape
% DoChannel(spikefiles,noisefiles,channel,deffilters,subrange,params)
% where
%	spikefiles is a cell array of filenames for spike snippets
%	noisefiles is a cell array of filenames for noise snippets
%	channel is the channel number
% If you want to supply default filters (optional), you must provide both
%	deffilters and subrange
% Also optional is params, which controls the default behavior of the GUI.
%	See DCDefParams for default values.
%
% Ouput:
%	The sorting data is stored as user properties of the figure (see getappdata).
%	The indices of
%	the spikes belonging to cluster clustnum in file spikefiles{filenum} are stored
%	as clflindx{clustnum,filenum}. The times (in scan #) of all the spikes are
%	in t{filenum}. The scanrate for each file is stored in the vector scanrate.
% (C) 2015 The Baccus Lab
%
% History:
% ?? - Tim Holy
%   - wrote it
%
% 2015-09-02 - Lane McIntosh
%   - updating to use HDF snippet file format
%
if (nargin < 6)
	params = [];
end
params = DCDefParams(params);	% Fill in any blank fields with defaults

[chans,nsnips,sniprange] = GetSnipNums(spikefiles);
chindx = find(channel == chans);
if (isempty(chindx))		% Was this channel recorded?
	fig = [];
	errordlg(sprintf('Channel %d was not recorded.',channel));
	return;
end
% Get spike times
for fnum= 1:length(spikefiles)
    [~, t{fnum}] = loadSnip(spikefiles{fnum},'spike',channel);
    scanrate(fnum) = g.scanrate;
	%[t{fnum},header{fnum}] = LoadSnipTimes(spikefiles{fnum},channel);
	%scanrate(fnum) = header{fnum}.scanrate;
	%rectime(fnum) = header{fnum}.nscans/header{fnum}.scanrate;
end
hfig = figure('Units','points', ...
	'Color',[0.8 0.8 0.8], ...
	'Position',[21 92 963 603], ...
	'ButtonDownFcn','DoChanFunctions Unselect',...
	'KeyPressFcn','DoChanFunctions KeyTrap',...
	'Name','Channel Grouping',...
	'Tag','ChannelFig');
for i = 1:2
	for j = 1:7
		if (j > 1)
			left = 144+(j-2)*120;
		else
			left = 15;
		end
		bottom = 471-(i-1)*100;
		pos = [left,bottom,109,91];
		haxc(i,j) = axes('Parent',hfig, ...
			'Units','pixels', ...
			'CameraUpVector',[0 1 0], ...
			'Color',[1 1 1], ...
			'Position',pos, ...
			'XColor',[0 0 0], ...
			'YColor',[0 0 0], ...
			'ZColor',[0 0 0]);
	end
end
h1 = uicontrol('Parent',hfig, ...
	'Units','points', ...
	'HorizontalAlignment','left', ...
	'Position',[859 505 42 19], ...
	'String','Display', ...
	'Style','text', ...
	'Tag','StaticText3');
h1 = uicontrol('Parent',hfig, ...
	'Units','points', ...
	'BackgroundColor',[1 1 1], ...
	'HorizontalAlignment','right', ...
	'Position',[901 507 40 20], ...
	'String',num2str(params.dispsnips), ...
	'Style','edit', ...
	'Callback','DoChanFunctions(''UpdateDisplay'',gcbf)',...
	'Tag','DispNumSnips');
h1 = uicontrol('Parent',hfig, ...
	'Units','points', ...
	'HorizontalAlignment','left', ...
	'Position',[859 415 25 15], ...
	'String','Max:', ...
	'Style','text', ...
	'Tag','StaticText4');
h1 = uicontrol('Parent',hfig, ...
	'Units','points', ...
	'BackgroundColor',[1 1 1], ...
	'HorizontalAlignment','right', ...
	'Position',[886 413 39 20], ...
	'String',num2str(params.ACTime), ...
	'Style','edit', ...
	'Callback','DoChanFunctions(''UpdateDisplay'',gcbf)',...
	'Tag','ACTime');
h1 = uicontrol('Parent',hfig, ...
	'Units','points', ...
	'Position',[925 417 12 13], ...
	'String','s', ...
	'Style','text', ...
	'Tag','StaticText4');

hctext(1) = uicontrol('Parent',hfig, ...
	'Units','points', ...
	'Position',[15 340 106 20], ...
	'String','Unassigned: ', ...
	'Style','text', ...
	'Tag','StaticText2');
for i = 1:6
	left = 150+(i-1)*120;
	pos = [left 340 106 20];
	hctext(i+1) = uicontrol('Parent',hfig, ...
		'Units','points', ...
		'Position',pos, ...
		'String',sprintf('%d: 0',i), ...
		'Style','text', ...
		'Tag','ClusterText');
end

h1 = uicontrol('Parent',hfig, ...
	'Units','points', ...
	'HorizontalAlignment','right', ...
	'Position',[130 270 40 20], ...
	'String','spikes', ...
	'Style','text', ...
	'Tag','StaticText1');
h1 = uicontrol('Parent',hfig, ...
	'Units','points', ...
	'HorizontalAlignment','right', ...
	'Position',[140 240 30 20], ...
	'String','noise', ...
	'Style','text', ...
	'Tag','StaticText1');
h1 = uicontrol('Parent',hfig, ...
	'Units','points', ...
	'BackgroundColor',[1 1 1], ...
	'Position',[180 270 61 21], ...
	'String',num2str(params.NSpikes), ...
	'Style','edit', ...
	'Tag','NumSpikes');
h1 = uicontrol('Parent',hfig, ...
	'Units','points', ...
	'BackgroundColor',[1 1 1], ...
	'Position',[180 240 61 21], ...
	'String',num2str(params.NNoise), ...
	'Style','edit', ...
	'Tag','NumNoise');
h1 = uicontrol('Parent',hfig, ...
	'Units','points', ...
	'Position',[30 270 102 29], ...
	'String','Variance Filters', ...
	'Callback','DoChanFunctions BuildFilters',...
	'Tag','BuildFiltersButton');
h1 = uicontrol('Parent',hfig, ...
	'Units','points', ...
	'Position',[30 230 102 29], ...
	'String','Discrim. Filters', ...
	'Callback','DoChanFunctions DiscrimFilters',...
	'Enable','off', ...
	'Tag','DiscrimFiltersButton');
h1 = axes('Parent',hfig, ...
	'Units','pixels', ...
	'CameraUpVector',[0 1 0], ...
	'Color',[1 1 1], ...
	'Position',[291 201 180 128], ...
	'Tag','SVAxes', ...
	'XColor',[0 0 0], ...
	'YColor',[0 0 0], ...
	'ZColor',[0 0 0]);
ylabel('Singular values');
h1 = axes('Parent',hfig, ...
	'Units','pixels', ...
	'CameraUpVector',[0 1 0], ...
	'Color',[1 1 1], ...
	'Position',[521 201 180 128], ...
	'Tag','WaveAxes', ...
	'XColor',[0 0 0], ...
	'YColor',[0 0 0], ...
	'ZColor',[0 0 0]);
ylabel('Waveforms');
h1 = axes('Parent',hfig, ...
	'Units','pixels', ...
	'CameraUpVector',[0 1 0], ...
	'Color',[1 1 1], ...
	'Position',[751 201 180 128], ...
	'Tag','FiltAxes', ...
	'XColor',[0 0 0], ...
	'YColor',[0 0 0], ...
	'ZColor',[0 0 0]);
ylabel('Filters');
h1 = uicontrol('Parent',hfig, ...
	'Units','points', ...
	'Position',[30 90 82 29], ...
	'String','Cluster', ...
	'Callback','DoChanFunctions Cluster',...
	'Enable','off',...
	'Tag','ClusterButton');
hdeffltbox = uicontrol('Parent',hfig, ...
	'Units','points', ...
	'Position',[30 50 111 25], ...
	'String','Use default filters', ...
	'Style','checkbox', ...
	'Callback','DoChanFunctions DefFiltBox',...
	'Tag','DefaultFiltersBox');
h1 = uicontrol('Parent',hfig, ...
	'Units','points', ...
	'HorizontalAlignment','right', ...
	'Position',[120 90 50 20], ...
	'String','block size', ...
	'Style','text', ...
	'Tag','StaticText1');
h1 = uicontrol('Parent',hfig, ...
	'Units','points', ...
	'BackgroundColor',[1 1 1], ...
	'Position',[180 90 61 21], ...
	'String',num2str(params.BlockSize), ...
	'Style','edit', ...
	'Tag','BlockSize');
h1 = uicontrol('Parent',hfig, ...
	'Units','points', ...
	'Position',[630 90 82 29], ...
	'String','CrossCorr', ...
	'Callback','DoChanFunctions CrossCorr',...
	'Tag','CCButton');
h1 = uicontrol('Parent',hfig, ...
	'Units','points', ...
	'Position',[740 90 82 29], ...
	'String','Join', ...
	'Callback','DoChanFunctions Join',...
	'Tag','JoinButton');
h1 = uicontrol('Parent',hfig, ...
	'Units','points', ...
	'Position',[850 90 82 29], ...
	'String','Reconstruct', ...
	'Callback','DoChanFunctions Recon',...
	'Tag','ReconButton');
h1 = uicontrol('Parent',hfig, ...
	'Units','points', ...
	'Position',[630 45 82 29], ...
	'String','Clear', ...
	'Callback','DoChanFunctions Clear',...
	'Tag','ClearButton');
h1 = uicontrol('Parent',hfig, ...
	'Units','points', ...
	'Position',[630 0 82 29], ...
	'String','Crosstalk', ...
	'Callback','DoChanFunctions Crosstalk',...
	'Tag','CTButton');
h1 = uicontrol('Parent',hfig, ...
	'Units','points', ...
	'Position',[740 0 82 29], ...
	'String','Multichannel', ...
	'Callback','DoChanFunctions Multichannel',...
	'Tag','CTButton');
h1 = uicontrol('Parent',hfig, ...
	'Units','points', ...
	'Position',[740 45 82 29], ...
	'String','Cancel', ...
	'Callback','DoChanFunctions Cancel',...
	'Tag','CancelButton');
h1 = uicontrol('Parent',hfig, ...
	'Units','points', ...
	'Position',[850 45 82 29], ...
	'String','Done', ...
	'Callback','DoChanFunctions Done',...
	'Tag','DoneButton');
h1 = uicontrol('Parent',hfig, ...
	'Units','points', ...
	'Position',[450 570 60 16], ...
	'String',sprintf('Channel %d',channel), ...
	'Style','text', ...
	'Tag','ChannelNumberText');
h1 = axes('Parent',hfig, ...
	'Units','pixels', ...
	'CameraUpVector',[0 1 0], ...
	'Color',[1 1 1], ...
	'Position',[371 31 230 133], ...
	'Tag','SpikesPerFile', ...
	'XColor',[0 0 0], ...
	'YColor',[0 0 0], ...
	'ZColor',[0 0 0]);
hctlist = uicontrol('Parent',hfig, ...
	'Units','points', ...
	'HorizontalAlignment','left', ...
	'Position',[620 120 150 40], ...
	'String','Cross talk:', ...
	'Style','text', ...
	'Tag','StaticText1');
ylabel('# spikes/file');

% Set the data that the callbacks will need
if (nargin >= 4)
	setappdata(hfig,'DefaultFilters',deffilters);
	setappdata(hfig,'DefaultSubrange',subrange);
else
	set(hdeffltbox,'Enable','off');
end
setappdata(hfig,'params',params);
setappdata(hfig,'spikefiles',spikefiles);
setappdata(hfig,'noisefiles',noisefiles);
setappdata(hfig,'channel',channel);
setappdata(hfig,'allchannels',g.channels);
setappdata(hfig,'chindx',chindx);
setappdata(hfig,'haxc',haxc);
setappdata(hfig,'hctext',hctext);
setappdata(hfig,'hctlist',hctlist);
setappdata(hfig,'nsnips',nsnips(chindx,:));
for fnum= 1:length(spikefiles)
	clflindx{1,fnum} =g.times{chindx}{fnum}(2,:);
end
setappdata(hfig,'clflindx',clflindx);
setappdata(hfig,'t',t);
setappdata(hfig,'alltimes',g.times);
setappdata(hfig,'hch',g.hch);
setappdata(hfig,'hcc',g.hcc);
setappdata(hfig,'hmain',g.hmain);
setappdata(hfig,'proj',g.proj);
setappdata(hfig,'xc',g.xc);
setappdata(hfig,'yc',g.yc);
setappdata(hfig,'nspikes',g.nspikes);
setappdata(hfig,'scanrate',scanrate);		% For converting times to seconds in autocorrelation
%setappdata(hfig,'rectime',rectime);
idxrem=cell(1,length(g.channels));					%For indexes of crosstalk
for ch = 1:length(g.channels)
	idxrem{ch}=cell(1,length(spikefiles));
end
setappdata(hfig,'idxrem',idxrem);
set(haxc(:,1),'Selected','on');	% Start with the unassigned cluster selected
DoChanFunctions('UpdateDisplay',hfig);
if nargout > 0, fig = hfig; end


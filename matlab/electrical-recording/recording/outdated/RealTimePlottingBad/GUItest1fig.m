function fig = GUItest1fig()% This is the machine-generated representation of a Handle Graphics object% and its children.  Note that handle values may change when these objects% are re-created. This may cause problems with any callbacks written to% depend on the value of the handle at the time the object was saved.%% To reopen this object, just type the name of the M-file at the MATLAB% prompt. The M-file and its associated MAT-file must be on your path.load GUItest1figh0 = figure('Units','points', ...	'Color',[0.8 0.8 0.8], ...	'Colormap',mat0, ...	'Position',[363 283 512 404], ...	'Tag','Fig1');h1 = uicontrol('Parent',h0, ...	'Units','points', ...	'Callback','runcounter', ...	'Position',[55 316 84 31], ...	'String','Start', ...	'Tag','Pushbutton1');h1 = uicontrol('Parent',h0, ...	'Units','points', ...	'Callback','stopcounter', ...	'Position',[187 317 84 31], ...	'String','Stop', ...	'Tag','Pushbutton1');h1 = uicontrol('Parent',h0, ...	'Units','points', ...	'Position',[90 260 163 30], ...	'Style','text', ...	'Tag','CounterText');if nargout > 0, fig = h0; end

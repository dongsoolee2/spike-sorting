function groupcw(outfile,datafiles,spikefiles,noisefiles,channels)
% groupcw: shape sorting of snippet waveforms
% written by Tim Holy and Stephen Baccus 1999-2004
%
% Updates:
%
% 2015-07-20 - Benjamin Naecker 
%	- Updating to use HDF snippet file format
%	- Removing support for peak-width data
%
% Three calling modes:
%	groupcw(outfilename, snipfile)
%		outfilename: name of sorted output .mat file
%		snipfile: Name of HDF snippet file, output from extract
%	groupcw(outfilename) 
%		Use this mode when you've sorted previously, and want
%		to continue where you left off. outfilename must already exist.

% Find out if output file already exists.
% If it does, load it in and start appending	
if (exist(outfile, 'file'))		% If file already exists

	fprintf(sprintf('Continuing to sort file %s...\n', outfile));
	load(outfile)
	nfiles = size(g.spikefiles, 2);
	nchans = size(g.channels, 2);
	g.ctchannels = [];
	if (~exist('removedCT', 'var'))
		removedCT = cell(nchans, nfiles);
	end
	%Setup array window
	handles = makearraywindow(g.channels);
	arrayplot(g.channels, handles.ch, g.xc, g.yc, g.nspikes);
	setuprop(handles.main, 'g', g);		

else % File does not yet exist

	pwflag = 0;
	hmain = setup(outfile, snipfile);
	g = getuprop(hmain, 'g');
	save(outfile, 'g');

end 

return

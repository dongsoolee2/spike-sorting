function [hxlabel,hylabel] = PlotMMkoffRStimCI(c,pbest,ci,cellindx)
ncells = size(pbest,2);
if (length(ci) ~= ncells)
	error('The number of cells in the parameters & confidence intervals do not match');
end
%dims = CalcSubplotDims(ncells,'Relative concentration','r_{\rm stim} (Hz)');
dims = CalcSubplotDims(ncells);
bottomrow = (dims(1)-1)*dims(2);
for i = 1:ncells
	subplot(dims(1),dims(2),i);
	cic = ci{i};
	l = [pbest(5:8,i),pbest(9:12,i)] - [cic(1,5:8)',cic(1,9:12)'];
	u = [cic(2,5:8)',cic(2,9:12)'] - [pbest(5:8,i),pbest(9:12,i)];
	%errorbar([c',c'],[pbest(5:8,i),pbest(9:12,i)],l,u);
	plot([c',c'],[pbest(5:8,i),pbest(9:12,i)]);
	if (i <= bottomrow)
		set(gca,'XTick',[]);
	end
	axis tight
	title(sprintf('%d',cellindx(i)));
end

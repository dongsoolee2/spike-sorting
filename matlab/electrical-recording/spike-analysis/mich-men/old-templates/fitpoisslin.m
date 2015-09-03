nexp = 32;nparms = 7;ntimes = length(ti);dims = [nparms nexp];% Order of variables in the vectors:% var:%	spont rate%	const of proportionality%	time delay%	off rate%	2 on rate proportionality constants% fix:%	duration of ligand application%	relative concentrationcoloffset = (0:nexp-1)*nparms;block = coloffset(1:ntimes);blen = coloffset(ntimes+1);varloc = {1+coloffset,2+coloffset,6+coloffset,4+coloffset,...	3+coloffset(1:nexp/2),3+coloffset(nexp/2+1:end)};colToffset = (0:ntimes:nexp-1)*nparms;fixloc = {5+colToffset,5+colToffset+nparms,5+colToffset+2*nparms,...	5+colToffset+3*nparms,[7+block,7+block+nexp*nparms/2],...	[7+block+blen,7+block+blen+nexp*nparms/2],[7+block+2*blen,7+block+2*blen+nexp*nparms/2],...	[7+block+3*blen,7+block+3*blen+nexp*nparms/2]};pfix = [0.5 1 2 4 1/1000 1/300 1/100 1/30];explabelbase = cvlabel(3:end);timelabel = {'0.5s','1s','2s','4s'};for i = 1:nexp	explabel{i} = [explabelbase{floor((i-1)/ntimes)+1},', ',timelabel{mod(i-1,ntimes)+1}];endtr = [trange(1)*ones(1,nexp);trange(2)*ones(1,nexp)];

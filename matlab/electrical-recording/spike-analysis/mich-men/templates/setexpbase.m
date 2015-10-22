nexp = 32;nparms = 6;ntimes = length(ti);dims = [nparms nexp];% Order of variables in the vectors:% var:%	tdelay%	kf%	8 on rates (F/1000,F/300,F/100,F/30,M/1000,M/300,M/100,M/30)%	8 steady-state rates (same order)% fix:%	duration of ligand application%	rspont% If want to make rspont variable, make it the last one% in the variable vector, and toggle the commenting-out belowcoloffset = (0:nexp-1)*nparms;block = coloffset(1:ntimes);blen = coloffset(ntimes+1);varloc = {1+coloffset,5+coloffset};for i = 0:nexp/ntimes-1	varloc{end+1} = 4+block+i*blen;endfor i = 0:nexp/ntimes-1	varloc{end+1} = 3+block+i*blen;end% varloc{end+1} = 2+coloffset;						% rspont variablecolToffset = (0:ntimes:nexp-1)*nparms;fixloc = {6+colToffset,6+colToffset+nparms,6+colToffset+2*nparms,...	6+colToffset+3*nparms};fixloc{end+1} = 2+coloffset;						% rspont fixedpfix = [0.5 1 2 4]';trfull = [trange(1)*ones(1,nexp);trange(2)*ones(1,nexp)];	% rspont variabletr = [zeros(1,nexp); trange(2)*ones(1,nexp)];			% rspont fixedfunc = 'RateExpBase';ifunc = 'IntRateExpBase';pcheckfunc = 'PCheckRateExpBase';pvarstart = ones(18,1);
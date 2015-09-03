function zspike = ParseCell(cl,uspike,ustim,ti,trange)% ParseCell: lump spikes with given stimulus, on-time together% zspike = ParseCell(cl,uspike,ustim,ti,trange)st = 4:11;clear zspike;nst = length(st);ntimes = length(ti);for j = 1:nst	for i = 1:ntimes		cspike = uspike{st(j),cl}(ti{i});		cstim = ustim{st(j)}(ti{i});		nrpts = length(ti{i});		for k = 1:nrpts			zspike{(j-1)*ntimes+i}{k} = cspike{k} - cstim{k}(2,1) + trange(1);		end	endend

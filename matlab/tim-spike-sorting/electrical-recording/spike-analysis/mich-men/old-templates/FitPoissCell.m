function [zspike,pstart] = FitPoissCell(cl,uspike,ustim,ti,trange)st = 4:11;clear zspike;nst = length(st);ntimes = length(ti);nrpts = length(ti{1});% Order of experiments in zspike:% F/1000: 0.5, 1, 2, 4% F/300: 0.5, 1, 2, 4% Then continue with F/100,F/30,M/1000,M/300,M/100,M/30for j = 1:nst	for i = 1:ntimes		cspike = uspike{st(j),cl}(ti{i});		cstim = ustim{st(j)}(ti{i});		for k = 1:nrpts			zspike{(j-1)*ntimes+i}{k} = cspike{k} - cstim{k}(2,1) + trange(1);		end	endendnexp = length(zspike);nparms = 6;dims = [nparms nexp];% Starting parameters[rspontf,rinff,kofff,konf] = PestMichMen(zspike(1:4:16),trange,4);[rspontm,rinfm,koffm,konm] = PestMichMen(zspike(20:4:32),trange,4);pstart(1)=(rspontf+rspontm)/2;pstart(2)=(rinff+rinfm)/2;pstart(3) = 0.5;pstart(4:5) = [kofff,koffm];pstart(6:9) = konf;pstart(10:13) = konm;pstart = pstart';%pcell16 = [2 40 0.5 0.3 0.3 0.3 0.3 0.3 0.3 0.3 1 3 4]';%pcell17 = [0.5 30 0.5 0.5 0.5 0.25 0.5 1 2 0.25 0.5 1 2]';%pcell23 = [0.75 25 0.5 1 1 0.3 0.3 0.3 0.3 0.3 1 3 4]';%cp = pcell23;%cprange = 0.2*cp;%prange = 0.2*pstart;% pbest = StatPSTRate(zspike,tr,pstart,prange,varloc,pfix,fixloc,nparms,'RateMichMen','IntRateMichMen');
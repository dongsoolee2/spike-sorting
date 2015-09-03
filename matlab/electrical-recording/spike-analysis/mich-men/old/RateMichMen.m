function rout = RateMichMen(spikes,p)% RateMichMen: Michaelis-Menten model for firing rate to a square pulse of ligand% rout = RateMichMen(spikes,p), where the parameters p are%	p(1) = spont. firing rate%	p(2) = const. of proportionality btw. rate & active fraction%		(i.e. rate = p(2)*(active fraction) + p(1))%	p(3) = on rate%	p(4) = off rate%	p(5) = duration of ligand application%	p(6) = time delayrout = zeros(size(spikes));spikes = spikes - p(6);	% adjust for the time delaybeforeind = find(spikes <= 0);rout(beforeind) = p(1);	% before the stimulus turns on, it's just the spont. rateduringind = find(spikes > 0 & spikes <= p(5));rout(duringind) = p(2)*p(3)/(p(3)+p(4)) * (1-exp(-(p(3)+p(4))*spikes(duringind))) + p(1);rAtOff = p(2)*p(3)/(p(3)+p(4)) * (1-exp(-(p(3)+p(4))*p(5)));afterind = find(spikes > p(5));rout(afterind) = exp(-p(4)*(spikes(afterind)-p(5)))*rAtOff + p(1);

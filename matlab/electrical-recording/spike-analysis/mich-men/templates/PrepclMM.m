zsp = ParseCell(cl,uspike,ustim,ti,trange);[zspike,rspont,rsponterr] = ClipSpike0(zsp,trfull);pfix(5) = rspont;ssrates = SSRates(zspike);pvarstart = [0.5 1 max(ssrates)+1 ssrates]';

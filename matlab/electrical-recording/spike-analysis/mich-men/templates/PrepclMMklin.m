zsp = ParseCell(cl,uspike,ustim,ti,trange);[zspike,rspont,rsponterr] = ClipSpike0(zsp,trfull);pfix(9) = rspont;ssrates = SSRates(zspike);rprop = max(ssrates)+1;pvarstart = [0.5 1 rprop 100 100]';
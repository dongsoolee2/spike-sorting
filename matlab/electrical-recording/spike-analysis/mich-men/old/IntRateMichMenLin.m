function irate = IntRateMichMenLin(trange,p)pnew = p(1:6);pnew(3) = p(3)*p(7);irate = IntRateMichMen(trange,pnew);

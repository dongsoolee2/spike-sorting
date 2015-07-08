function [ir,g] = IntRateMMkoff(trangep,p)
% IntRateMMkoff: Michaelis-Menten model for firing rates, with hidden koff
% Like IntRateExpBase, except rstim = rprop*(kr-koff)/kr
% Parameters:
%	p(1) = tdelay
%	p(2) = rspont
%	p(3) = rstim
%	p(4) = rprop
%	p(5) = kf
%	p(6) = koff
%	p(7) = T
rprop = p(4);
rstim = p(3);
koff = p(6);

newp = [p(1:5);p(7)];
dfr = 1-rstim/rprop;
newp(4) = koff/dfr;
if (nargout == 1)
	ir = IntRateExpBase(trangep,newp);
else
	[ir,gtemp] = IntRateExpBase(trangep,newp);
	g = gtemp;
	% Change of variable rules...
	g(3) = gtemp(3) + koff/(dfr^2*rprop) * gtemp(4);
	g(4) = -koff*rstim/(dfr*rprop)^2 * gtemp(4);
	g(6) = gtemp(4)/dfr;
end

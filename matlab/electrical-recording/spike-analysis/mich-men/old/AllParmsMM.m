function allp = AllParmsMM(c,p)if (size(p,1) ~= 11)	error('These don''t look like MM parms!');endnsim = size(p,2);allp = p;koff = repmat(p(2,:),8,1);rprop = repmat(p(3,:),8,1);allp(12:19,:) = koff./(1-p(4:11,:)./rprop)-koff;	% kpfor i = 1:nsim	allp(20,i) = 1/MMHalfMax(c,p(4:7,i));	allp(21,i) = 1/MMHalfMax(c,p(8:11,i));end